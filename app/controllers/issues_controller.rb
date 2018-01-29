class IssuesController < BaseApiController
  before_action :fetch_issue, only: %i[update show assign unassign change_status destory]

  attr_reader :issue

  def index
    @issues = IssuesFetcher.new(user: current_user, status: status,
                                assigned_to_me: assigned_to_me).run
  end

  def create
    if can? :create, Issue
      @issue = current_user.issues.build(issue_params)
      if issue.save
        render :show, status: :created
      else
        render json: { errors: issue.errors.full_messages }, status: 400

      end
    else
      render json: { error: 'Not enough permissions'}, status: 403
    end
  end

  def destroy
    if can? :destroy, Issue
      issue.destroy
      head :no_content
    else
      render json: { error: 'Not enough permissions'}, status: 403
    end
  end

  def update
    if can? :update, issue
      if issue.update(issue_params)
        render :show, status: 200
      else
        render json: { errors: issue.errors.full_messages }, status: 400
      end
    else
      render json: { error: 'Not enough permissions'}, status: 403
    end
  end

  def show
    if can? :read, issue
      render :show
    else
      render json: { error: 'Not enough permissions'}, status: 403
    end
  end

  def assign
    if can? :assign, issue
      if issue.update(manager_id: current_user.id)
        render :show
      else
        render json: { errors: issue.errors.full_messages }, status: 400
      end
    else
      render json: { error: 'Not enough permissions'}, status: 403
    end
  end

  def unassign
    if can? :unassign, issue
      if issue.update(manager_id: nil)
        render :show
      else
        render json: { errors: issue.errors.full_messages }, status: 400
      end
    else
      render json: { error: 'Not enough permissions'}, status: 403
    end
  end

  def change_status
    if can? :change_status, issue
      if issue.change_status(status: params.require(:issue).permit(:status)[:status])
        render :show
      else
        render json: { errors: issue.errors.full_messages }, status: 400
      end
    else
      render json: { error: 'Not enough permissions'}, status: 403
    end
  end

  private

  def fetch_issue
    @issue = Issue.find(params[:id])
  end

  def issue_params
    @issue_params ||= params.require(:issue)
                            .permit(:id, :title, :content)
  end

  def status
    status = params[:status]
    return unless status.present?
    status
  end

  def assigned_to_me
    params[:assigned_to_me]
  end
end
