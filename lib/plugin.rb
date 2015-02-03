require 'cocoapods-core'

module CocoaPodsKeys
  include Pod::Config::Mixin

  def podfile_for_current_project
    config.podfile
  end
end

module Pod
  class Installer
    include CocoaPodsKeys

    alias_method :install_before_cocoapods_keys!, :install!

    def install!
      require 'preinstaller'

      podfile = podfile_for_current_project()
      user_options = podfile.plugins["cocoapods-keys"]
      PreInstaller.new(user_options).setup

      # Add our template podspec (needs to be remote, not local). 
      podfile.pod 'Keys', :git => 'https://github.com/ashfurrow/empty-podspec.git'

      install_before_cocoapods_keys!
    end

    class Analyzer
      class SandboxAnalyzer

        alias_method :pod_state_before_cocoapods_keys, :pod_state

        def pod_state(pod) 
          if pod == 'Keys'
            # return :added if we were, otherwise assume the Keys have :changed since last install, following my mother's "Better Safe than Sorry" principle.
            return :added if pod_added?(pod)
            :changed
          else
            pod_state_before_cocoapods_keys(pod)
          end
        end
      end
    end
  end

  class Specification
    class << self 
      include CocoaPodsKeys

      alias_method :from_string_before_cocoapods_keys, :from_string

      def from_string(spec_contents, path, subspec_name = nil)
        if path.to_s.include? "Keys.podspec"
          user_options = podfile_for_current_project.plugins["cocoapods-keys"]

          keyring = KeyringLiberator.get_keyring_named(user_options["project"]) || KeyringLiberator.get_keyring(Dir.getwd)
          abort "Could not load keyring" unless keyring 

          key_master = KeyMaster.new(keyring)

          spec_contents.gsub!(/%%SOURCE_FILES%%/, "#{key_master.name}.{h,m}")
          spec_contents.gsub!(/%%PROJECT_NAME%%/, user_options["project"])
        end
        
        from_string_before_cocoapods_keys(spec_contents, path, subspec_name)
      end
    end
  end
end
