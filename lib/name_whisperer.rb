require 'cocoapods'

module CocoaPodsKeys
  class NameWhisperer
    def self.get_project_name
      podfile = Pod::Config.instance.podfile
      if podfile
        user_xcodeproj = xcodeproj_from_podfile(podfile)
      end
      user_xcodeproj ||= search_folders_for_xcodeproj
      user_xcodeproj.basename('.xcodeproj')
    end

    private

    def self.xcodeproj_from_podfile(podfile)
      unless podfile.target_definition_list.empty?
        return podfile.target_definition_list.first.user_project_path
      end
    end

    def self.search_folders_for_xcodeproj
      xcodeprojects = Pathname.glob('**/*.xcodeproj')
      if xcodeprojects.length == 1
        Pathname(xcodeprojects.first).basename
      else
        error_message = (xcodeprojects.length > 1) ? 'found too many' : "couldn't find any"
        puts 'CocoaPods-Keys ' + error_message + ' Xcode projects. Please give a name for this project.'

        answer = ''
        loop do
          print ' > '
          answer = STDIN.gets.chomp
          break if answer.length > 0
        end
        answer
      end
    end
  end
end
