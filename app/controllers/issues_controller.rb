class IssuesController < BaseApiController
  load_and_authorize_resource

  before_action :fetch_issue,
                only: %i[update show assign unassign change_status destroy]

  attr_reader :issue

  def index
    @issues = IssuesFetcher.new(user: current_user, status: params[:status],
                                assigned_to_me: params[:assigned_to_me]).run
                                .paginate(page: params[:page])
  end

  def create
    @issue = current_user.issues.build(issue_params)
    if issue.save
      render :show, status: :created
    else
      render_validation_errors(issue)
    end
  end

  def destroy
    issue.destroy
    head :no_content
  end

  def update
    if issue.update(issue_params)
      render :show
    else
      render_validation_errors(issue)
    end
  end

  def show; end

  def assign
    if issue.update(manager_id: current_user.id)
      render :show
    else
      render_validation_errors(issue)
    end
  end

  def unassign
    if issue.update(manager_id: nil)
      render :show
    else
      render_validation_errors(issue)
    end
  end

  def change_status
    status = params.require(:issue).permit(:status)[:status]
    if issue.change_status(status: status)
      render :show
    else
      render_validation_errors(issue)
    end
  end

  private

  def fetch_issue
    @issue = Issue.find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(:title, :content)
  end
end
