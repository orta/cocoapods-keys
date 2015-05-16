require 'cocoapods-core'
require 'fileutils'
require 'active_support/core_ext/hash/indifferent_access'

module CocoaPodsKeys
  class << self
    include FileUtils

    def setup
      require 'preinstaller'

      PreInstaller.new(user_options).setup

      keys_path = Pod::Config.instance.installation_root + 'Pods/CocoaPodsKeys/'

      # move our podspec in to the Pods
      mkdir_p keys_path
      podspec_path = Pathname(__dir__) + '../templates' + 'Keys.podspec.json'
      cp podspec_path, keys_path

      # Get all the keys
      local_user_options = user_options || {}
      project = local_user_options.fetch('project') { CocoaPodsKeys::NameWhisperer.get_project_name }
      keyring = KeyringLiberator.get_keyring_named(project) || KeyringLiberator.get_keyring(Pathname.pwd)
      raise Pod::Informative, 'Could not load keyring' unless keyring

      # Create the h & m files in the same folder as the podspec
      key_master = KeyMaster.new(keyring)
      interface_file = keys_path + (key_master.name + '.h')
      implementation_file = keys_path + (key_master.name + '.m')

      File.write(interface_file, key_master.interface)
      File.write(implementation_file, key_master.implementation)

      # Add our template podspec
      if user_options['target']
        # Support correct scoping for a target
        target = podfile.root_target_definitions.flat_map(&:children).find do |target|
          target.label == 'Pods-' + user_options['target'].to_s
        end

        if target
          target.store_pod 'Keys', :path => keys_path.to_path
        else
          puts "Could not find a target named '#{user_options['target']}' in your Podfile. Stopping Keys.".red
        end

      else
        # otherwise let it go in global
        podfile.pod 'Keys', :path => keys_path.to_path
      end
    end

    private

    def podfile
      Pod::Config.instance.podfile
    end

    def user_options
      options = podfile.plugins['cocoapods-keys']
      # Until CocoaPods provides a HashWithIndifferentAccess, normalize the hash keys here.
      # See https://github.com/CocoaPods/CocoaPods/issues/3354
      options.with_indifferent_access
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
      !Pod::Config.instance.podfile.plugins['cocoapods-keys'].nil?
    end
  end
end
