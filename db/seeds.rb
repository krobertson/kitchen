puts "Seeding database"
puts "-------------------------------"

# Create an inital chef-validator client
validator_name = "chef-validator"
validator_client = Client.where(:name => validator_name).first || Client.new(:name => validator_name)
validator_client.validator = true
validator_client.create_keys
validator_client.save!
puts 
puts "Creating chef-validator client:"
puts "-- name:        #{validator_name}"
puts "-- private_key:"
puts
puts validator_client.private_key
puts 
puts "Be sure to save the private key!"

# Create _default environment
puts
puts "Creating _default environment..."
default_environment = Environment.create(:name => '_default', :branch => 'master')
