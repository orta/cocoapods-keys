require 'keyring_liberator'

module Pod
  class Command
    class Keys
      class Export < Keys
        self.summary = 'Exports commands to recreate the key setup.'

        self.description = <<-DESC
          Gives a list of all the pod keys commands necessary to recreate the key setup on another machine.
        DESC

        def run
          # List all settings for current app
          this_keyring = get_current_keyring
          raise 'Could not load keyring' unless this_keyring
          export_current_keyring this_keyring
        end

        def export_current_keyring(keyring)
          data = keyring.keychain_data
          data.each do |key, value|
            UI.puts "pod keys set #{key} \"#{value}\" #{keyring.name}"
          end
          UI.puts
        end
      end
    end
  end
end
