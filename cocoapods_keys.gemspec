# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_keys.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-keys"
  spec.version       = CocoaPodsKeys::VERSION
  spec.authors       = ["Orta Therox", 'Samuel E. Giddins']
  spec.email         = ["orta.therox@gmail.com", 'segiddins@segiddins.me']
  spec.description   = %q{A key value store for environment settings in Cocoa Apps.}
  spec.summary       = %q{CocoaPods Keys will store sensitive data in your Mac's keychain. Then on running `pod install` they will be installed into your app's source code by creating a Development Pod.}
  spec.homepage      = "https://github.com/orta/cocoapods-keys"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "keychain"
  spec.add_runtime_dependency "dotenv"
  # spec.add_runtime_dependency "cocoapods", "> 1"

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", "> 1.38"
end
