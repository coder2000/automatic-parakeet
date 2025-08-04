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

    trait :with_link do
      content { "Check out this cool game at https://example.com" }
    end

    trait :duplicate_content do
      content { "This is a duplicate comment" }
    end

    trait :old do
      created_at { 1.hour.ago }
    end

    trait :recent do
      created_at { 1.minute.ago }
    end
  end
end
