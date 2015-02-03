require 'cocoapods-core'
require 'keyring_liberator'
require 'key_master'

module CocoaPodsKeys

end

module Pod
  class Installer
    include Pod::Podfile::DSL

    alias_method :original_install!, :install!

    def install!
      require 'preinstaller'
      user_options = config.podfile.plugins["cocoapods-keys"]
      CocoaPodsKeys::PreInstaller.new(user_options).setup

      # Add our template podspec (needs to be remote, not local). 
      config.podfile.pod 'Keys', :git => 'https://github.com/ashfurrow/empty-podspec.git', :commit => 'e6588faecb89632f2616251746a313a2ad6336fa'

      original_install!
    end

    class Analyzer
      class SandboxAnalyzer

        alias_method :original_pod_state, :pod_state

        def pod_state(pod) 
          if pod == 'Keys'
            # return :added if we were, otherwise assume the Keys have :changed since last install, following my mother's "Better Safe than Sorry" principle.
            return :added if pod_added?(pod)
            :changed
          else
            original_pod_state(pod)
          end
        end
      end
    end
  end

  class Specification
    class << self 

      include Pod::Podfile::DSL

      alias_method :original_from_string, :from_string

      def from_string(spec_contents, path, subspec_name = nil)
        if path.to_s.include? "Keys.podspec"
          user_options = Pod::Config.instance.podfile.plugins["cocoapods-keys"]

          keyring = CocoaPodsKeys::KeyringLiberator.get_keyring_named(user_options["project"]) || CocoaPodsKeys::KeyringLiberator.get_keyring(Dir.getwd)
          abort "Could not load keyring" unless keyring 

          key_master = CocoaPodsKeys::KeyMaster.new(keyring)

          spec_contents.gsub!(/%%SOURCE_FILES%%/, "#{key_master.name}.{h,m}")
          spec_contents.gsub!(/%%PROJECT_NAME%%/, user_options["project"])
        end
        
        original_from_string(spec_contents, path, subspec_name)
      end
    end
  end
end
