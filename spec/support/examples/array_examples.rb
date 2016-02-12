# spec/support/examples/array_examples.rb

require 'support/examples'

module Spec::Examples
  module ArrayExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should create a deep copy of an array' do
      describe 'with an array of arrays' do
        let(:ary) { [%w(ichi ni san), %w(yon go roku), %w(hachi nana kyuu)] }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 'jyuu' }.not_to change { ary }
        end # it

        it 'should return a copy of the child arrays' do
          expect { cpy.first << 'jyuu' }.not_to change { ary }
        end # it

        it 'should return a copy of the child array items' do
          expect { cpy.first.first << 'jyuu' }.not_to change { ary }
        end # it
      end # describe

      describe 'with an array of integers' do
        let(:ary) { [1, 2, 3] }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 4 }.not_to change { ary }
        end # it
      end # describe

      describe 'with an array of strings' do
        let(:ary) { %w(ichi ni san) }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 'yon' }.not_to change { ary }
        end # it

        it 'should return a copy of the array items' do
          expect { cpy.first << 'yon' }.not_to change { ary }
        end # it
      end # describe

      describe 'with a heterogenous array' do
        let(:ary) { ['0', 1.0, :'2', 3, 4..5] }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 'yon' }.not_to change { ary }
        end # it

        it 'should return a copy of the array items' do
          expect { cpy.first << 'yon' }.not_to change { ary }
        end # it
      end # describe
    end # shared_examples
  end # module
end # module
