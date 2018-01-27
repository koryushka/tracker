class UserIssuesFetcher < BaseIssuesFetcher

  def run
    super.where(user: user)
  end
end
