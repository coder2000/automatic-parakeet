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
FactoryBot.define do
  factory :game_language do
    association :game
    language_code { "en" }
  end
end
