require 'cocoapods-core'

module CocoaPodsKeys

  # Pod::HooksManager.register('cocoapods-keys', :post_install) do |context, user_options|
  #   require 'installer'
  #   require 'preinstaller'

  #   # PreInstaller.new(user_options).setup
  #   # Installer.new(context.sandbox_root, user_options).install!
  # end
end


module Pod
  class Installer

    include Pod::Podfile::DSL

    alias_method :original_install!, :install!
    alias_method :original_install_source_of_pod, :install_source_of_pod

    def install!
      config.podfile.pod 'Keys', :git => 'https://github.com/ashfurrow/empty-podspec.git'

      # puts @podfile.to_hash["target_definitions"].map { |d| d["dependencies"] }
      original_install!
      # abort "\'Nuff said."
    end

    def install_source_of_pod(pod_name) 
      # if pod_name == 'Keys'
      #   target = pod_targets.first { |target| target.pod_name == 'Keys' }
      #   puts "Hi, #{target.should_build?}!"
      # end

      # puts "Installing source of #{pod_name}"
      # puts "Targets: #{ pod_targets }"

      original_install_source_of_pod(pod_name)
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
        spec = original_from_string(spec_contents, path, subspec_name)

        if spec.name == 'Keys'
          # TODO: This isnt' working :\
          puts "Keys!"
          spec.attributes_hash["source_files"] = "/Users/ash/bin/eidolon/EidolonKeys.{h,m}"
        end

        spec
      end
    end
  end
end
