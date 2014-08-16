require 'set'

module CocoaPodsKeys
  class KeyMaster

    def initialize(keys)
      @keys = keys
      @used_indexes = Set.new
      @indexed_keys = {}
      @data = generate_data
      generate_source_code
    end

    def generate_data
      data = `head -c 10000 /dev/random | base64 | head -c 10000`
      length = data.length

      @keys.each do |key, value|
        @indexed_keys[key] = []

        value.chars.each_with_index do |char, char_index|
          loop do

            index = rand data.length
            unless @used_indexes.include?(index)
              data[index] = char

              @used_indexes << index
              @indexed_keys[key][char_index] = index
              break
            end

          end
        end
      end

      data
    end

    def generate_source_code
      require 'pathname'
      require 'erb'
      require 'digest'

      erb = <<-SOURCE
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface Keys : NSObject

<% @keys.each do |key, value| %>

- (NSString *)<%= key %>;

<% end %>

@end

@implementation Keys

+ (BOOL)resolveInstanceMethod:(SEL)name {
  NSString *key = NSStringFromSelector(name);
  IMP implementation = NULL;
<% @keys.each do |key, value| %>
  if ([key isEqualToString:@"<%= key %>"]) {
    implementation = _podKeys<%= Digest::MD5.hexdigest(key) %>;
  }
<% end %>

  if (!implementation) {
    return [super resolveInstanceMethod:name];
  }

  class_addMethod([self class], name, (IMP)implementation, "@@:");
  return YES;
}

<% @keys.each do |key, value| %>

static NSString *_podKeys<%= Digest::MD5.hexdigest(key) %>() {
  char cString[<%= hash[key].length %>] = { <%= hash[key] %> };
  return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
}

<% end %>

static char PodKeysData[10000] = "<%= @data %>";

@end

int main(int argc, char **argv) {
  NSLog(@"%@", [[Keys new] <%= @keys.keys.first %>]);
}

SOURCE

      hash = Hash[@indexed_keys.map {|key, value| [key, value.map { |i| "PodKeysData[#{i}]" }.join(', ')]}]

      b = binding

      source = ERB.new(erb).result(b)

      Pathname.new('~/Keys.m').expand_path.open('w') {|f| f.write source}
    end

  end
end
