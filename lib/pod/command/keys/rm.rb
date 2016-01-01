require 'keyring_liberator'
require 'keyring'
require 'name_whisperer'
require 'shellwords'

module Pod
  class Command
    class Keys
      class Rm < Keys
        self.summary = 'Removes key-value pairs from a project.'

        self.description = <<-DESC
            Removes a key, and it's value from a project.

            If Wildcards are included, it will remove the keys matching the pattern.
            E.g.: `pod keys rm \"G*og*\"` will remove *all* the keys that begin
            with 'G', have 'og' in the middle and end with anything.

            To nuke all the keys, run either `pod keys rm "*"` or `pod keys rm --all`

            A second optional operator can be done to force a project name.
        DESC

        self.arguments = [CLAide::Argument.new('key', true), CLAide::Argument.new('project_name', false)]

        def self.options
          [[
            '--all', 'Remove all the stored keys without asking'
          ]].concat(super)
        end

        def initialize(argv)
          @key_name = argv.shift_argument
          @project_name = argv.shift_argument
          @wipe_all = argv.flag?('all')
          super
        end

        def validate!
          super
          verify_podfile_exists!
          help! 'A key name is required for lookup.' unless @key_name || @wipe_all
        end

        def run
          keyring = get_current_keyring
          unless keyring
            raise Informative, 'Could not find a project to remove the key from.'
          end

          if @wipe_all
            @key_name = '*'
          end

          matching_keys = matches(keyring.keys)
          if matching_keys.count > 0
            messages = matching_keys.map { |e| delete_key(e, keyring) }
            raise Informative, messages.join("\n")
          else
            raise Informative, "Could not find key that matched \"#{@key_name}\"."
          end
        end

        def delete_key(key, keyring)
          keyring.save(key, '')
          keyring.keys.delete key
          CocoaPodsKeys::KeyringLiberator.save_keyring(keyring)

          prefix = CocoaPodsKeys::Keyring.keychain_prefix
          login = prefix + keyring.name
          delete_generic = `security delete-generic-password -a #{key.shellescape} -l #{login.shellescape} 2>&1`

          if delete_generic.include? 'security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain.'
            return "Removed value for #{key}, but could not delete from Keychain."
          elsif delete_generic.include? 'password has been deleted.'
            return "Removed value for #{key}, and deleted associated key in Keychain."
          else
            return "Removed value for #{key}."
          end
        end

        def matches(keys)
          if @key_name.include? '*'
            return keys.select { |e| e =~ create_regex(@key_name) }
          else
            return keys.select { |e| e == @key_name }
          end
        end

        def create_regex(pattern)
          regex_str = "^#{pattern.gsub('*', '.*')}$"
          Regexp.new(regex_str)
        end
      end
    end
  end
end
