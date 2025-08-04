FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.paragraph(sentence_count: 3) }
    association :user
    association :game
    parent { nil }

    trait :reply do
      association :parent, factory: :comment
    end

    trait :long_content do
      content { Faker::Lorem.paragraph(sentence_count: 20) }
    end

    trait :short_content do
      content { "Hi!" }
    end
  end
end
