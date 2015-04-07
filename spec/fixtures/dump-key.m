// Dumps a key from a fixture bundle created like so:
//
// $ xcrun clang -framework Foundation -bundle ArtsyKeys.m -o ArtsyKeys.bundle

#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <stdio.h>

int main(int argc, char **argv) {
  if (argc != 3) {
      fprintf(stderr, "Usage: dump-key path/to/fixture.bundle [KEY]\n");
      return 1;
  }

  char *fixturePath = argv[1];
  char *keyName = argv[2];

  if (dlopen(fixturePath, RTLD_NOW) == NULL) {
      fprintf(stderr, "[!] Unable to load bundle at path `%s`: %s\n", fixturePath, strerror(errno));
      return 2;
  }

  NSString *fixtureClassName = [[[NSString stringWithUTF8String:fixturePath] lastPathComponent] stringByDeletingPathExtension];
  Class fixtureClass = NSClassFromString(fixtureClassName);
  if (fixtureClass == nil) {
      fprintf(stderr, "[!] Unable to load fixture class `%s` from bundle at `%s`\n", [fixtureClassName UTF8String], fixturePath);
      return 3;
  }

  SEL keySelector = sel_registerName(keyName);
  if (![fixtureClass instancesRespondToSelector:keySelector]) {
      fprintf(stderr, "[!] Unable to find key `%s` in fixture class `%s` from bundle at `%s`\n", keyName, [fixtureClassName UTF8String], fixturePath);
      return 4;
  }

  NSString *key = [[fixtureClass new] performSelector:keySelector];
  // TODO Or is a `nil` entry fine?
  if (key == nil) {
      fprintf(stderr, "[!] Got `nil` for key `%s` in fixture class `%s` from bundle at `%s`\n", keyName, [fixtureClassName UTF8String], fixturePath);
      return 5;
  }

  printf("%s\n", [key UTF8String]);
  return 0;
}
