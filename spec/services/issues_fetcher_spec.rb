# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IssuesFetcher do
  describe '.run' do
    subject { described_class.new(user: user)}

    context 'call appropriate service object based on user role' do
      context 'UserIssuesFetcher' do
        let(:user) { create(:user) }
        it do
          expect_any_instance_of(UserIssuesFetcher).to receive(:run)
          subject.run
        end

      end

      context 'ManagerIssuesFetcher' do
        let(:user) { create(:user, :manager) }
        it do
          expect_any_instance_of(ManagerIssuesFetcher).to receive(:run)
          subject.run
        end
      end
    end
  end
end
