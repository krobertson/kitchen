class Environment
  include Mongoid::Document

  field :name, :type => String
  field :properties, :type => Hash, :default => {}

  validates_uniqueness_of :name

  index :name, :unique => true
end
