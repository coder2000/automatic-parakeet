# frozen_string_literal: true

# Chartable
# Adds ranking and position calculation for ActiveRecord models.
#
# Usage:
#   include Chartable
#   user.chart_position(:score)
#
# Options:
#   - attribute: Symbol or String, must be a valid column name
#   - start_query: Optional ActiveRecord::Relation scope
#   - order: Optional Hash for custom ordering, e.g. { score: :desc, created_at: :asc }
module Chartable
  extend ActiveSupport::Concern

  # Returns the position of the record in the ranking for the given attribute(s)
  # @param attribute [Symbol, String] column to rank by
  # @param start_query [ActiveRecord::Relation, nil] optional scope
  # @param order [Hash, nil] custom ordering, e.g. { score: :desc, created_at: :asc }
  # @return [Integer, nil] position in ranking (1-based)
  def chart_position(attribute, start_query = nil, order: nil)
    @chart_position_cache ||= {}
    cache_key = [attribute, start_query&.object_id, order].join(":")
    return @chart_position_cache[cache_key] if @chart_position_cache.key?(cache_key)

    attribute = attribute.to_s
    unless self.class.column_names.include?(attribute)
      raise ArgumentError, "Invalid attribute for ranking: #{attribute}"
    end

    partition = partition_by(start_query || self.class.all, attribute, order)
    position = self.class.from(partition, :s).select("s.id, s.position")
      .find_by("s.id = ?", id)&.position
    @chart_position_cache[cache_key] = position
  rescue => e
    Rails.logger.warn("Chartable: #{e.message}")
    nil
  end

  private

  # Returns an ActiveRecord::Relation with a position column based on ranking
  # @param chain [ActiveRecord::Relation] base scope
  # @param attribute [String] column to rank by
  # @param order [Hash, nil] custom ordering
  # @return [ActiveRecord::Relation]
  def partition_by(chain, attribute, order = nil)
    order_sql = if order.present?
      order.map do |attr, dir|
        attr = attr.to_s
        unless self.class.column_names.include?(attr)
          raise ArgumentError, "Invalid attribute for ordering: #{attr}"
        end
        "#{self.class.connection.quote_column_name(attr)} #{dir.to_s.upcase}"
      end.join(", ")
    else
      "#{self.class.connection.quote_column_name(attribute)} DESC, created_at DESC"
    end
    chain.select(
      "id, ROW_NUMBER() OVER (ORDER BY #{order_sql}) as position"
    )
  end
end
