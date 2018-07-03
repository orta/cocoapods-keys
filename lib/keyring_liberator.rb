require 'digest'
require 'yaml'
require 'pathname'

module CocoaPodsKeys
  class KeyringLiberator
    # Gets given a gives back a Keyring for the project
    # by basically parsing it out of ~/.cocoapods/keys/"pathMD5".yml

    def self.keys_dir
      Pathname('~/.cocoapods/keys/').expand_path
    end

    def self.yaml_path_for_path(path)
      sha = Digest::MD5.hexdigest(path.to_s)
      keys_dir + (sha + '.yml')
    end

    def self.get_keyring(path)
      get_keyring_at_path(yaml_path_for_path(path))
    end

    def self.get_keyring_named(name)
      get_all_keyrings.find { |k| k.name == name }
    end

    def self.get_current_keyring(name, cwd)
      found_by_name = name && get_all_keyrings.find { |k| k.name == name && k.path == cwd.to_s }
      found_by_name || KeyringLiberator.get_keyring(cwd)
    end

    def self.get_all_keyrings_named(name)
      get_all_keyrings.find_all { |k| k.name == name }
    end

    def self.prompt_if_already_existing(keyring)
      keyrings = get_all_keyrings_named(keyring.name)
      already_exists = File.exist?(yaml_path_for_path(keyring.path))
      if !already_exists && keyrings.any? { |existing_keyring| File.exist?(yaml_path_for_path(existing_keyring.path)) }
        ui = Pod::UserInterface
        ui.puts "About to create a duplicate keyring file for project #{keyring.name.green}"
        ui.puts 'Entries in your Apple Keychain will be shared between both projects.'
        ui.puts "\nPress enter to continue, or `ctrl + c` to cancel"
        ui.gets
      end
    end

    def self.save_keyring(keyring)
      keys_dir.mkpath
      if ci?
        prompt_if_already_existing(keyring)
      end
      yaml_path_for_path(keyring.path).open('w') { |f| f.write(YAML.dump(keyring.to_hash)) }
    end

    def self.get_all_keyrings
      return [] unless keys_dir.directory?
      rings = []
      Pathname.glob(keys_dir + '*.yml').each do |path|
        rings << get_keyring_at_path(path)
      end
      rings
    end

    def self.get_keyring_at_path(path)
      Keyring.from_hash(YAML.load(path.read)) if path.file?
    end

    private_class_method :get_keyring_at_path

    def ci?
      %w([JENKINS_HOME TRAVIS CIRCLECI CI TEAMCITY_VERSION GO_PIPELINE_NAME bamboo_buildKey GITLAB_CI XCS]).each do |current|
        return true if ENV.key?(current)
      end
      false
    end
  end
end
