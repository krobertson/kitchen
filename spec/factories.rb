Factory.define :validator_client, :class => Client do |f|
  f.name "chef-validator"
  f.validator true
end

Factory.define :admin_client, :class => Client do |f|
  f.name 'admin'
  f.admin true
end

Factory.define :client do |f|
  f.name 'test_client'
end

Factory.define :default_environment do |f|
  f.name '_default'
  f.branch 'master'
end

Factory.define :environment do |f|
  f.name 'test_environment'
end

Factory.define :node do |f|
  f.name 'test_node'
end
