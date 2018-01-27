class IssuesFetcher
  attr_reader :user, :status, :assigned_to_me

  def initialize(user:, status: nil, assigned_to_me: nil)
    self.user = user
    self.status = status
    self.assigned_to_me = assigned_to_me
  end

  delegate :role, to: :user
  delegate :run, to: :fetcher

  def fetcher
    class_name.new(user: user, status: status, assigned_to_me: assigned_to_me)
  end

  private

  attr_writer :user, :status, :assigned_to_me

  def class_name
    "#{role.capitalize}IssuesFetcher".constantize
  end
end
