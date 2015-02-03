require 'cocoapods-core'

module CocoaPodsKeys
end

module Pod
  class Installer

    include Pod::Podfile::DSL

    alias_method :original_install!, :install!
    alias_method :original_install_source_of_pod, :install_source_of_pod

    def install!
      require 'preinstaller'
      user_options = config.podfile.plugins["cocoapods-keys"]
      CocoaPodsKeys::PreInstaller.new(user_options).setup

      # Add our template podspec (needs to be remote, not local). 
      config.podfile.pod 'Keys', :git => 'https://github.com/ashfurrow/empty-podspec.git'

      original_install!
    end

    class Analyzer
      class SandboxAnalyzer

        alias_method :original_pod_state, :pod_state

        def pod_state(pod) 
          if pod == 'Keys'
            # return :added if we were, otherwise assume the Keys have :changed since last install following my mother's "Better Safe than Sorry" principle.
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

      alias_method :original_from_string, :from_string

      def from_string(spec_contents, path, subspec_name = nil)
        if path.to_s.include? "Keys.podspec"
          puts "Hi there, #{path}"

          # TODO: Replace %%SOURCE_FILES%% and %%PREPARE_COMMAND%% with the actual files/commands.
          # spec_contents.gsub!()
        end
        
        original_from_string(spec_contents, path, subspec_name)
      end
    end
  end
end
