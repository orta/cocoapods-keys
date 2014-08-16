module CocoaPodsKeys
  class Installer
    def install!
      require 'key_master'
      require 'keyring_liberator'

      keyring = KeyringLiberator.get_keyring(Dir.getwd)

      return unless keyring

      key_master = KeyMaster.new(keyring)

      # puts key_master.interface
      # puts key_master.implementation

        # List all settings for current app

        # List all known bundle ids

    end
  end
end
