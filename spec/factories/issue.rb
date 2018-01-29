# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    association :user
    association :manager, factory: :user
    title { FFaker::Lorem.sentence }
    content { FFaker::Lorem.paragraph }
    status 0
  end
end
