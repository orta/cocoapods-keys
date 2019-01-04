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
      require 'cocoapods/user_interface'
      require 'dotenv'

      ui = Pod::UserInterface

      options = @user_options || {}
      current_dir = Pathname.pwd
      Dotenv.load
      project = options.fetch('project') { CocoaPodsKeys::NameWhisperer.get_project_name }

      keyring = KeyringLiberator.get_current_keyring(project, current_dir)

      unless keyring
        check_for_multiple_keyrings(project, current_dir)
      end

      existing_keyring = !keyring.nil?
      keyring = CocoaPodsKeys::Keyring.new(project, current_dir, []) unless keyring

      has_shown_intro = false
      keys = options.fetch('keys', [])

      # Remove keys from the keyring that no longer exist
      original_keyring_keys = keyring.keys.clone
      original_keyring_keys.each do |key|
        keyring.keychain_has_key?(key)
      end

      # Add keys to the keyring that have been added,
      # and prompt for their value if needed.
      keys.each do |key|
        unless keyring.keychain_has_key?(key)
          if ci?
            raise Pod::Informative, "CocoaPods-Keys could not find a key named: #{key}"
          end

          unless has_shown_intro
            ui.puts "\n CocoaPods-Keys has detected a keys mismatch for your setup."
            has_shown_intro = true
          end

          ui.puts ' What is the key for ' + key.green
          answer = ''
          loop do
            ui.print ' > '
            answer = ui.gets.strip
            break unless answer.empty?
          end

          ui.puts
          args = CLAide::ARGV.new([key, answer, keyring.name])
          setter = Pod::Command::Keys::Set.new(args)
          setter.run
        end
      end

      existing_keyring || !keys.empty?
    end

    def check_for_multiple_keyrings(project, current_dir)
      unless ci?
        ui = Pod::UserInterface
        keyrings = KeyringLiberator.get_all_keyrings_named(project)
        if keyrings.count > 1
          ui.puts "Found multiple keyrings for project #{project.inspect}, but"
          ui.puts "no match found for current path (#{current_dir}):"
          keyrings.each do |found_keyring|
            ui.puts "- #{found_keyring.path}"
          end
          ui.puts "\nPress enter to create a new keyring, or `ctrl + c` to cancel"
          ui.gets
        end
      end
    end

    def ci?
      %w([JENKINS_HOME TRAVIS CIRCLECI CI TEAMCITY_VERSION GO_PIPELINE_NAME bamboo_buildKey GITLAB_CI XCS]).each do |current|
        return true if ENV.key?(current)
      end
      false
    end
  end
end
