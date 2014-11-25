module CocoaPodsKeys

  Pod::HooksManager.register('cocoapods-keys', :post_install) do |options|
    require 'installer'

    Installer.new(options.sandbox_root).install!
  end
end
