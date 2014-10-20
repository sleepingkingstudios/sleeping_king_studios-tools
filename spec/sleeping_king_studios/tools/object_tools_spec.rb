# spec/sleeping_king_studios/tools/object_tools_spec.rb

require 'sleeping_king_studios/tools/object_tools'

RSpec.describe SleepingKingStudios::Tools::ObjectTools do
  describe '::apply' do
    let(:base) { double('base object', :instance_method => nil) }

    it { expect(described_class).to respond_to(:apply).with(2).arguments }

    describe 'with a proc with no arguments' do
      let(:proc) { ->() { self.instance_method() } }

      it 'sets the base object as the receiver and calls the proc' do
        expect(base).to receive(:instance_method).and_return(:return_value)

        expect(described_class.apply base, proc).to be == :return_value
      end # it

      it 'does not change the methods on the object' do
        expect { described_class.apply base, proc }.not_to change(base, :methods)
      end # it
    end # describe

    describe 'with a proc with many arguments' do
      let(:args) { %i(foo bar baz) }
      let(:proc) { ->(*args) { self.instance_method(*args) } }

      it 'sets the base object as the receiver and calls the proc with the arguments' do
        expect(base).to receive(:instance_method) do |*symbols|
          "Called with #{symbols.join ', '}."
        end # receive

        expect(described_class.apply base, proc, *args).to be == "Called with #{args.join ', '}."
      end # it
    end # describe

    describe 'with a proc with a block' do
      let(:proc) { ->(&block) { self.instance_method &block } }

      it 'sets the base object as the receiver and calls the proc with the block' do
        expect(base).to receive(:instance_method) do |&block|
          %i(foo bar baz).map { |symbol| block.call symbol }
        end # receive

        expect(described_class.apply(base, proc) { |symbol| "yielded symbol :#{symbol}" }).to be == ["yielded symbol :foo", "yielded symbol :bar", "yielded symbol :baz"]
      end # it
    end # describe
  end # describe

  describe '::eigenclass' do
    let(:object) { Object.new }

    it { expect(described_class).to respond_to(:eigenclass).with(1).argument }

    it "returns the object's metaclass" do
      metaclass = class << object; self; end

      expect(described_class.eigenclass(object)).to be == metaclass
    end # it
  end # describe

  describe '::metaclass' do
    let(:object) { Object.new }

    it { expect(described_class).to respond_to(:metaclass).with(1).argument }

    it "returns the object's metaclass" do
      metaclass = class << object; self; end

      expect(described_class.metaclass(object)).to be == metaclass
    end # it
  end # describe
end # describe
