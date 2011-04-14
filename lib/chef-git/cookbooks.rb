module ChefGit
  class Cookbooks
    def self.cookbooks(branch)
      tree = REPOSITORY.tree(branch) / AppConfig.git.cookbooks_directory
      tree.contents.select { |b| b.is_a?(Grit::Tree) }.map(&:name)
    end

    def self.cookbook_file(branch, cookbook, path)
      REPOSITORY.tree(branch)/AppConfig.git.cookbooks_directory/cookbook/path
    end
  end
end