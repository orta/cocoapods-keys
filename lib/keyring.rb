require 'osx_keychain'

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
      @keychain ||= OSXKeychain.new
    end

    def save(key, value)
      keychain[self.class.keychain_prefix + name, key] = value
    end

    def keychain_data
      Hash[
        @keys.map { |key| [key, ENV[key] || keychain[self.class.keychain_prefix + name, key]] }
      ]
    end

    def camel_cased_keys
      Hash[keychain_data.map { |(key, value)| [key[0].downcase + key[1..-1], value] }]
    end
  end
end
