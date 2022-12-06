require 'keychain'
require 'base64'
require 'json'

module CocoaPodsKeys
  class Keyring
    attr_accessor :keys, :path, :name

    def initialize(name, path, keys = [])
      @name = name.to_s
      @path = path.to_s
      @keys = keys
    end

    def self.from_hash(hash)
      new(hash['name'], hash['path'], hash['keys'])
    end

    def to_hash
      { 'keys' => @keys, 'path' => @path, 'name' => @name }
    end

    def code_name
      name.split(/[^a-zA-Z0-9_]/).map { |s| s[0].upcase + s[1..-1] }.join('')
    end

    def self.keychain_prefix
      'cocoapods-keys-'
    end

    def keychain
      @keychain ||= Keychain.generic_passwords
    end

    def save(key, value)
      item = keychain.where(service: self.class.keychain_prefix + name, account: key).first
      if item
        item.password = value
        item.save!
      else
        keychain.create(service: self.class.keychain_prefix + name, password: value, account: key)
      end
    end

    def keychain_data
      Hash[
        @keys.map { |key| [key, keychain_value(key)] }
      ]
    end

    def keychain_has_key?(key)
      has_key = !keychain_value(key).nil?

      if has_key && !@keys.include?(key)
        @keys << key
      elsif !has_key && @keys.include?(key)
        @keys.delete(key)
      end

      has_key
    end

    def keychain_value(key)
      item = keychain.where(service: self.class.keychain_prefix + name, account: key).first
      ENV[key] || item&.password
    end

    def camel_cased_keys
      Hash[keychain_data.map { |(key, value)| [key[0].downcase + key[1..-1], value] }]
    end
  end
end
