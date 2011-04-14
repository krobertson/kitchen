module ChefGit
  class Roles
    def self.all(branch)
      tree = ChefGit.repository.tree(branch) / AppConfig.git.roles_directory
      tree.contents.select { |b| b.is_a?(Grit::Blob) && b.name =~ /\.rb$/ }.collect { |b| b.name.gsub('.rb', '') }
    end

    def self.role(branch, role)
      filename = "#{role}.rb"
      role = Chef::Role.new
      role.instance_eval((ChefGit.repository.tree(branch)/AppConfig.git.roles_directory/filename).data, filename, 1)
      role
    end
  end
end