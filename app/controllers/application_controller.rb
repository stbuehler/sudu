class ApplicationController < BaseController
  before_filter :authenticate_user!

  layout "application"
end
