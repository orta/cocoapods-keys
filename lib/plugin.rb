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

    def install!

      config.podfile.pod 'Keys', :git => 'https://github.com/ashfurrow/empty-podspec.git'

      puts @podfile.to_hash["target_definitions"].map { |d| d["dependencies"] }
      original_install!
    end

    class Analyzer
      class SandboxAnalyzer

        alias_method :original_pod_state, :pod_state

        def pod_state(pod) 
          if pod == 'Keys'
            #return added if we were, otherwise assume the Keys have changed since last install.
            return :added if pod_added?(pod)
            :changed
          else
            original_pod_state(pod)
          end
        end
      end
    end
  end
end
