require "digest"
require "yaml"
require "pathname"

module CocoaPodsKeys
    class KeyringLiberator

      # Gets given a gives back a Keyring for the project
      # by basically parsing it out of ~/.cocoapods/keys/"pathMD5".yml

      def self.keys_dir
         Pathname.new("~/.cocoapods/keys/").expand_path.to_s
      end

      def self.yaml_path_for_path(path)
        sha = Digest::MD5.hexdigest(path)
        File.join(keys_dir, sha + '.yml')
      end

      def self.get_keyring(path)
        get_keyring_at_path(yaml_path_for_path(path))
      end

      def self.save_keyring(keyring)
        `mkdir -p #{keys_dir}`

        File.open(yaml_path_for_path(keyring.path), 'w') {|f| f.write(YAML::dump(keyring.to_hash)) }
      end

      def self.get_all_keyrings()
        return [] unless Dir.exist? keys_dir
        rings = []
        Dir.glob(keys_dir + "/*.yml").each do |path|
          rings << get_keyring_at_path(path)
        end
        rings
      end

      private

      def self.get_keyring_at_path(path)
        Keyring.from_hash(YAML.load(File.read(path))) if File.exist?(path)
      end

    end
end
