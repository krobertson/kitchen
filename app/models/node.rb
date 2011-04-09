class Node
  include Mongoid::Document

  field :name
  field :ip_address
  field :hostname

  index :name, :unique => true

end
