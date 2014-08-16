module Pod
  class Command
    class Keys

      class Install < Keys
        self.summary = "A key value store for environment settings in Cocoa Apps."

        self.description = <<-DESC
          Longer description of cocoapods-keys.
        DESC

        def run
          require 'key_master'
          require 'keyring_liberator'

          keyring = CocoaPodsKeys::KeyringLiberator.get_keyring(Dir.getwd)
          CocoaPodsKeys::KeyMaster.new(keyring.keychain_data)

            # List all settings for current app

            # List all known bundle ids

        end
      end
    end
  end
end
