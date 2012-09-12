# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


case Rails.env
when "production"
  a = Admin.new(email: 'admin@example.com', password: 'admin').save(:validate => false)
else
  u = User.create(username: 'user', email: 'user@example.com', password: 'password')
  u.confirm!
  p = Project.create(name: 'test')
  l = p.lists.create(name: 'Test')
  
  pr = ProjectRole.create(name: 'Admin', :project => p, :abilities => ['manage'], :users => [u])
  
  a = Admin.create(email: 'admin@example.com', password: 'password')
  
  for k in 1..20
    i = l.items.create(:users => [u], :title => "Item #{k}", :open => true, :priority => TodoItem::NORMAL)
    i.changes.create(:user => u, :description => "Seed #{k}", :status => 'created ' + i.title)
  end
end
