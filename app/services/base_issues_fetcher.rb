class BaseIssuesFetcher
  attr_reader :user, :statuses

  def initialize(attributes)
    self.user = attributes[:user]
    self.statuses = fetch_status(attributes[:status])
  end

  def run
    issues
  end

  private

  attr_writer :user, :statuses

  def issues
    return Issue.all if statuses.empty?
    Issue.where(conditions, *args)
  end

  def conditions
    actual_statuses
      .inject([]) { |arr, _el| arr << 'status = (?)' }
      .join(' OR ')
  end

  def args
    actual_statuses.each_with_object([]) do |status, ary|
      ary << Issue.statuses[status]
    end
  end

  def possible_statuses
    Issue.statuses.keys.map(&:to_sym)
  end

  def actual_statuses
    @actual_statuses ||= statuses.select do |el|
      possible_statuses.include?(el.try(:to_sym))
    end
  end

  def fetch_status(status)
    return [] unless status.present?
    status.split(',')
  end

end
