require 'chef_ext'

module ChefGit
  class Cookbook
    def initialize(branch, cookbook)
      @branch = branch
      @cookbook = cookbook
    end

    def generate_manifest
      generate_settings
      generate_metadata
    end

    def generate_manifest_with_urls
      generate_manifest.generate_manifest_with_urls do |o|
        path = Chef::CookbookVersion.cookbook_file_for_checksum(o[:checksum])
        yield path
      end
    end

    protected

    def generate_settings
      tree = ChefGit.repository.tree(@branch) / AppConfig.git.cookbooks_directory / @cookbook
      @ignore_regexes = Array.new

      @settings = { 
          :attribute_filenames  => Hash.new,
          :definition_filenames => Hash.new,
          :recipe_filenames     => Hash.new,
          :template_filenames   => Hash.new,
          :file_filenames       => Hash.new,
          :library_filenames    => Hash.new,
          :resource_filenames   => Hash.new,
          :provider_filenames   => Hash.new,
          :root_filenames       => Hash.new,
          :metadata_filenames   => Array.new
      }

      ignore_regexes = load_ignore_file(File.join(@cookbook, "ignore"))
      @ignore_regexes.concat(ignore_regexes)

      load_files_unless_basename(
        tree, "attributes", /.rb$/, 
        @settings[:attribute_filenames]
      )
      load_files_unless_basename(
        tree, "definitions", /.rb$/, 
        @settings[:definition_filenames]
      )
      load_files_unless_basename(
        tree, "recipes", /.rb$/, 
        @settings[:recipe_filenames]
      )
      load_files_unless_basename(
        tree, "libraries", /.rb$/, 
        @settings[:library_filenames]
      )
      load_cascading_files(
        tree, "templates", /.+/,
        @settings[:template_filenames]
      )
      load_cascading_files(
        tree, "files", /.+/,
        @settings[:file_filenames]
      )
      load_cascading_files(
        tree, "resources", /.+/,
        @settings[:resource_filenames]
      )
      load_cascading_files(
        tree, "providers", /.+/,
        @settings[:provider_filenames]
      )
      load_files(
        tree, "", /.+/,
        @settings[:root_filenames]
      )
      @settings[:root_dir] = @cookbook
      if tree/'metadata.json'
        @settings[:metadata_filenames] << File.join(@cookbook, "metadata.json")
      end

      empty = @settings.inject(true) do |all_empty, files|
        all_empty && files.last.empty?
      end

      if empty
        raise "found a directory #{@cookbook} in the cookbook path, but it contains no cookbook files. skipping."
      end
    end

    def generate_metadata
      v = Chef::CookbookVersion.new(@cookbook)
      v.root_dir = @settings[:root_dir]
      v.attribute_filenames = @settings[:attribute_filenames].values
      v.definition_filenames = @settings[:definition_filenames].values
      v.recipe_filenames = @settings[:recipe_filenames].values
      v.template_filenames = @settings[:template_filenames].values
      v.file_filenames = @settings[:file_filenames].values
      v.library_filenames = @settings[:library_filenames].values
      v.resource_filenames = @settings[:resource_filenames].values
      v.provider_filenames = @settings[:provider_filenames].values
      v.root_filenames = @settings[:root_filenames].values
      v.metadata_filenames = @settings[:metadata_filenames]

      # Load the metadata file
      metadata = Chef::Cookbook::Metadata.new(v)
      @settings[:metadata_filenames].each do |meta_json|
        begin
          metadata.from_json((ChefGit.repository.tree(@branch)/AppConfig.git.cookbooks_directory/meta_json).data)
        rescue JSON::ParserError
          Chef::Log.fatal("Couldn't parse JSON in " + meta_json)
          raise
        end
      end
      v.metadata = metadata

      # Trigger the manidest to be built
      v.manifest
      v.name = @cookbook
      v.manifest['name'] = @cookbook

      v
    end

    def load_ignore_file(ignore_file)
      return Array.new
      # TODO
      results = Array.new
      if File.exists?(ignore_file) && File.readable?(ignore_file)
        IO.foreach(ignore_file) do |line|
          next if line =~ /^#/
          next if line =~ /^\w*$/
          line.chomp!
          results << Regexp.new(line)
        end
      end
      results
    end

    def remove_ignored_files_from(cookbook_settings)
      file_types_to_inspect = [ :attribute_filenames, :definition_filenames, :recipe_filenames, :template_filenames, 
                                :file_filenames, :library_filenames, :resource_filenames, :provider_filenames]

      @ignore_regexes.each do |regexes|
        regexes.each do |regex|
          file_types_to_inspect.each do |file_type|
            @settings[file_type].delete_if { |uniqname, fullpath| fullpath.match(regex) }
          end
        end
      end
    end

    def load_files(tree, path, format, result_hash, recursive=false)
      return unless tree/path
      (tree/path).contents.each do |blob|
        if blob.is_a?(Grit::Blob)
          next unless blob.name =~ format

          d = Digest::MD5.new
          d.update(blob.data)
          Chef::CookbookVersion.set_checksum("/" + File.join(@branch, @cookbook, path, blob.name), d.hexdigest)

          result_hash[blob.name] = "/" + File.join(@branch, @cookbook, path, blob.name)
        elsif blob.is_a?(Grit::Tree) && recursive
          load_files(tree, File.join(path, blob.name), format, result_hash, true)
        end
      end
    end

    def load_cascading_files(tree, path, format, result_hash)
      load_files(tree, path, format, result_hash, true)
    end

    def load_files_unless_basename(tree, path, format, result_hash)
      return unless tree/path
      (tree/path).contents.each do |file|
        next unless file.is_a?(Grit::Blob)
        next unless file.name =~ format

        d = Digest::MD5.new
        d.update(file.data)
        Chef::CookbookVersion.set_checksum("/" + File.join(@branch, @cookbook, path, file.name), d.hexdigest)

        result_hash[file.name] = "/" + File.join(@branch, @cookbook, path, file.name)
      end
    end
  end
end