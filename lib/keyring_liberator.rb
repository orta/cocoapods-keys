require "digest"
require "yaml"
module CocoapodsKeys
  class KeyringLiberator

    # Gets given a gives back a Keyring for the project
    # by basically parsing it out of ~/.cocoapods/keys/"pathMD5".yml

    keys_dir = "~/.cocoapods/keys/"

    def self.get_keyring(path)
      sha = Digest::MD5.hexdigest(path)

      if Dir.exist?(keys_dir + "#{sha}.yml")
          hash = YAML.load yaml
          keyring = Keyring.new(hash)
      end
      nil
    end

    def self.save_keyring(keyring)
      `mkdir -p #{keys_dir}`

      sha = Digest::MD5.hexdigest(keyring.path)

      if Dir.exist?(keys_dir + "#{sha}.yml")
          hash = YAML.load yaml
      end
    end

  end
end
