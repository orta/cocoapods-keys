require "osx_keychain"
require "keyring_liberator"

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

          keychain = OSXKeychain.new
          keychain["cocoapods-keys-bundle-#{keyring.name}", @key_name] = @key_value

        end

        def current_keyring
          current_dir = Dir.getwd
          this_keyring = CocoaPodsKeys::KeyringLiberator.get_keyring current_dir

          unless this_keyring
              keyring = CocoaPodsKeys::Keyring.new("name", current_dir, [])
          end
        end

      end
    end
  end
end
