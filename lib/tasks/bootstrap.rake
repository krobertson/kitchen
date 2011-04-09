task :create_validation => :environment do
  client = Client.create({ :name => 'valida' })
  client.create_keys
  client.save

  puts "\nKEY:\n\n#{client.private_key}\n\n"


  environment = Environment.create(:name => '_default', :branch => 'master')
end