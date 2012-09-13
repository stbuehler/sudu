class BaseController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end

  layout :layout_by_resource

  def current_ability
    @current_ability ||= Ability.new(current_user, current_admin)
  end

private
  def layout_by_resource
    (devise_controller? and resource_name == :admin) ? "admin/admin" : "application"
  end
end
