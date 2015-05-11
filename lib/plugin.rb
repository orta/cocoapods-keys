require 'cocoapods-core'

module CocoaPodsKeys
  class << self

    def setup
      require 'preinstaller'

      unless PreInstaller.new(user_options).setup
        raise Pod::Informative, "Could not load key data"
      end

      # move our podspec in to the Pods
      `mkdir Pods/CocoaPodsKeys` unless Dir.exists? "Pods/CocoaPodsKeys"
      podspec_path = File.join(__dir__, "../templates", "Keys.podspec.json")
      `cp "#{podspec_path}" Pods/CocoaPodsKeys`

      # Get all the keys
      local_user_options = user_options || {}
      project = local_user_options.fetch("project") { CocoaPodsKeys::NameWhisperer.get_project_name }
      keyring = KeyringLiberator.get_keyring_named(project) ||
                KeyringLiberator.get_keyring(Dir.getwd) ||
                Keyring.new(project, Dir.getwd, local_user_options['keys'])

      # Create the h & m files in the same folder as the podspec
      key_master = KeyMaster.new(keyring)
      interface_file = File.join("Pods/CocoaPodsKeys", key_master.name + '.h')
      implementation_file = File.join("Pods/CocoaPodsKeys", key_master.name + '.m')

      File.write(interface_file, key_master.interface)
      File.write(implementation_file, key_master.implementation)
      
      # Add our template podspec
      if user_options["target"]
        # Support correct scoping for a target
        target = podfile.root_target_definitions.map(&:children).flatten.find do |target|
          target.label == "Pods-" + user_options["target"].to_s
        end
              
        if target
          target.store_pod 'Keys', :path => 'Pods/CocoaPodsKeys/'
        else
          puts "Could not find a target named '#{user_options["target"]}' in your Podfile. Stopping Keys.".red
        end

      else
        # otherwise let it go in global
        podfile.pod 'Keys', :path => 'Pods/CocoaPodsKeys/'
      end
    end

    private

    def podfile
      Pod::Config.instance.podfile
    end

    def user_options
      options = podfile.plugins["cocoapods-keys"]
      # Until CocoaPods provides a HashWithIndifferentAccess, normalize the hash keys here.
      # See https://github.com/CocoaPods/CocoaPods/issues/3354
      options.inject({}) do |normalized_hash, (key, value)|
        normalized_hash[key.to_s] = value
        normalized_hash
      end
    end
  end
end

module Pod
  class Installer
    alias_method :install_before_cocoapods_keys!, :install!

    def install!
      CocoaPodsKeys.setup if validates_for_keys
      install_before_cocoapods_keys!
    end

    def validates_for_keys
      Pod::Config.instance.podfile.plugins["cocoapods-keys"] != nil
    end
  end
end
