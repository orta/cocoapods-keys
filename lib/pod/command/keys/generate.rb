require 'keyring_liberator'
require 'key_master'

module Pod
  class Command
    class Keys

      class Generate < Keys
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
            this_keyring = CocoaPodsKeys::KeyringLiberator.get_keyring_named(@project_name) || CocoaPodsKeys::KeyringLiberator.get_keyring(Dir.getwd)
            if this_keyring
              key_master = CocoaPodsKeys::KeyMaster.new(this_keyring)

              interface_file = key_master.name + '.h'
              implementation_file = key_master.name + '.m'
           
              File.open(interface_file, 'w') { |f| f.write(key_master.interface) }
              File.open(implementation_file, 'w') { |f| f.write(key_master.implementation) }
            else
              abort "No keys associated with this directory or project name."
            end
        end        
      end
    end
  end
end
