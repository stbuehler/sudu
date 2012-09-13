class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :reset_feed_token]

  ALLOWED_FIELDS = {
    :email => true,
    :password => true,
    :password_confirmation => true,
    :current_password => true,
  }

  def new
    raise CanCan::AccessDenied.new("Not authorized!") unless Sudu::Application.config.allow_registration
    super
  end

  def create
    raise CanCan::AccessDenied.new("Not authorized!") unless Sudu::Application.config.allow_registration
    resource_params.select! { |key,v| key.to_sym == :username || ALLOWED_FIELDS[key.to_sym] }
    super
  end

  def update
    resource_params.select! { |key,v| ALLOWED_FIELDS[key.to_sym] }
    super
  end

  def destroy
    resource.deleted_at = Time.now
    if resource.save
      set_flash_message :notice, :destroyed
      sign_out_and_redirect(self.resource)
    else
      respond_to do |format|
        resource.errors.clear
        set_flash_message :alert, :has_projects
        format.html { render action: "edit" }
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  def reset_feed_token
    current_user.reset_feed_authentication_token
    respond_to do |format|
      if current_user.save
        format.html { redirect_to edit_user_registration_path, notice: 'Reset feed token successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_user_registration_path, alert: current_user.errors.to_a.join(', ') }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end
end
