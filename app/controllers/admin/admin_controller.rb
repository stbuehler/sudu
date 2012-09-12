class Admin::AdminController < BaseController
  layout "admin/admin"
  before_filter :authenticate_admin!
end
