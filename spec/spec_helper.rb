$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

def clang_available
  # uses a shell to ensure we get a reasonable PATH
  system('which -s clang')
end

def fixture(name)
  File.join(__dir__, 'fixtures', name)
end

RSpec.configure do |c|
  # exclude tests requiring clang when it's unavailable
  c.filter_run_excluding :requires_clang => true unless clang_available

  c.color = true
end

class FakeKeychain
  def initialize(data)
    @data = data
  end

  def [](_, key)
    @data[key]
  end
end
