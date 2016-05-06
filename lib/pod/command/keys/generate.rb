require 'keyring_liberator'
require 'key_master'

module Pod
  class Command
    class Keys
      class Generate < Keys
        self.summary = 'Generates the obfuscated class.'

        self.description = <<-DESC
          Generates the obfuscated Objective-C h/m files using the current key values.
        DESC

        def run
          installation_root = Pod::Config.instance.installation_root
          keys_path = installation_root.+('Pods/CocoaPodsKeys/')
      
          # List all settings for current app
          keyring = get_current_keyring
          if keyring
            
            # Create the h & m files in the same folder as the podspec
            key_master = CocoaPodsKeys::KeyMaster.new(keyring)
            interface_file = keys_path + (key_master.name + '.h')
            implementation_file = keys_path + (key_master.name + '.m')

            File.write(interface_file, key_master.interface)
            UI.puts "Generated #{interface_file}"
            
            File.write(implementation_file, key_master.implementation)
            UI.puts "Generated #{implementation_file}"
            
          end

        end

      end
    end
  end
end
