require "keyring_liberator"
require "name_whisperer"

module Pod
  class Command
    class Keys

      class Set < Keys
        include Config::Mixin

        self.summary = "A set values for keys."

        self.description = <<-DESC
            Save a environment key to be added to your project on the next pod install.

            If a third argument is given then that will be used as the project name if
            you need to skip the project naming process.
        DESC

        self.arguments = [CLAide::Argument.new('key', true),
                          CLAide::Argument.new('value', true),
                          CLAide::Argument.new('project_name', false)]

        def initialize(argv)
          @key_name = argv.shift_argument
          @key_value = argv.shift_argument
          @project_name = argv.shift_argument
          super
        end

        def validate!
          super
          verify_podfile_exists!
          help! "A key name is required to save." unless @key_name
          help! "A value is required for the key." unless @key_value
        end

        def run
          # set a key to a folder id in ~/.cocoapods/keys
          # info "Saving into the keychain."

          keyring = current_keyring
          keyring.keys << @key_name.gsub("-", "_")
          CocoaPodsKeys::KeyringLiberator.save_keyring keyring

          keyring.save @key_name, @key_value

          puts "Saved #{@key_name} to #{keyring.name}." unless config.silent?
        end

        def current_keyring
          current_dir = Dir.getwd
          keyring = CocoaPodsKeys::KeyringLiberator.get_keyring current_dir

          unless keyring
            name = @project_name || CocoaPodsKeys::NameWhisperer.get_project_name
            keyring = CocoaPodsKeys::Keyring.new(name, current_dir, [])
          end

          keyring
        end

      end
    end
  end
end
