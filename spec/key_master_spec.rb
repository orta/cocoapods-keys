require 'spec_helper'
require 'key_master'

describe CocoaPodsKeys::KeyMaster do
  let(:empty_keys_interface) {
    IO.read(File.join(__dir__, "fixtures", "Keys_empty.h"))
  }
  
  let(:empty_keys_implementation) {
    IO.read(File.join(__dir__, "fixtures", "Keys_empty.m"))
  }
  
  it "should init with an empty keyring" do
    keyring = double("Keyring", keychain_data: [], code_name: "Fake")
    keymaster = described_class.new(keyring, Time.new(2015, 3, 11))
    expect(keymaster.name).to eq("FakeKeys")
    expect(keymaster.interface).to eq(empty_keys_interface)
    expect(keymaster.implementation).to eq(empty_keys_implementation)
    expect(validate_syntax(keymaster)).to eq(true)
  end
  
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
      system("clang", "-fsyntax-only", m_file)
    end
  end
end