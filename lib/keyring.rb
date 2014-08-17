require "osx_keychain"

module CocoaPodsKeys
  class Keyring
    attr_accessor :keys, :path, :name

    def initialize(name, path, keys=[])
      @name = name
      @path = path
      @keys = keys
    end

    def self.from_hash(hash)
      new(hash["name"], hash["path"], hash["keys"])
    end

    def to_hash
      { "keys" => @keys, "path" => @path, "name" => @name }
    end

    def code_name
      name.titlecase.gsub(/![a-zA-Z0-9\-_]/, '')
    end

    def save(key, value)
      keychain = OSXKeychain.new
      keychain[keychain_prefix + name, key] = value
    end

    def keychain_data
      keychain = OSXKeychain.new
      Hash[
        @keys.map { |key| [key, keychain[keychain_prefix + name, key]] }
      ]
    end

    def keychain_prefix
      "cocoapods-keys-"
    end

  end
end

class String
  def titlecase
    downcase.split.map(&:capitalize).join(" ").upfirst
  end

  def upfirst
    self[0,1].capitalize + self[1,length-1]
  end
 end
