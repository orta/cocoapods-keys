require "keyring_liberator"
require "name_whisperer"

module Pod
  class Command
    class Keys

      class Set < Keys
        self.summary = "A key value store for environment settings in Cocoa Apps."

        self.description = <<-DESC
          Longer description of cocoapods-keys.
        DESC

        self.arguments = ["key_name", "key_value"]

        def initialize(argv)
          @key_name = argv.shift_argument
          @key_value = argv.shift_argument

          super
        end

        def validate!
          super
          help! "A key name is required to save." unless @key_name
          help! "A value is required for the key." unless @key_value
        end

        def run
          # set a key to a folder id in ~/.cocoapods/keys
          # info "Saving into the keychain."

          keyring = current_keyring
          keyring.keys << @key_name
          CocoaPodsKeys::KeyringLiberator.save_keyring keyring

          keyring.save @key_name, @key_value

          puts "Saved #{@key_name} to #{keyring.name}."
        end

        def current_keyring
          current_dir = Dir.getwd
          keyring = CocoaPodsKeys::KeyringLiberator.get_keyring current_dir

          unless keyring
            name = CocoaPodsKeys::NameWhisperer.get_project_name
            keyring = CocoaPodsKeys::Keyring.new(name, current_dir, [])
          end

          keyring
        end

      end
    end
  end
end
