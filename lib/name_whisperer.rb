require 'cocoapods'

module CocoaPodsKeys
    class NameWhisperer

      def self.get_project_name()
        podfile = Pod::Podfile.from_file("Podfile") rescue nil
        if podfile
          user_xcodeproj = xcodeproj_from_podfile(podfile)
        end
        user_xcodeproj ||= self.search_folders_for_xcodeproj
        user_xcodeproj.gsub(".xcodeproj", "")
      end

    private

      def self.xcodeproj_from_podfile(podfile)
        if podfile.target_definition_list.length > 0
          return podfile.target_definition_list[0].user_project_path
        end

        nil
      end

      def self.search_folders_for_xcodeproj
        xcodeprojects = Dir.glob("**/**/*.xcodeproj")
        if xcodeprojects.length == 1
          Pathname.new(xcodeprojects[0]).basename.to_s
        else
          error_message = (xcodeprojects.length > 1) ? "found too many" : "couldn't find any"
          puts "Hello there, we " + error_message + " xcodeprojects. Please give a name for this project."

          answer = ""
          loop do
            print " > "
            answer = STDIN.gets.chomp
            break if answer.length > 0
          end
          answer

        end
      end

    end
end
