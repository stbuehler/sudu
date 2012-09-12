class TodoItemsController < ApplicationController
  def show
    @todo_item = TodoItem.find(params[:id])
    authorize! :read, @todo_item.project

    @keep_user_default = true
    @keep_users = {}
    @add_users = {}
    @description = @todo_item.description
    @comment = ''
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @todo_item }
    end
  end

  # PUT /todo_items/1
  # PUT /todo_items/1.json
  def update
    @todo_item = TodoItem.find(params[:id])
    authorize! :comment, @todo_item.project
    
    @keep_user_default = true
    @keep_users = {}
    @add_users = {}
    @description = @todo_item.description

    p = params[:todo_item]

    p[:title] ||= ''
    p[:description] ||= ''
    p[:comment] ||= ''

    suspdate = Date.new(p['suspend_till(1i)'].to_i, p['suspend_till(2i)'].to_i, p['suspend_till(3i)'].to_i)

    changed = false
    
    @todo_item.transaction do
      change = TodoItemChanges.new(:user => current_user)
      if can? :assign, @todo_item.project
        @keep_user_default = !p[:users_old]
        p[:users_old] ||= {}
        p[:users_keep] ||= {}
        p[:users_new] ||= {}
        p[:users_old].keys.each do |userid|
          if p[:users_keep][userid]
            @keep_users[userid] = true
            next
          end
          u = User.find(userid)
          if u.nil?
            @todo_item.errors[:base] << "Userid #{userid} does not exist"
            next
          end
          next if !@todo_item.users.include?(u)
          change.status_append "Unassigned #{u.username}"
          @todo_item.users.delete(u)
        end
        p[:users_new].keys.each do |email|
          @add_users[email] = true
          u = User.find_by_email(email)
          if u.nil?
            @todo_item.errors[:base] << "User #{userid} does not exist"
            next
          end
          next if @todo_item.users.include?(u)
          change.status_append "Assigned #{u.username}"
          @todo_item.users << u
        end
      end
      if (can? :finish_all, @todo_item.project) or (can? :finish_own, @todo_item.project and @todo_item.users.include?(current_user))
        if p[:open] != p[:open_old]
          if p[:open] == "true"
            unless @todo_item.open
              change.status_append "Reopened"
              @todo_item.open = true
            end
          else
            if @todo_item.open
              change.status_append "Closed"
              @todo_item.open = false
            end
          end
        end
        
        if p[:suspend_use]
          if (p[:suspend_till_old].empty? or suspdate != Date.parse(p[:suspend_till_old])) and @todo_item.suspend_till != suspdate
            @todo_item.suspend_till = suspdate
            change.status_append "Suspended item till #{suspdate}"
          end
        else
          if !p[:suspend_till_old].empty? and @todo_item.suspend_till
            @todo_item.suspend_till = nil
            change.status_append "Removed suspension"
          end
        end
      end
      if can? :assign_priority, @todo_item.project
        if p[:priority] != p[:priority_old]
          @todo_item.priority = p[:priority]
          change.status_append "Priority changed to #{@todo_item.priority_to_s}"
        end
      end
      if @todo_item.title != p[:title] and !p[:title].empty?
        change.status_append "Changed title to '#{p[:title]}'"
        @todo_item.title = p[:title]
      end
      if @todo_item.description != p[:description] and !p[:description].empty?
        change.status_append "Description updated"
        @description = change.description = p[:description] # stored in changes for history
      end
      @comment = change.comment = p[:comment]
      changed = (!change.status.blank? or !change.comment.blank?)
      @todo_item.save! if @todo_item.errors.empty?
      @todo_item.changes << change if changed and @todo_item.errors.empty?
      raise ActiveRecord::Rollback unless @todo_item.errors.empty?
    end

    respond_to do |format|
      if @todo_item.errors.empty?
        format.html { redirect_to @todo_item, notice: changed ? 'Todo item was successfully updated.' : 'Nothing to change.' }
        format.json { head :no_content }
      else
        @todo_item.users.reload
        @todo_item.open = p[:open] == "true" if p[:open_old]
        @todo_item.priority = p[:priority] if p[:priority]
        format.html { render action: "show" }
        format.json { render json: @todo_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todo_items/1
  # DELETE /todo_items/1.json
  def destroy
    @todo_item = TodoItem.find(params[:id])
    authorize! :manage_item, @todo_item.project
    list = @todo_item.list
    @todo_item.destroy

    respond_to do |format|
      format.html { redirect_to list, notice: 'Todo Item was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
