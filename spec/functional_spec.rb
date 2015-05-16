require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe 'CocoaPodsKeys functional tests' do
  before :all do
    @tmpdir = Dir.mktmpdir
    Dir.chdir(@tmpdir) do
      FileUtils.mkdir('TestProject.xcodeproj')
      File.open('Podfile', 'w') do |podfile|
        podfile.puts <<-PODFILE
          platform :ios, '7'
          plugin 'cocoapods-keys', {
              :project => 'TestProject',
              :keys => [
                  'KeyWithData',
                  'AnotherKeyWithData',
                  # This is not included!
                  # 'UnusedKey'
              ]
          }
        PODFILE
      end

      system('pod keys set KeyWithData such-data --silent')
      system('pod keys set AnotherKeyWithData other-data --silent')
      system('pod keys set UnusedKey - --silent')
      system('pod install --silent --no-repo-update --no-integrate')
    end
  end

  it 'does not directly encode the keys into the implementation file' do
    source = File.read(File.join(@tmpdir, 'Pods/CocoaPodsKeys/TestProjectKeys.m'))
    expect(source).to_not include('such-data')
    expect(source).to_not include('other-data')
  end

  it 'is able to retrieve the correct keys from the command-line' do
    Dir.chdir(@tmpdir) do
      expect(`pod keys get KeyWithData`.strip).to eq('such-data')
      expect(`pod keys get AnotherKeyWithData`.strip).to eq('other-data')
    end
  end

  describe 'with a built keys implementation' do
    before :all do
      name = 'TestProjectKeys'
      dir = File.join(@tmpdir, 'Pods/CocoaPodsKeys')
      Dir.chdir(dir) do
        system("xcrun clang -framework Foundation -bundle #{name}.m -o #{name}.bundle")
      end
      @bundle = File.join(dir, "#{name}.bundle")
    end

    it 'produces an implementation that is able to return the correct keys' do
      expect(fetch_key('keyWithData')).to eq('such-data')
      expect(fetch_key('anotherKeyWithData')).to eq('other-data')
    end

    xit 'does not include keys that were not specified in the Podfile' do
      expect(lambda { fetch_key('unusedKey') }).to raise_error
    end

    private

    def fetch_key(key)
      result = `'#{fixture('dump-key')}' '#{@bundle}' #{key}`.strip
      raise 'Failed to fetch key from bundle' unless $?.success?
      result
    end
  end
end
