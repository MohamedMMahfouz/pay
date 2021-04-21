# frozen_string_literal: true

FactoryBot.define do
  factory :charge do
    processor_id { 'MyString' }
    owner 
    amount { 10 }
    payment_reference { 1 }
    processor { 'accept' }
  end
end
