namespace :kitchen do
  desc 'Creates mongo indexes and seeds with initial data'
  task :bootstrap do
    Rake::Task['db:mongoid:create_indexes'].invoke
    puts "\n"
    Rake::Task['db:seed'].invoke
  end
end