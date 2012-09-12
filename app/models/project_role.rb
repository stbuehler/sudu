class ProjectRole < ActiveRecord::Base
  class AbilitiesAttributeCoder
    def self.load(str)
      str.to_s.split(/:/).reject(&:empty?).map(&:to_sym)
    end
    
    def self.dump(value)
      ':' + value.map(&:to_s).join(':') + ':'
    end
  end

  belongs_to :project
  serialize :abilities, ::ProjectRole::AbilitiesAttributeCoder
  has_and_belongs_to_many :users

  attr_accessible :name, :project, :abilities, :users

  def abilities=(a)
    write_attribute :abilities, (a || []).map(&:to_sym).sort.uniq
  end
  
  def add_ability!(*as)
    as.map!(&:to_sym)
    as.reject! { |a| !Ability::Project_Abilities.include?(a) }
    write_attribute :abilities, ((abilities || []) + as).sort.uniq
    save!
  end
  
  def remove_ability!(*as)
    as.map!(&:to_sym)
    write_attribute :abilities, (abilities || []).reject{|a| as.include?(a) }
    save!
  end
  
  def has_ability?(a)
    (abilities || []).include?(a.to_sym)
  end
  
  def each_ability_value
    Ability::Project_Abilities.each do |k,v|
      yield k, abilities.include?(k)
    end
  end 
end
