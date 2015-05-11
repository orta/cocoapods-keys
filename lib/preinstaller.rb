module CocoaPodsKeys
  class PreInstaller
    def initialize(user_options)
      @user_options = user_options
    end

    # Returns `true` if all keys specified by the user are satisfied by either an existing keyring or environment
    # variables.
    def setup
      require 'key_master'
      require 'keyring_liberator'
      require 'pod/command/keys/set'

      options = @user_options || {}
      current_dir = Dir.getwd
      project = options.fetch('project') { CocoaPodsKeys::NameWhisperer.get_project_name }
      keyring = KeyringLiberator.get_keyring_named(project) || KeyringLiberator.get_keyring(current_dir)

      existing_keyring = !keyring.nil?
      keyring = CocoaPodsKeys::Keyring.new(project, current_dir, []) unless keyring

      data = keyring.keychain_data
      has_shown_intro = false
      keys = options.fetch("keys", [])
      keys.each do |key|
        unless ENV[key] || data.keys.include?(key)
          
          unless has_shown_intro
            puts "\n CocoaPods-Keys has detected a keys mismatch for your setup."
            has_shown_intro = true
          end
          
          puts " What is the key for " + key.green
          answer = ""
          loop do
            print " > "
            answer = STDIN.gets.chomp
            break if answer.length > 0
          end
          
          puts ""
          args = CLAide::ARGV.new([key, answer, keyring.name])
          setter = Pod::Command::Keys::Set.new(args)
          setter.run
          
        end
      end

      existing_keyring || !keys.empty?
    end
  end
end
