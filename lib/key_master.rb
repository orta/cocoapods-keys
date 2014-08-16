require 'set'

module CocoaPodsKeys
  class KeyMaster

    def initialize(keys)
      @keys = keys
      @used_indexes = Set.new
      @indexed_keys = []
      @data = generate_data
      super
    end

    def generate_data
      data = `head -c 10000 /dev/random | base64 | head -c 10000`
      length = data.length

      @keys.each_with_index do |key, key_index|
        @indexed_keys[key_index] = []

        key.chars.each_with_index do |char, char_index|
          loop do

            index = rand data.length
            unless @used_indexes.include?(index)
              data[index] = char

              @used_indexes << index
              @indexed_keys[key_index][char_index] = index
              break
            end

          end
        end
      end

      data
    end

    def generate_source_code

    end

  end
end
