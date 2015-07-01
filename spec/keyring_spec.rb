require 'spec_helper'
require 'keyring'

include CocoaPodsKeys

describe KeyringLiberator do
  before(:each) do
    ENV['ARMyKey'] = 'Hello'
  end

  after(:each) do
    ENV['ARMyKey'] = nil
  end

  it 'can get keys from ENV' do
    keyring = Keyring.new('test', '/', ['ARMyKey'])
    expect(keyring.keychain_data).to eq('ARMyKey' => 'Hello')
  end
end
