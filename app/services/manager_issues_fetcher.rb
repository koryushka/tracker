# frozen_string_literal: true

class ManagerIssuesFetcher < BaseIssuesFetcher
  attr_reader :assigned_to_me

  def initialize(attributes)
    super
    self.assigned_to_me = attributes[:assigned_to_me]
  end

  def run
    return super unless only_assigned_to_me?
    super.where(manager: user)
  end

  private

  def only_assigned_to_me?
    !!assigned_to_me
  end

  attr_writer :assigned_to_me
end
