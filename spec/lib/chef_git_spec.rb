require 'spec_helper'

describe ChefGit do
  it 'should return branches' do
    ChefGit.branches.should == ['master', 'refactor', 'sample']
  end
end

describe ChefGit::Cookbooks do
  it 'should return a list of cookbooks per branch' do
    ChefGit::Cookbooks.get_cookbooks('master').should == ['git', 'logrotate', 'nginx', 'packages']
    ChefGit::Cookbooks.get_cookbooks('refactor').should == ['git', 'god', 'nginx', 'packages']
  end

  it 'should return a file from within a cookbook' do
    ChefGit::Cookbooks.get_cookbook_file('master', 'git', 'README.rdoc').data.should == File.read(Rails.root.join('spec/git-repo/cookbooks/git/README.rdoc'))
  end
end

describe ChefGit::Roles do
  it 'should return a list of roles per branch' do
    ChefGit::Roles.all('master').should == ['base']
    ChefGit::Roles.all('refactor').should == ['another', 'base']
  end

  it 'should return a Chef::Role for a given role' do
    role = ChefGit::Roles.role('refactor', 'another')
    role.should be_a Chef::Role
    role.name.should == 'another'
    role.default_attributes[:packages].should == ['imagemagick']
  end
end

describe ChefGit::Cookbook do
  it 'should generate a manifest for the cookbook' do
    cookbook = ChefGit::Cookbook.new('refactor', 'god')
    manifest = cookbook.generate_manifest

    manifest.name.should == 'god'
    manifest.version.should == '0.7.0'
    manifest.definition_filenames.should == ["/refactor/god/definitions/god_monitor.rb"]
    manifest.recipe_filenames.should == ["/refactor/god/recipes/default.rb"]
    manifest.metadata.name.should == 'god'
    manifest.metadata.version.should == '0.7.0'
    manifest.metadata.dependencies.should == {"runit"=>[], "ruby"=>[]}
    manifest.metadata.platforms.should == {"debian"=>[], "ubuntu"=>[]}
    manifest.metadata.maintainer_email.should == 'cookbooks@opscode.com'
  end
end
