class Repository

  def self.branches
    repo.heads.map(&:name)
  end

  def self.cookbooks(branch)
    tree = repo.tree(branch) / 'cookbooks'
    tree.contents.select { |b| b.is_a?(Grit::Tree) }.map(&:name)
  end

  def self.roles(branch)
    tree = repo.tree(branch) / 'roles'
    tree.contents.select { |b| b.is_a?(Grit::Blob) && b.name =~ /\.rb$/ }.collect { |b| b.name.gsub('.rb', '') }
  end

  def self.role(branch, role)
    filename = "#{role}.rb"
    r = Chef::Role.new
    r.instance_eval((repo.tree(branch)/'roles'/filename).data, filename, 1)
    r
  end

  def self.cookbook_file(branch, cookbook, path)
    repo.tree(branch)/'cookbooks'/cookbook/path
  end

  protected

  def self.repo
    @repo ||= Grit::Repo.new(Rails.root + "../linked-ops/.git")
  end

end
