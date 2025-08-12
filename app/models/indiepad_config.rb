require "erb"

class IndiepadConfig < ApplicationRecord
# == Schema Information
#
# Table name: indiepad_configs
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#
# Indexes
#
#  index_indiepad_configs_on_game_id  (game_id)
#

  belongs_to :game

  # Expect up to 3 top-level keys: default, keynames, keycodes
  validates :data, length: {maximum: 3}
  validates :game, uniqueness: true

  validate :validate_structure

  class << self
    # Load global defaults from YAML once per process; reload in development on change.
    def defaults
      @defaults = nil if Rails.env.development?
      @defaults ||= begin
        path = Rails.root.join("config", "indiepad.yml")
        raise "Missing config/indiepad.yml" unless File.exist?(path)
        yaml = YAML.safe_load(ERB.new(File.read(path)).result, aliases: true)
        deep_symbolize_keys(yaml)
      end
    end

    private

    def deep_symbolize_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(k, v), h|
          h[k.to_sym] = deep_symbolize_keys(v)
        end
      when Array
        obj.map { |v| deep_symbolize_keys(v) }
      else
        obj
      end
    end
  end

  # Build a new config initialized with the global defaults
  def self.build_with_defaults(game:)
    new(game: game, data: defaults)
  end

  private

  before_validation :normalize_data

  def normalize_data
    return if data.blank?

    d = if data.respond_to?(:to_unsafe_h)
      data.to_unsafe_h
    else
      data
    end
    d = d.deep_stringify_keys

    allowed = %w[default keynames keycodes]
    normalized = {}

    allowed.each do |k|
      next unless d[k].is_a?(Hash)
      normalized[k] = d[k].each_with_object({}) do |(kk, vv), h|
        h[kk] = (vv.is_a?(String) && vv.match?(/\A-?\d+\z/)) ? vv.to_i : vv
      end
    end

    self.data = normalized if normalized.any?
  end

  def validate_structure
    return if data.blank?

    # Normalize keys to symbols for validation
    d = if data.respond_to?(:to_unsafe_h)
      data.to_unsafe_h
    else
      data
    end
    d = d.deep_symbolize_keys

    allowed_keys = %i[default keynames keycodes]
    unknown = d.keys - allowed_keys
    errors.add(:data, "contains unknown keys: #{unknown.join(", ")}") if unknown.any?

    %i[default keynames keycodes].each do |k|
      next unless d[k]
      unless d[k].is_a?(Hash)
        errors.add(:data, "#{k} must be a hash")
        next
      end
      # Ensure all values are integers
      unless d[k].values.all? { |v| v.is_a?(Integer) }
        errors.add(:data, "#{k} values must be integers")
      end
    end
  end
end
