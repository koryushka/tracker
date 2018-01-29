# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :issues do
    member do
      patch :assign, to: 'issues#assign'
      patch :unassign, to: 'issues#unassign'
      patch :change_status, to: 'issues#change_status'
    end
  end
end
