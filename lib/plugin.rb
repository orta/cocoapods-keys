require 'cocoapods-core'
require 'fileutils'
require 'active_support/core_ext/hash/indifferent_access'

module CocoaPodsKeys
  class << self
    include FileUtils

    def setup
      require 'preinstaller'

      unless PreInstaller.new(user_options).setup
        raise Pod::Informative, 'Could not load key data'
      end

      installation_root = Pod::Config.instance.installation_root
      keys_path = installation_root.+('Pods/CocoaPodsKeys/')

      # move our podspec in to the Pods
      mkdir_p keys_path
      podspec_path = Pathname(__dir__) + '../templates' + 'Keys.podspec.json'
      cp podspec_path, keys_path

      # Get all the keys
      local_user_options = user_options || {}
      project = local_user_options.fetch('project') { CocoaPodsKeys::NameWhisperer.get_project_name }

      keyring = KeyringLiberator.get_keyring_named(project) ||
        KeyringLiberator.get_keyring(Dir.getwd) ||
        Keyring.new(project, Dir.getwd, local_user_options['keys'])

      raise Pod::Informative, 'Could not load keyring' unless keyring

      # Create the h & m files in the same folder as the podspec
      key_master = KeyMaster.new(keyring)
      interface_file = keys_path + (key_master.name + '.h')
      implementation_file = keys_path + (key_master.name + '.m')

      File.write(interface_file, key_master.interface)
      File.write(implementation_file, key_master.implementation)

      # Add our template podspec
      add_keys_to_pods(keys_path.relative_path_from(installation_root), user_options)
    end

    def add_keys_to_pods(keys_path, options)
      keys_targets = options['target'] || options['targets']

      if keys_targets
        # Get a list of targets, even if only one was specified
        keys_target_list = ([] << keys_targets).flatten

        # Iterate through each target specified in the Keys plugin
        keys_target_list.each do |keys_target|
          # Find a matching Pod target
          pod_target = podfile.root_target_definitions.flat_map(&:children).find do |target|
            target.label == "Pods-#{keys_target}"
          end

          if pod_target
            pod_target.store_pod 'Keys', :path => keys_path.to_path
          else
            Pod::UI.puts "Could not find a target named '#{keys_target}' in your Podfile. Stopping keys".red
          end
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
      podfile && podfile.plugins && !podfile.plugins['cocoapods-keys'].nil?
    end
  end
end
