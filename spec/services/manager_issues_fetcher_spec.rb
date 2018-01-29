# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManagerIssuesFetcher do
  describe '.run' do
    let(:manager) { create(:user, :manager) }

    subject do
      described_class.new(user: manager, status: statuses,
                          assigned_to_me: assigned_to_me).run
    end
    context 'fetches all issues' do
      let(:assigned_to_me) { false }
      let(:statuses) { nil }
      it do
        issues = create_list(:issue, 3)
        assigned_issues = create_list(:issue, 3, manager: manager)

        expect(subject).to match_array(issues + assigned_issues)
      end
    end

    context 'filters issues by assignment' do
      let(:assigned_to_me) { true }
      let(:statuses) { nil }

      let!(:issues) { create_list(:issue, 3) }
      let!(:assigned_issues) { create_list(:issue, 3, manager: manager) }

      it { is_expected.to match_array(assigned_issues) }
    end

    context 'filters issues by statues' do
      let(:assigned_to_me) { false }
      let!(:pending_issue) { create(:issue) }
      let!(:progress_issue) { create(:issue, status: 1) }
      let!(:resolved_issue) { create(:issue, status: 2) }

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
