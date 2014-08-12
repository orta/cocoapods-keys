module Pod
  class Command
    class Spec
      # This is an example of a cocoapods plugin adding a subcommand to
      # the 'pod spec' command. Adapt it to suit your needs.
      #
      # @todo Create a PR to add your plugin to CocoaPods/cocoapods.org
      #       in the `plugins.json` file, once your plugin is released.
      #
      class Keys < Spec
        self.summary = "Short description of cocoapods-keys."

        self.description = <<-DESC
          Longer description of cocoapods-keys.
        DESC

        self.arguments = 'NAME'

        def initialize(argv)
          @name = argv.shift_argument
          super
        end

        def validate!
          super
          help! "A Pod name is required." unless @name
        end

        def run
          path = get_path_of_spec(@name)
          spec = Specification.from_file(path)
          UI.puts "Hello #{spec.name}"
        end
      end
    end
  end
end
