module CocoaPodsKeys

  Pod::HooksManager.register('cocoapods-keys', :post_install) do |context, user_options|
    require 'installer'
    require 'preinstaller'

    PreInstaller.new(user_options).setup
    Installer.new(context.sandbox_root, user_options).install!
  end
end
