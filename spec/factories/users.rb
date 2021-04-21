# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'factory Name F' }
    last_name { 'factory Name L' }
    email { "user_#{SecureRandom.hex}@example.com" }
  end
end
