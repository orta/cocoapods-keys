require 'cocoapods'

module CocoaPodsKeys
  class NameWhisperer
    def self.get_project_name
      podfile = Pod::Config.instance.podfile
      if podfile
        user_xcodeproj = xcodeproj_from_podfile(podfile)
      end
      user_xcodeproj || search_folders_for_xcodeproj
    end

    private

    def self.xcodeproj_from_podfile(podfile)
      unless podfile.target_definition_list.empty?
        project_path = podfile.target_definition_list.first.user_project_path
        File.basename(project_path, '.xcodeproj') if project_path
      end
    end

    def self.search_folders_for_xcodeproj
      ui = Pod::UserInterface
      xcodeprojects = Pathname.glob('**/*.xcodeproj').reject { |path| path.to_s.start_with?('Pods/') }
      if xcodeprojects.length == 1
        Pathname(xcodeprojects.first).basename('.xcodeproj')
      else
        error_message = xcodeprojects.length > 1 ? 'found too many' : "couldn't find any"
        projects = xcodeprojects.map(&:basename).join(' ')
        ui.puts 'CocoaPods-Keys ' + error_message + ' Xcode projects (' + projects + '). Please give a name for this project.'

        answer = ''
        loop do
          ui.print ' > '
          answer = ui.gets.strip
          break unless answer.empty?
        end
        answer
      end
    end

    private_class_method :xcodeproj_from_podfile
    private_class_method :search_folders_for_xcodeproj
  end
end
