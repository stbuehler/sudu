class Ability
  include CanCan::Ability

  Project_Abilities = {
    # project admin
    :manage => "Project Admin",
    # manage lists of a project: create, delete
    :manage_list => "Project Manager",
    # move items (also cross project if allowed for both projects)
    :move => "Move Items",
    # manage items: change all data of an item
    :manage_item => "Manage Items",
    # assign users to an item
    :assign => "Assign Items",
    # close any item
    :finish_all => "Close All Items",
    # close assigned items
    :finish_own => "Close Own Items",
    # assign priority
    :assign_priority => "Assign Priority",
    # create new items
    :create => "Create Items",
    # add comments to items
    :comment => "Comment Items",
    # basic read access - always included for now if you are member of any role for a project
    #  :read => "Read",
  }

  def initialize(user, admin)
    unless user.nil?
      user.project_roles.find_each do |role|
        pid = role.project.id

        # default read access
        can :read, Project, :id => pid

        a = role.abilities
        a = (a + [:move]).uniq if role.has_ability? :manage_list
        a = (a + [:assign, :finish_all, :finish_own, :create, :comment]).uniq if role.has_ability? :manage_item

        can a, Project, :id => pid
      end
    end

    unless admin.nil?
    end
  end

  def self.stringify(a)
    Project_Abilities[a.to_sym]
  end
end
