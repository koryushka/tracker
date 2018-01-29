# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Issue) do
  it { should belong_to(:user) }
  it { should belong_to(:manager) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:content) }

  context 'manager_id if status `progress`' do
    it 'should not be valid' do
      issue = build(:issue, status: :progress, manager: nil)

      expect(issue).to_not be_valid
    end
  end

  context 'manager_id if status `resolved`' do
    it 'should not be valid' do
      issue = build(:issue, status: :resolved, manager: nil)

      expect(issue).to_not be_valid
    end
  end
end
