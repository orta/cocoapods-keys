require "osx_keychain"

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
          
          keychain = OSXKeychain.new
          keychain["cocoapods-keys-bundle", @key_name] = @key_value

        end
      end
    end
  end
end
