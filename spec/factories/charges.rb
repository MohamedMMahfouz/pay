# frozen_string_literal: true

FactoryBot.define do
  factory :charge, class: Pay::Charge do
    amount { 10 }
    sequence(:payment_reference) { |n| n }
    processor { 'accept' }
    sequence(:processor_id) { |n| SecureRandom.random_number(10**7) + n }
    owner_id { create(:user).id }
    owner_type { 'User' }

    trait :reflected do
      status { :reflected }
    end
  end
end
