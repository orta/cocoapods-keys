module Pod
  class Command

    class Keys < Command
      require 'pod/command/keys/list'
      require 'pod/command/keys/set'
      require 'pod/command/keys/get'
      require 'pod/command/keys/rm'

      self.summary = "A key value store for environment settings in Cocoa Apps."

      self.description = <<-DESC
        CocoaPods Keys will store sensitive data in your Mac's keychain. Then on running pod install they will be installed into your app's source code via the Pods library.
      DESC

      self.abstract_command = true
      self.default_subcommand = 'list'

    end
  end
end
