# frozen_string_literal: true

class UserIssuesFetcher < BaseIssuesFetcher
  def run
    super.where(user: user)
  end
end
