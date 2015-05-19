require 'set'
require 'erb'
require 'digest'
require 'securerandom'

module CocoaPodsKeys
  class KeyMaster
    attr_accessor :name, :interface, :implementation

    def initialize(keyring, time = Time.now)
      @time = time
      @keys = Hash[keyring.keychain_data.map { |(key, value)| [key[0].downcase + key[1..-1], value] }]
      @name = keyring.code_name + 'Keys'
      @used_indexes = Set.new
      @indexed_keys = {}
      @data = generate_data
      @interface = generate_interface
      @implementation = generate_implementation
    end

    def generate_data

      # guard method; raises error if something in application keychain
      # is nil. provides for better error message.
      self.verify_keychain_integrity

      # Generate a base64 hash string that is ~25 times the length of all keys

      @data_length = @keys.values.map(&:length).reduce(:+) * (20 + rand(10))
      data = SecureRandom.base64(@data_length)
      data += '\\"'
      @data_length = data.length

      # Swap the characters within the hashed string with the characters from
      # the keyring values. Then store that index in a index-ed copy of the values.

      @keys.each do |key, value|
        @indexed_keys[key] = []

        value.chars.each_with_index do |char, char_index|
          loop do
            if char == '"'
              index = data.delete('\\').length - 1
              @indexed_keys[key][char_index] = index
              break
            else
              index = SecureRandom.random_number data.length
              unless @used_indexes.include?(index)
                data[index] = char

                @used_indexes << index
                @indexed_keys[key][char_index] = index
                break
              end
            end
          end
        end
      end

      data
    end

    def generate_interface
      render_erb('Keys.h.erb')
    end

    def generate_implementation
      render_erb('Keys.m.erb')
    end

    :private

    def verify_keychain_integrity
      if @keys.values.any? { |value| value.nil? } || @keys.any? { |value| value.nil? }
        raise "A key/value pair in the application keychain is nil."
      end
    end

    def render_erb(erb_template)
      erb = (Pathname(__dir__).parent + 'templates' + erb_template).read
      ERB.new(erb, nil, '-').result(binding)
    end

    def key_data_arrays
      Hash[@indexed_keys.map { |key, value| [key, value.map { |i| name + "Data[#{i}]" }.join(', ')] }]
    end
  end
end
