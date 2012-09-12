class Users::RegistrationsController < Devise::RegistrationsController
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
end
