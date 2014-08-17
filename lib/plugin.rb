module CocoaPodsKeys

  Pod::HooksManager.register(:post_install) do |options|
    # require 'xcodeproj/ext'
    # sandbox = Pod::Sandbox.new(options[:sandbox_root])
    # options[:user_targets].each do |user_target|
    #   metadata = PlistGenerator.generate(user_target, sandbox)
    #   plist_path = sandbox.root + "#{user_target[:cocoapods_target_label]}-metadata.plist"
    #   Xcodeproj.write_plist(metadata, plist_path)
    #
    #
    #   user_target[:user_project_path]
    #   project = Xcodeproj::Project.open(user_target[:user_project_path])
    #   cocoapods_group = project.main_group["CocoaPods"]
    #   unless cocoapods_group
    #     cocoapods_group = project.main_group.new_group("CocoaPods", sandbox.root)
    #   end
    #
    #   file_ref = cocoapods_group.files.find { |file| file.real_path == plist_path }
    #   unless file_ref
    #     file_ref = cocoapods_group.new_file(plist_path)
    #   end
    #
    #   target = project.objects_by_uuid[user_target[:uuid]]
    #   unless target.resources_build_phase.files_references.include?(file_ref)
    #     target.add_resources([file_ref])
    #   end
    #
    #   project.save

    require 'installer'

    p options

    Installer.new.install!

    puts "Hello from Keys"
    # end
  end
end
