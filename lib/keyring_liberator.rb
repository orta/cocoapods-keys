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

    def self.save_keyring(keyring)
      keys_dir.mkpath

      existing = get_keyring_named(keyring.name)
      if existing && yaml_path_for_path(existing.path) != yaml_path_for_path(keyring.path)
        ui = Pod::UserInterface
        ui.puts "About to create a duplicate keyring file for project #{keyring.name.green}"
        ui.puts "\nPress enter to continue, or `ctrl + c` to cancel"
        ui.gets
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

    private

    def self.get_keyring_at_path(path)
      Keyring.from_hash(YAML.load(path.read)) if path.file?
    end
  end
end
