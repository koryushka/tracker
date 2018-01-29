# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |index| "user_#{index}@test.com" }
    name { FFaker::Name.name }
    nickname { FFaker::Name.last_name }
    password '12345678'
    role 0
  end

  trait :manager do
    role 1
  end
end
