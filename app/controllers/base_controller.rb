class BaseController < ActionController::Base
  protect_from_forgery

  layout :layout_by_resource

  def current_ability
    @current_ability ||= Ability.new(current_user, current_admin)
  end

private
  def layout_by_resource
    (devise_controller? and resource_name == :admin) ? "admin/admin" : "application"
  end
end
