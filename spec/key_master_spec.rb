require 'spec_helper'
require 'key_master'

describe CocoaPodsKeys::KeyMaster do
  let(:empty_keys_interface) {
    IO.read(File.join(__dir__, "fixtures", "Keys.h_empty"))
  }
  
  let(:empty_keys_implementation) {
    IO.read(File.join(__dir__, "fixtures", "Keys.m_empty"))
  }
  
  it "should init with an empty keyring" do
    keyring = double("Keyring", keychain_data: [], code_name: "Fake")
    keymaster = described_class.new(keyring, Time.new(2015, 3, 11))
    expect(keymaster.name).to eq("FakeKeys")
    expect(keymaster.interface).to eq(empty_keys_interface)
    expect(keymaster.implementation).to eq(empty_keys_implementation)
  end
end