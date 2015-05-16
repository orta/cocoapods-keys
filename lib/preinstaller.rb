module CocoaPodsKeys
  class PreInstaller
    def initialize(user_options)
      @user_options = user_options
    end

    def setup
      require 'key_master'
      require 'keyring_liberator'
      require 'pod/command/keys/set'
      require 'cocoapods/user_interface'

      ui = Pod::UserInterface

      options = @user_options || {}
      current_dir = Pathname.pwd
      project = options.fetch('project') { CocoaPodsKeys::NameWhisperer.get_project_name }
      keyring = KeyringLiberator.get_keyring_named(project) || KeyringLiberator.get_keyring(current_dir)

      keyring = CocoaPodsKeys::Keyring.new(project, current_dir, []) unless keyring

      data = keyring.keychain_data
      has_shown_intro = false
      keys = options.fetch('keys', [])
      keys.each do |key|
        unless data.keys.include? key

          unless has_shown_intro
            ui.puts "\n CocoaPods-Keys has detected a keys mismatch for your setup."
            has_shown_intro = true
          end

          ui.puts ' What is the key for ' + key.green
          answer = ''
          loop do
            ui.print ' > '
            answer = ui.gets.strip
            break if answer.length > 0
          end

          ui.puts ''
          args = CLAide::ARGV.new([key, answer, keyring.name])
          setter = Pod::Command::Keys::Set.new(args)
          setter.run

        end
      end
    end
  end
end
