require 'chef/certificate'

class Client
  include Mongoid::Document

  field :name
  field :admin
  field :public_key

  index :name, :unique => true

  def create_keys
    results = Chef::Certificate.gen_keypair(self.name)
    self.public_key = results[0].to_s.chomp
    self.private_key = results[1].to_s.chomp
    true
  end

  attr_accessor :private_key
end