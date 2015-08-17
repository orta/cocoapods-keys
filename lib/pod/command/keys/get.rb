require 'keyring_liberator'
require 'name_whisperer'

module Pod
  class Command
    class Keys
      class Get < Keys
        self.summary = 'Print a values of a key.'

        self.description = <<-DESC
            Outputs the value of a key to SDTOUT

            A second optional operator can be done to force a project name.
        DESC

        self.arguments = [CLAide::Argument.new('key', true),
                          CLAide::Argument.new('project_name', false)]

        def initialize(argv)
          @key_name = argv.shift_argument
          @project_name = argv.shift_argument
          super
        end

        def validate!
          super
          verify_podfile_exists!
          help! 'A key name is required for lookup.' unless @key_name
        end

        def run
          keyring = get_current_keyring
          unless keyring
            raise Informative, 'Could not find a project for this folder'
          end

          if keyring.keys.include? @key_name
            data = keyring.keychain_value(@key_name)
            UI.puts data
          else
            raise Informative, 'Could not find value'
          end
        end
      end
    end
  end
end
