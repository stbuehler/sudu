class Admin::UsersController < Admin::AdminController
  def index
    @users = User

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users.all }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def create
    p = params[:user]
    @user = User.new(:username => p[:username], :email => p[:email], :password => p[:password])
    @user.skip_confirmation!
    @user.save

    respond_to do |format|
      if @user.valid? and @user.errors.empty? then
        format.html { redirect_to admin_users_url, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: admin_user_path(@user) }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @user.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def update
    p = params[:user]
    @user = User.find(params[:id])
    if @user.email != p[:email]
      @user.email = p[:email]
      @user.skip_reconfirmation!
    end
    if !p[:password].blank?
      @user.password = p[:password]
    end
    @user.save

    respond_to do |format|
      if @user.errors.empty? then
        format.html { redirect_to admin_users_url, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @user.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.transaction do
      @user.projects.each do |project|
        if project.users.uniq == [@user]
          project.destroy
        else
          project.roles.each do |role|
            role.users.delete(@user)
          end
        end
      end

      @user.deleted_at = Time.now
      @user.save(:validate => false) if @user.errors.empty?
      raise ActiveRecord::Rollback unless @user.errors.empty?
    end

    respond_to do |format|
      if @user.errors.empty? then
        format.html { redirect_to admin_user_url(@user), notice: "User #{@user.username} was successfully disabled." }
        format.json { head :no_content }
      else
        @user.reload
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @user.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def restore
    @user = User.find(params[:id])
    @user.deleted_at = nil
    @user.save

    respond_to do |format|
      if @user.errors.empty? then
        format.html { redirect_to admin_user_url(@user), notice: "User #{@user.username} was successfully restored." }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @user.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def lock
    @user = User.find(params[:id])
    @user.locked = true
    @user.save

    respond_to do |format|
      if @user.errors.empty? then
        format.html { redirect_to admin_user_url(@user), notice: "User #{@user.username} was successfully locked." }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @user.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def unlock
    @user = User.find(params[:id])
    @user.locked = false
    @user.save

    respond_to do |format|
      if @user.errors.empty? then
        format.html { redirect_to admin_user_url(@user), notice: "User #{@user.username} was successfully unlocked." }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @user.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def confirm
    @user = User.find(params[:id])
    @user.skip_confirmation!
    @user.save

    respond_to do |format|
      if @user.errors.empty? then
        format.html { redirect_to admin_user_url(@user), notice: "User #{@user.username} was successfully confirmed." }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @user.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def become
    @user = User.find(params[:id])
    active = @user.active_for_authentication?
    sign_in(:user, @user, :bypass => true) if active

    respond_to do |format|
      if active
        format.html { redirect_to root_url, notice: "Logged in as user #{@user.username}" }
        format.json { head :no_content }
      else
        flash[:alert] = "Cannot become inactive user"
        format.html { render :action => "show" }
        format.json {
          @user.errors[:base] << "Cannot become inactive user"
          render :json => { :errors => @user.errors }, :status => :unprocessable_entity
        }
      end
    end
  end

  def make_admin
    @user = User.find(params[:id])
    error = nil
    if @user.active_for_authentication?
      @admin = Admin.new(email: @user.email)
      @admin.encrypted_password = @user.encrypted_password
      @admin.save(:validate => false)
      if !@admin.valid?
        error = "Administrator already exists: " + @admin.errors.to_a.join(',')
      end
    else
      error = "Cannot copy inactive user to admins"
    end

    respond_to do |format|
      unless error
        format.html { redirect_to admin_admin_url(@admin), notice: "Administrator #{@admin.email} was successfully created from user." }
        format.json { head :no_content }
      else
        flash[:alert] = error
        format.html { render :action => "show" }
        format.json {
          @user.errors[:base] << error
          render :json => { :errors => @user.errors }, :status => :unprocessable_entity
        }
      end
    end
  end
end
