# frozen_string_literal: true

class BaseApiController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |_exception|
    render json: { error: I18n.t('errors.permissions.not_enough') }, status: 403
  end

  def render_validation_errors(obj)
    render json: { errors: obj.errors.full_messages }, status: 422
  end
end
