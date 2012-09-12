class Admin::ProjectsController < Admin::AdminController
  def index
    @projects = Project

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects.all }
    end
  end

  def show
    @project = Project.find(params[:id], :include => :roles)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  def new_role
    @project = Project.find(params[:project_id], :include => :roles)
    @role = @project.roles.new(:name => "New Role")

    respond_to do |format|
      format.html { render :action => "show" }
      format.json { render json: @role }
    end
  end

  def destroy_role
    @project = Project.find(params[:project_id])
    @project.roles.find(params[:id]).destroy

    respond_to do |format|
      format.html { redirect_to admin_project_path(@project) }
      format.json { head :no_content }
    end
  end

  def create
    @project = Project.create(:name => params[:project][:name])

    respond_to do |format|
      if @project.valid? then
        format.html { redirect_to admin_project_path(@project), notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: admin_project_path(@project) }
      else
        format.html { redirect_to admin_projects_path, alert: 'Project was not created, empty name not allowed' }
        format.json { render :json => { :errors => @project.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def update
    @project = Project.find(params[:id])

    @project.transaction do
      @project.name = params[:project][:name]
      @project.save

      update_roles
    end

    respond_to do |format|
      if @project.errors.empty? then
        format.html { redirect_to admin_project_path(@project), notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @project.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to admin_projects_url }
      format.json { head :no_content }
    end
  end

private
  def update_roles
    p = params[:project]
    p[:roles] ||= {}
    p[:roles].each do |k,v|
      if k.to_i > 0
        role = @project.roles.find(k)
      else
        role = @project.roles.create(:name => v[:name])
      end
      next if role.nil?
      v[:name] ||= ''
      v[:was_ability] ||= {}
      v[:set_ability] ||= {}
      v[:had_member] ||= {}
      v[:still_member] ||= {}
      v[:new_member] ||= {}
      v[:new_members] ||= ''
      role[:name] = v[:name] unless v[:name].empty?
      role.save
      Ability::Project_Abilities.keys.each do |a|
        if v[:was_ability][a] != (v[:set_ability][a] || 'false')
          if v[:set_ability][a]
            role.add_ability!(a)
          else
            role.remove_ability!(a)
          end
        end
      end
      v[:had_member].keys.each do |userid|
        next if v[:still_member][userid]
        u = User.find(userid)
        if u.nil? or u.deleted_at
          @project.errors[:base] << "Userid #{userid} does not exist"
          next
        end
        role.users.delete(u) if role.users.include?(u)
      end
      v[:new_member].keys.each do |userid|
        u = User.find(userid)
        if u.nil? or u.deleted_at
          @project.errors[:base] << "Userid #{userid} does not exist"
          next
        end
        role.users << u unless role.users.include?(u)
      end
      v[:new_members].split('/ +/').each do |username|
        u = User.find_first_by_auth_conditions({ login: username })
        if u.nil? or u.deleted_at
          @project.errors[:base] << "User #{username} does not exist"
          next
        end
        role.users << u unless role.users.include?(u)
      end
    end
  end
end
