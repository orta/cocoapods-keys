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

  it 'looks up keys from Keychain Access' do
    keyring = Keyring.new('test', '/', ['ARMyKey'])
    keyring.instance_variable_set(:@keychain, FakeKeychain.new('KeychainKey' => 'abcde'))
    expect(keyring.keychain_has_key?('KeychainKey')).to be_truthy
    expect(keyring.keychain_value('KeychainKey')).to eq('abcde')
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

    expect(keyring.keys.include?('KeychainKey')).to be_truthy
    expect(keyring.keys.include?('EnvKey')).to be_truthy
    expect(keyring.keys.include?('NotMyKey')).to be_falsey
  end
end
