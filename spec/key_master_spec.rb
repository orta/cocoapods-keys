require 'spec_helper'
require 'keyring'
require 'key_master'
require 'tmpdir'

include CocoaPodsKeys

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

  describe '#name' do
    it 'takes keyring with name that starts with number returns augmented the name with underscore' do
      keyring = Keyring.new('500px', '/', ['ARMyKey'])
      keyring.instance_variable_set(:@keychain, FakeKeychain.new('ARMyKey' => 'secretkey'))
      key_master = KeyMaster.new(keyring)
      expect(key_master.name).to eq('_500pxKeys')
    end
    it 'takes keyring with proper name returns proper Keys file' do
      keyring = Keyring.new('Artsy', '/', ['ARMyKey'])
      keyring.instance_variable_set(:@keychain, FakeKeychain.new('ARMyKey' => 'secretkey'))
      key_master = KeyMaster.new(keyring)
      expect(key_master.name).to eq('ArtsyKeys')
    end
  end
end
