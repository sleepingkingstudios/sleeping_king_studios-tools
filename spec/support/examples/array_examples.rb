# spec/support/examples/array_examples.rb

require 'support/examples'

module Spec::Examples
  module ArrayExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the array is frozen' do
      let(:ary) { super().freeze }
    end # shared_context

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

    shared_examples 'should perform a deep freeze of the array' do
      describe 'with an array of arrays' do
        let(:ary) { [%w(ichi ni san), %w(yon go roku), %w(hachi nana kyuu)] }

        it 'should freeze the array and items' do
          expect { instance.deep_freeze ary }.
            to change(ary, :frozen?).
            to be true

          ary.each do |child|
            expect(child.frozen?).to be true

            child.each do |item|
              expect(item.frozen?).to be true
            end # each
          end # each
        end # it
      end # describe

      describe 'with an array of integers' do
        let(:ary) { [1, 2, 3] }

        it 'should freeze the array' do
          expect { instance.deep_freeze ary }.
            to change(ary, :frozen?).
            to be true
        end # it
      end # describe

      describe 'with an array of strings' do
        let(:ary) { %w(ichi ni san) }

        it 'should freeze the array and items' do
          expect { instance.deep_freeze ary }.
            to change(ary, :frozen?).
            to be true

          ary.each do |item|
            expect(item.frozen?).to be true
          end # each
        end # it
      end # describe

      describe 'with a heterogenous array' do
        let(:ary) { ['0', 1.0, :'2', 3, 4..5] }

        it 'should freeze the array and items' do
          expect { instance.deep_freeze ary }.
            to change(ary, :frozen?).
            to be true

          ary.each do |item|
            expect(item.frozen?).to be true
          end # each
        end # it
      end # describe
    end # shared_examples

    shared_examples 'should test if the array is immutable' do
      describe 'with an array of arrays' do
        let(:ary) { [%w(ichi ni san), %w(yon go roku), %w(hachi nana kyuu)] }

        it { expect(instance.immutable? ary).to be false }

        wrap_context 'when the array is frozen' do
          it { expect(instance.immutable? ary).to be false }

          context 'when the child arrays are frozen' do
            before(:example) { ary.each { |item| item.freeze } }

            it { expect(instance.immutable? ary).to be false }

            context 'when the child array items are frozen' do
              before(:example) { ary.flatten.each { |item| item.freeze } }

              it { expect(instance.immutable? ary).to be true }
            end # context
          end # context
        end # wrap_context
      end # describe

      describe 'with an array of integers' do
        let(:ary) { [1, 2, 3] }

        it { expect(instance.immutable? ary).to be false }

        wrap_context 'when the array is frozen' do
          it { expect(instance.immutable? ary).to be true }
        end # wrap_context
      end # describe

      describe 'with an array of strings' do
        let(:ary) { %w(ichi ni san) }

        it { expect(instance.immutable? ary).to be false }

        wrap_context 'when the array is frozen' do
          it { expect(instance.immutable? ary).to be false }

          context 'when some of the strings are frozen' do
            before(:example) { ary.each.with_index { |item, index| item.freeze if index.odd? } }

            it { expect(instance.immutable? ary).to be false }
          end # context

          context 'when all of the strings are frozen' do
            before(:example) { ary.each { |item| item.freeze } }

            it { expect(instance.immutable? ary).to be true }
          end # context
        end # wrap_context
      end # describe

      describe 'with a heterogenous array' do
        let(:ary) { ['0', 1.0, :'2', 3, 4..5] }

        it { expect(instance.immutable? ary).to be false }

        wrap_context 'when the array is frozen' do
          it { expect(instance.immutable? ary).to be false }

          context 'when the mutable items are frozen' do
            before(:example) { ary.each { |item| item.freeze unless ::SleepingKingStudios::Tools::ObjectTools.immutable?(item) } }

            it { expect(instance.immutable? ary).to be true }
          end # context
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
