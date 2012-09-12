class TodoListsController < ApplicationController
  def show
    @todo_list = TodoList.find(params[:id])
    authorize! :read, @todo_list.project 

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @todo_list }
    end
  end

  def edit
    @todo_list = TodoList.find(params[:id])
    authorize! :manage_list, @todo_list.project 
  end

  def update
    @todo_list = TodoList.find(params[:id])
    authorize! :manage_list, @todo_list.project
    @todo_list.name = params[:todo_list][:name]
    @todo_list.save 

    respond_to do |format|
      if @todo_list.errors.empty?
        format.html { redirect_to @todo_list, notice: 'Todo list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @todo_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @todo_list = TodoList.find(params[:id])
    project = @todo_list.project
    authorize! :manage_list, project 
    @todo_list.destroy

    respond_to do |format|
      format.html { redirect_to project, notice: 'Todo list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_item
    @todo_list = TodoList.find(params[:todo_list_id])
    authorize! :create, @todo_list.project 

    @todo_item = TodoItem.new(:list => @todo_list, :users => [current_user], :open => true)

    respond_to do |format|
      format.html { render }
      format.json { render json: @todo_item }
    end
  end

  def create_item
    @todo_list = TodoList.find(params[:todo_list_id])
    authorize! :create, @todo_list.project 

    prio = TodoItem::NORMAL
    prio = params[:todo_item][:priority].to_i if can? :priority, @todo_list.project and !params[:todo_item][:priority].blank? 
    @todo_item = @todo_list.items.create(:users => [current_user], :title => params[:todo_item][:title], :priority => prio, :open => true)
    if @todo_item.valid?
      @todo_item.changes.create(:user => current_user, :description => params[:todo_item][:description], :status => 'created ' + @todo_item.title)
    end

    respond_to do |format|
      if @todo_item.valid?
        format.html { redirect_to @todo_item, notice: 'Todo Item was successfully created.' }
        format.json { render json: @todo_item, status: :created, location: @todo_item }
      else
        format.html { render action: "new_item" }
        format.json { render json: @todo_list.errors, status: :unprocessable_entity }
      end
    end
  end
end
