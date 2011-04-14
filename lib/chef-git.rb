module ChefGit
  def self.repository
    @repo ||= Grit::Repo.new(File.expand_path(AppConfig.repository_path))
  end

  def self.branches
    repository.heads.map(&:name)
  end
end
