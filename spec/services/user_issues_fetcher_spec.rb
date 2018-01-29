# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserIssuesFetcher do
  describe '.run' do
    let(:user) { create(:user) }
    subject { described_class.new(user: user, status: statuses).run }
    context 'fetches users` issues' do
      let(:statuses) { nil }
      it 'fetches all user` issues' do
        issues = create_list(:issue, 3, user: user)

        expect(subject).to match_array(issues)
      end

      it 'doesn`t fetch other users` issues' do
        another_user = create(:user)
        create_list(:issue, 3, user: another_user)

        expect(subject).to match_array([])
      end

      context 'filters issues by statues' do
        let!(:pending_issue) { create(:issue, user: user) }
        let!(:progress_issue) { create(:issue, user: user, status: 1) }
        let!(:resolved_issue) { create(:issue, user: user, status: 2) }

        context 'ignoring invalid statuses' do
          context 'single status' do
            let(:statuses) { 'invalid' }
            it do
              is_expected.to match_array([pending_issue, progress_issue,
                                          resolved_issue])
            end
          end

          context 'multiple statues' do
            let(:statuses) { 'invalid,progress' }
            it { is_expected.to match_array([progress_issue]) }
          end
        end

        context 'pending issues' do
          let(:statuses) { 'pending' }
          it { is_expected.to match_array([pending_issue]) }
        end

        context 'progress issues' do
          let(:statuses) { 'progress' }
          it { is_expected.to match_array([progress_issue]) }
        end

        context 'resolved issues' do
          let(:statuses) { 'resolved' }
          it { is_expected.to match_array([resolved_issue]) }
        end

        context 'multiple statuses' do
          context 'pending and resolved' do
            let(:statuses) { 'progress,resolved' }
            it { is_expected.to match_array([progress_issue, resolved_issue]) }
          end

          context 'pending and progress' do
            let(:statuses) { 'progress,pending' }
            it { is_expected.to match_array([progress_issue, pending_issue]) }
          end

          context 'resolved and progress' do
            let(:statuses) { 'resolved,pending' }
            it { is_expected.to match_array([resolved_issue, pending_issue]) }
          end
        end
      end
    end
  end
end
