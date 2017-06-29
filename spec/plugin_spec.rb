require 'spec_helper'
require 'cocoapods'
require 'cocoapods-core'
require 'plugin'

# include Pod
#
# describe Installer do
#   it "only runs if the podfile has keys support" do
#     installer = Installer.new(Sandbox.new("."), Podfile.new)
#     installer.install!
#   end
#
# end

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

describe CocoaPodsKeys, '#plugin' do
  before(:each) do
    @config = Pod::Config.instance
    @podfile = double('Podfile')
    allow(@config).to receive(:podfile).and_return(@podfile)

    @target_defs = double('TargetDefinition')
    @target_a = double('TargetDefinition')
    @target_b = double('TargetDefinition')

    allow(@target_a).to receive(:label).and_return('Pods-TargetA')
    allow(@target_b).to receive(:label).and_return('Pods-TargetB')
  end

  context 'with no targets defined in the Podfile' do
    before(:each) do
      allow(@podfile).to receive(:root_target_definitions).and_return([])
    end

    it 'adds Keys to the global Pod' do
      expect(@podfile).to receive(:pod).with('Keys', anything)

      CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), {})
    end

    %w[target targets].each do |target_tag|
      context "with a non-existant target specified as a string in '#{target_tag}'" do
        it 'fails to assign the key to the tag' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(Pod::UI).to receive(:puts).with('Could not find a target named \'TargetA\' in your Podfile. Stopping keys'.red)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => 'TargetA')
        end
      end

      context "with a non-existant target specified as an array in '#{target_tag}'" do
        it 'fails to assign the key to the tag' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(Pod::UI).to receive(:puts).with('Could not find a target named \'TargetA\' in your Podfile. Stopping keys'.red)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => ['TargetA'])
        end
      end
    end
  end

  context 'with a single target defined in the Podfile' do
    before(:each) do
      @config = Pod::Config.instance
      @podfile = double('Podfile')
      allow(@config).to receive(:podfile).and_return(@podfile)

      allow(@podfile).to receive(:root_target_definitions).and_return([@target_defs])
      allow(@target_defs).to receive(:children).and_return([@target_a])
    end

    context 'with no targets specified' do
      it 'adds Keys to the global Pod' do
        expect(@podfile).to receive(:pod).with('Keys', anything)
        expect(@target_a).not_to receive(:store_pod).with('Keys', anything)

        CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), {})
      end
    end

    %w[target targets].each do |target_tag|
      context "with a string specified in '#{target_tag}'" do
        it 'adds Keys to the target' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(@target_a).to receive(:store_pod).with('Keys', anything)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => 'TargetA')
        end
      end

      context "with an array specified in '#{target_tag}'" do
        it 'adds Keys to the target' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(@target_a).to receive(:store_pod).with('Keys', anything)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => ['TargetA'])
        end
      end

      context "with a non-existant target specified as a string in '#{target_tag}'" do
        it 'fails to assign the key to the tag' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(Pod::UI).to receive(:puts).with('Could not find a target named \'TargetB\' in your Podfile. Stopping keys'.red)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => 'TargetB')
        end
      end

      context "with a non-existant target specified as an array in '#{target_tag}'" do
        it 'fails to assign the key to the tag' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(Pod::UI).to receive(:puts).with('Could not find a target named \'TargetB\' in your Podfile. Stopping keys'.red)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => ['TargetB'])
        end
      end
    end
  end

  context 'with two targets defined in the Podfile' do
    before(:each) do
      @config = Pod::Config.instance
      @podfile = double('Podfile')
      allow(@config).to receive(:podfile).and_return(@podfile)

      allow(@podfile).to receive(:root_target_definitions).and_return([@target_defs])
      allow(@target_defs).to receive(:children).and_return([@target_a, @target_b])
    end

    context 'with no targets specified' do
      it 'adds Keys to the global Pod' do
        expect(@podfile).to receive(:pod).with('Keys', anything)
        expect(@target_a).not_to receive(:store_pod).with('Keys', anything)
        expect(@target_b).not_to receive(:store_pod).with('Keys', anything)

        CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), {})
      end
    end

    %w[target targets].each do |target_tag|
      context "with 'TargetA' specified as a string in '#{target_tag}'" do
        it 'adds Keys to Target A' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(@target_a).to receive(:store_pod).with('Keys', anything)
          expect(@target_b).not_to receive(:store_pod).with('Keys', anything)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => 'TargetA')
        end
      end

      context "with 'TargetA' specified in an array in '#{target_tag}'" do
        it 'adds Keys to Target A' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(@target_a).to receive(:store_pod).with('Keys', anything)
          expect(@target_b).not_to receive(:store_pod).with('Keys', anything)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => ['TargetA'])
        end
      end

      context "with 'TargetA' specified as a string in '#{target_tag}'" do
        it 'adds Keys to Target B' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(@target_a).not_to receive(:store_pod).with('Keys', anything)
          expect(@target_b).to receive(:store_pod).with('Keys', anything)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => 'TargetB')
        end
      end

      context "with 'TargetB' specified in an array in '#{target_tag}'" do
        it 'adds Keys to Target B' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(@target_a).not_to receive(:store_pod).with('Keys', anything)
          expect(@target_b).to receive(:store_pod).with('Keys', anything)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => ['TargetB'])
        end
      end

      context "with a non-existant target specified as a string in '#{target_tag}'" do
        it 'fails to assign the key to the tag' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(Pod::UI).to receive(:puts).with('Could not find a target named \'TargetC\' in your Podfile. Stopping keys'.red)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => 'TargetC')
        end
      end

      context "with a non-existant target specified as an array in '#{target_tag}'" do
        it 'fails to assign the key to the tag' do
          expect(@podfile).not_to receive(:pod).with('Keys', anything)
          expect(Pod::UI).to receive(:puts).with('Could not find a target named \'TargetC\' in your Podfile. Stopping keys'.red)

          CocoaPodsKeys.add_keys_to_pods(@podfile, Pathname.new('Pods/CocoaPodsKeys/'), target_tag => ['TargetC'])
        end
      end
    end
  end
end
