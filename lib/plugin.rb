module CocoaPodsKeys

  Pod::HooksManager.register(:post_install) do |options|
    require 'installer'

    Installer.new(options.sandbox_root).install!
  end
end
