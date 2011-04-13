class Environment
  include Mongoid::Document

  field :name, :type => String

  index :name, :unique => true
end
