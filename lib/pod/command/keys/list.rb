require 'keyring_liberator'

module Pod
  class Command
    class Keys
      class List < Keys
        self.summary = 'Lists all known keys and values.'

        self.description = <<-DESC
          Shows all the current keys and values for your current working directory.

          Also lists all known projects with variable stores.
        DESC

        def run
          # List all settings for current app
          this_keyring = CocoaPodsKeys::KeyringLiberator.get_keyring(Pathname.pwd)
          if this_keyring
            display_current_keyring this_keyring
          end

          # List all known bundle ids

          all_keyrings = CocoaPodsKeys::KeyringLiberator.get_all_keyrings
          all_keyrings.each do |keyring|
            display_keyring(keyring) if !this_keyring || keyring.path != this_keyring.path
          end
        end

        def display_current_keyring(keyring)
          puts "Keys for #{keyring.name}"
          data = keyring.keychain_data
          data.each_with_index do |(key, value), index|
            prefix = (index == data.length - 1) ? ' └ ' : ' ├ '
            puts prefix + " #{key} - #{ value}"
          end
          puts ''
        end

        def display_keyring(keyring)
          puts "#{keyring.name} - #{keyring.path}"
          if keyring.keys.length == 1
            puts ' └ ' + keyring.keys[0]
          else
            puts ' └ ' + keyring.keys[0...-1].join(' ') + ' & ' + keyring.keys[-1]
          end
          puts ''
        end
      end
    end
  end
end
