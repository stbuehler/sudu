class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  def show
    @project = Project.find(params[:id], :include => :roles)
    authorize! :read, @project

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  def edit
    @project = Project.find(params[:id], :include => :roles)
    authorize! :manage, @project
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  def update
    @project = Project.find(params[:id])
    authorize! :manage, @project
    
    @project.transaction do
      @project.name = params[:project][:name]
      @project.save
  
      update_roles
      unless @project.managing_users.count > 0
        @project.errors[:base] << "No project administrator remaining"
      end
      raise ActiveRecord::Rollback unless @project.errors.empty?
    end

    respond_to do |format|
      if @project.errors.empty? then
        format.html { redirect_to edit_project_path(@project), notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => { :errors => @project.errors }, :status => :unprocessable_entity}
      end
    end
  end

  # just extends edit form to show a new role
  def new_role
    @project = Project.find(params[:project_id], :include => :roles)
    authorize! :manage, @project
    @role = @project.roles.new(:name => "New Role")

    respond_to do |format|
      format.html { render :action => "edit" }
      format.json { render json: @role }
    end
  end

  def destroy_role
    @project = Project.find(params[:project_id])
    authorize! :manage, @project

    @project.transaction do
      @project.roles.find(params[:id]).destroy

      unless @project.managing_users.count > 0
        @project.errors[:base] << "No project administrator remaining"
      end
      raise ActiveRecord::Rollback unless @project.errors.empty?
    end

    respond_to do |format|
      if @project.errors.empty?
        format.html { redirect_to edit_project_path(@project) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => { :errors => @project.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def create_list
    @project = Project.find(params[:project_id])
    authorize! :manage_list, @project
    @list = @project.lists.create(:name => params[:new_list][:name])
    
    respond_to do |format|
      if @list.valid?
        format.html { redirect_to @list, notice: 'List was successfully created.' }
        format.json { render json: @list, status: :created, location: @list }
      else
        @project.reload
        format.html { redirect_to @project, alert: 'List was not created, empty name not allowed' }
        format.json { render :json => { :errors => @list.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def create
    @project = Project.create(:name => params[:project][:name])
    @project.roles.create(:name => "Administrators", :abilities => [:manage], :users => [current_user]) if @project.valid?

    respond_to do |format|
      if @project.valid?
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: project_path(@project) }
      else
        format.html { redirect_to projects_path, alert: 'Project was not created, empty name not allowed' }
        format.json { render :json => { :errors => @project.errors }, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])
    authorize! :manage, @project
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  def leave
    @project = Project.find(params[:project_id])
    authorize! :read, @project
    wasadmin = can? :manage, @project

    success = @project.transaction do
      @project.last_managing_user
      @project.roles.each do |role|
        role.users.delete(current_user)
      end

      unless @project.managing_users.count > 0 or !wasadmin
        @project.errors[:base] << "No project administrator remaining"
      end
      raise ActiveRecord::Rollback unless @project.errors.empty?
    end

    respond_to do |format|
      if @project.errors.empty?
        format.html { redirect_to projects_url }
        format.json { head :no_content }
      else
        format.html { render :action => "show" }
        format.json { render :json => { :errors => @project.errors }, :status => :unprocessable_entity}
      end
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
      is_mrole = role.has_ability?(:manage)
      v[:had_member].keys.each do |userid|
        next if v[:still_member][userid]
        u = User.find(userid)
        if u.nil? or u.deleted_at
          @project.errors[:base] << "Userid #{userid} does not exist"
          next
        end
        next unless role.users.include?(u)
        role.users.delete(u)
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
        u = User.find_by_username(username)
        if u.nil? or u.deleted_at
          @project.errors[:base] << "Username #{username} does not exist"
          next
        end
        role.users << u unless role.users.include?(u)
      end
    end
  end
end
