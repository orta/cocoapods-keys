require 'spec_helper'
require 'keyring'

include CocoaPodsKeys

class FakeKeychain
  def initialize(data)
    @data = data
  end

  def [](_, key)
    data[key]
  end
end

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

  it 'looks up keys from the OSXKeychain' do
    keyring = Keyring.new('test', '/', ['ARMyKey'])
    keyring.instance_variable_set(:@keychain, FakeKeychain.new('KeychainKey' => 'abcde'))
    expect(keyring.keychain_has_key?('KeychainKey')).to be_truthy
    expect(keyring.keychain_value('KeychainKey')).to eq('12345')
    expect(keyring.keychain_has_key?('NotMyKey')).to be_falsey
  end

  it 'looks up keys from ENV' do
    keyring = Keyring.new('test', '/', ['ARMyKey'])
    ENV['EnvKey'] = '12345'
    keyring.instance_variable_set(:@keychain, FakeKeychain.new('KeychainKey' => 'abcde'))
    expect(keyring.keychain_has_key?('EnvKey')).to be_truthy
    expect(keyring.keychain_value('EnvKey')).to eq('12345')
    expect(keyring.keychain_has_key?('NotMyKey')).to be_falsey
  end

  it 'updates its list of keys' do
    keyring = Keyring.new('test', '/', ['NotMyKey'])
    ENV['EnvKey'] = '12345'
    keyring.instance_variable_set(:@keychain, FakeKeychain.new('KeychainKey' => 'abcde'))

    keyring.keychain_has_key?('KeychainKey')
    keyring.keychain_has_key?('EnvKey')
    keyring.keychain_has_key?('NotMyKey')

    expect(keyring.keys).to include?('KeychainKey')
    expect(keyring.keys).to include?('EnvKey')
    expect(keyring.keys).not_to include?('NotMyKey')
  end
end
