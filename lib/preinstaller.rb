module CocoaPodsKeys
  class PreInstaller
    def initialize(user_options)
      @options = user_options
    end

    def setup
      require 'key_master'
      require 'keyring_liberator'
      require 'pod/command/keys/set'

      current_dir = Dir.getwd
      keyring = KeyringLiberator.get_keyring_named(@options["project"]) || KeyringLiberator.get_keyring(current_dir)
      unless keyring
        name = @options["project"] || CocoaPodsKeys::NameWhisperer.get_project_name
        keyring = CocoaPodsKeys::Keyring.new(name, current_dir, [])
      end
      
      data = keyring.keychain_data
      has_shown_intro = false
      @options["keys"].each do |key|
        unless data.keys.include? key
          
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
      
    end
  end
end
