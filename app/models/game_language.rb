# == Schema Information
#
# Table name: game_languages
#
#  id            :bigint           not null, primary key
#  language_code :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  game_id       :bigint           not null
#
# Indexes
#
#  index_game_languages_on_game_id                    (game_id)
#  index_game_languages_on_game_id_and_language_code  (game_id,language_code) UNIQUE
#  index_game_languages_on_language_code              (language_code)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
class GameLanguage < ApplicationRecord
  belongs_to :game

  validates :language_code, presence: true
  validates :language_code, uniqueness: {scope: :game_id}
  validates :language_code, inclusion: {in: proc { I18n.available_locales.map(&:to_s) }}

  def language_name
    I18n.t("languages.#{language_code}", locale: I18n.locale, default: language_code.upcase)
  end
end
