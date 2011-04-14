module ChefGit
  class Cookbooks
    def self.get_cookbooks(branch)
      tree = ChefGit.repository.tree(branch) / AppConfig.git.cookbooks_directory
      tree.contents.select { |b| b.is_a?(Grit::Tree) }.map(&:name)
    end

    def self.get_cookbook_file(branch, cookbook, path)
      ChefGit.repository.tree(branch)/AppConfig.git.cookbooks_directory/cookbook/path
    end
  end
end