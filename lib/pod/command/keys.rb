module Pod
  class Command
    class Keys < Command
      include ProjectDirectory

      require 'pod/command/keys/list'
      require 'pod/command/keys/set'
      require 'pod/command/keys/get'
      require 'pod/command/keys/rm'

      self.summary = 'A key value store for environment settings in Cocoa Apps.'

      self.description = <<-DESC
        CocoaPods Keys will store sensitive data in your Mac's keychain. Then on running pod install they will be installed into your app's source code via the Pods library.
      DESC

      self.abstract_command = true
      self.default_subcommand = 'list'

      def create_keyring
        current_dir = Pathname.pwd
        name = @project_name || CocoaPodsKeys::NameWhisperer.get_project_name
        CocoaPodsKeys::Keyring.new(name, current_dir, [])
      end

      def get_current_keyring
        current_dir = Pathname.pwd
        project = @project_name || CocoaPodsKeys::NameWhisperer.get_project_name
        CocoaPodsKeys::KeyringLiberator.get_current_keyring(project, current_dir)
      end
    end
  end
end
