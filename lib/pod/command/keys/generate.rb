require 'keyring_liberator'
require 'key_master'

module Pod
  class Command
    class Keys
      class Generate < Keys
        include CocoaPodsKeys

        self.summary = "Generates the .h and .m files representing the keys."

        self.description = <<-DESC
          Generates the Objective-C class containing obfuscated keys for the project
          in the current working directory (if it exists). The .h and .m files are
          generated in the current working directory.
        DESC

        def initialize(argv)
          @project_name = argv.shift_argument
          super
        end

        def run
          key_master = KeyMaster.new(@keyring)

          interface_file = key_master.name + '.h'
          implementation_file = key_master.name + '.m'
       
          File.write(interface_file, key_master.interface)
          File.write(implementation_file, key_master.implementation)
        end

        def validate!
          super
          verify_podfile_exists!

          @keyring = KeyringLiberator.get_keyring_named(@project_name) || KeyringLiberator.get_keyring(Dir.getwd)
          help! "No keys associated with this directory or project name." unless @keyring
        end
      end
    end
  end
end
