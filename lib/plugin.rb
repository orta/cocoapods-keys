require 'cocoapods-core'

module CocoaPodsKeys

  # Pod::HooksManager.register('cocoapods-keys', :post_install) do |context, user_options|
  #   require 'installer'
  #   require 'preinstaller'

  #   # PreInstaller.new(user_options).setup
  #   # Installer.new(context.sandbox_root, user_options).install!
  # end
end


module Pod
  class Installer

    include Pod::Podfile::DSL

    alias_method :original_install!, :install!

    def install!
      # original_install!

      # So the problem here is that we can either have a pod specified with :path 
      # that will be assumed to be a development pod (do not want) *or* we can have 
      # a pod specified by a file, like below. The problem is that I don't think 
      # we can use a podspec that points to local `source` files (only git, hg, 
      # etc). I would like to programmatically generate a podspec that uses :local
      # or :path in the `sources`, but I get an 'Unsupported download strategy' 
      # when I try and lint a pod like that. Must investigate more. Can I 
      # programmatically generate a podspec? Maybe a subclass, like with unit 
      # tests doubles? But then how do I call private methods to add that spec
      # to our list? 

      # ORRRR maybe I can use a podspec that refers to any (maybe empty?) GH repo
      # but specifies *no* source files. After installation, I can add the Keys
      # .m/.h files to that empty pod's target. Maybe? 

      config.podfile.pod :podspec => '/Users/ash/bin/eidolon/Keys.podspec'

      puts @podfile.to_hash["target_definitions"].map { |d| d["dependencies"] }
      abort "\'Nuff said."
    end
  end
end
