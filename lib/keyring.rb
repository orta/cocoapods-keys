module CocoapodsKeys
  class Keyring
    attr_accessor :keys, :path, :name

    def initialize(hash)
      @keys = hash[:keys]
      @path = hash[:path]
      @name = hash[:name]
      super
    end

  end
end
