module ChefGit
  def self.REPOSITORY
    @repo ||= Grit::Repo.new(File.expand_path(AppConfig.git.repository_path))
  end

  def self.branches
    REPOSITORY.heads.map(&:name)
  end
end
