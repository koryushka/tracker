# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud
    if user.manager?
      can :assign, Issue do |issue|
        issue.manager.nil?
      end
      can :change_status, Issue, manager_id: user.id
      can :read, Issue
      can :unassign, Issue, manager_id: user.id
    else
      can :crud, Issue, user_id: user.id
    end
  end
end
