require 'chef/cookbook_version'

class Chef::CookbookVersion
  def self.checksum_cookbook_file(filepath)
    @git_checksums[filepath]
  end

  def self.cookbook_file_for_checksum(checksum)
    @git_files[checksum]
  end

  def self.set_checksum(filepath, checksum)
    @git_checksums ||= {}
    @git_checksums[filepath] = checksum

    @git_files ||= {}
    @git_files[checksum] = filepath
  end
end

class RunListExpansionFromGit < Chef::RunList::RunListExpansion
  def fetch_role(name)
    Repository.role(source, name)
  end
end