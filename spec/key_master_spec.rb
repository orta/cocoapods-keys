require 'spec_helper'
require 'key_master'
require 'tmpdir'

describe CocoaPodsKeys::KeyMaster do

  # Previous tests operated under assumption that
  # empty keychains were OK. See for more info:
  # github.com/orta/cocoapods-keys/pull/68

  private

  def validate_syntax(keymaster)
    # write out the interface and the implementation to temp files
    Dir.mktmpdir do |dir|
      # create the header file
      h_file = File.join(dir, "#{keymaster.name}.h")
      IO.write(h_file, keymaster.interface)
      # create the implementation file
      m_file = File.join(dir, "#{keymaster.name}.m")
      IO.write(m_file, keymaster.implementation)
      # attempt to validate syntax with clang
      Dir.chdir(dir)
      system(`xcrun --sdk macosx --find clang`.strip, '-fsyntax-only', m_file)
    end
  end
end
