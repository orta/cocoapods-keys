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

      config.podfile.pod 'UIAlertView-Blocks', :git => 'https://github.com/jivadevoe/UIAlertView-Blocks.git'

      puts @podfile.to_hash["target_definitions"].map { |d| d["dependencies"] }
      original_install!
    end
  end
end
