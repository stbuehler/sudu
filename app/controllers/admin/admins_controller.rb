class Admin::AdminsController < Admin::AdminController
  def index
    @admins = Admin

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admins.all }
    end
  end

  def show
    @admin = Admin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin }
    end
  end

  def create
    p = params[:admin]
    @admin = Admin.create(:email => p[:email], :password => p[:password])

    respond_to do |format|
      if @admin.valid? then
        format.html { redirect_to admin_admins_url, notice: 'Admin was successfully created.' }
        format.json { render json: @admin, status: :created, location: admin_admin_path(@admin) }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @admin.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def update
    p = params[:admin]
    @admin = Admin.find(params[:id])
    @admin.email = p[:email]
    if !p[:password].blank? || !p[:password_confirmation].blank?
      if p[:password] != p[:password_confirmation]
        @admin.errors[:password_confirmation] << "doesn't match password"
      else
        @admin.password = p[:password]
      end
    end
    @admin.save if @admin.errors.empty?

    respond_to do |format|
      if @admin.errors.empty? then
        format.html { redirect_to admin_admins_url, notice: 'Admin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @admin.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @admin = Admin.find(params[:id])
    lastadmin = false
    @admin.transaction do
      if Admin.count == 1
        lastadmin = true
      else
        @admin.destroy
      end
    end

    respond_to do |format|
      unless lastadmin
        format.html { redirect_to admin_admins_url }
        format.json { head :no_content }
      else
        format.html { redirect_to admin_admins_url, :alert => "Can't delete last administrator account" }
        format.json { head :json => { :errors => ["Can't delete last administrator account"] }, :status => :unprocessable_entity }
      end
    end
  end
end
