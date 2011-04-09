class Environment
  include Mongoid::Document

  field :name

  index :name, :unique => true
end
