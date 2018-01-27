class IssuesController < BaseApiController

  def index
    @issues = IssuesFetcher.new(user: current_user, status: status,
                                assigned_to_me: assigned_to_me).run
  end

  private

  def status
    status = params[:status]
    return unless status.present?
    status
  end

  def assigned_to_me
    params[:assigned_to_me]
  end
end
