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

    def keychain_data
      keychain = OSXKeychain.new
      Hash[
        @keys.map { |key| [key, keychain["cocoapods-keys-bundle-#{name}", key]] }
      ]
    end

  end
end
