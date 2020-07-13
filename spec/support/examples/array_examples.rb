# frozen_string_literal: true

require 'support/examples'

module Spec::Examples
  module ArrayExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the array is frozen' do
      let(:ary) { super().freeze }
    end

    shared_examples 'should create a deep copy of an array' do
      describe 'with an array of arrays' do
        let(:ary) { [%w[ichi ni san], %w[yon go roku], %w[hachi nana kyuu]] }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 'jyuu' }.not_to(change { ary })
        end

        it 'should return a copy of the child arrays' do
          expect { cpy.first << 'jyuu' }.not_to(change { ary })
        end

        it 'should return a copy of the child array items' do
          expect { cpy.first.first << 'jyuu' }.not_to(change { ary })
        end
      end

      describe 'with an array of integers' do
        let(:ary) { [1, 2, 3] }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 4 }.not_to(change { ary })
        end
      end

      describe 'with an array of strings' do
        let(:ary) { %w[ichi ni san] }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 'yon' }.not_to(change { ary })
        end

        it 'should return a copy of the array items' do
          expect { cpy.first << 'yon' }.not_to(change { ary })
        end
      end

      describe 'with a heterogenous array' do
        let(:ary) { ['0', 1.0, :'2', 3, 4..5] }
        let(:cpy) { instance.deep_dup ary }

        it { expect(cpy).to be == ary }

        it 'should return a copy of the array' do
          expect { cpy << 'yon' }.not_to(change { ary })
        end

        it 'should return a copy of the array items' do
          expect { cpy.first << 'yon' }.not_to(change { ary })
        end
      end
    end

    shared_examples 'should perform a deep freeze of the array' do
      describe 'with an array of arrays' do
        let(:ary) { [%w[ichi ni san], %w[yon go roku], %w[hachi nana kyuu]] }

        it 'should freeze the array' do
          expect { instance.deep_freeze ary }
            .to change(ary, :frozen?)
            .to be true
        end

        it 'should freeze the array items' do
          instance.deep_freeze ary

          expect(ary.all?(&:frozen?)).to be true
        end

        it 'should freeze the nested array items' do
          instance.deep_freeze ary

          expect(ary.flatten.all?(&:frozen?)).to be true
        end
      end

      describe 'with an array of integers' do
        let(:ary) { [1, 2, 3] }

        it 'should freeze the array' do
          expect { instance.deep_freeze ary }
            .to change(ary, :frozen?)
            .to be true
        end
      end

      describe 'with an array of strings' do
        let(:ary) { %w[ichi ni san] }

        it 'should freeze the array' do
          expect { instance.deep_freeze ary }
            .to change(ary, :frozen?)
            .to be true
        end

        it 'should freeze the array items' do
          instance.deep_freeze ary

          expect(ary.all?(&:frozen?)).to be true
        end
      end

      describe 'with a heterogenous array' do
        let(:ary) { ['0', 1.0, :'2', 3, 4..5] }

        it 'should freeze the array' do
          expect { instance.deep_freeze ary }
            .to change(ary, :frozen?)
            .to be true
        end

        it 'should freeze the array items' do
          instance.deep_freeze ary

          expect(ary.all?(&:frozen?)).to be true
        end
      end
    end

    shared_examples 'should test if the array is immutable' do
      describe 'with an array of arrays' do
        let(:ary) do
          [
            [+'ichi', +'ni', +'san'],
            [+'yon', +'go', +'roku'],
            [+'hachi', +'nana', +'kyuu']
          ]
        end

        it { expect(instance.immutable? ary).to be false }

        context 'when the array is frozen' do
          include_context 'when the array is frozen'

          it { expect(instance.immutable? ary).to be false }

          context 'when the child arrays are frozen' do
            before(:example) { ary.each(&:freeze) }

            it { expect(instance.immutable? ary).to be false }

            context 'when the child array items are frozen' do
              before(:example) { ary.flatten.each(&:freeze) }

              it { expect(instance.immutable? ary).to be true }
            end
          end
        end
      end

      describe 'with an array of integers' do
        let(:ary) { [1, 2, 3] }

        it { expect(instance.immutable? ary).to be false }

        wrap_context 'when the array is frozen' do
          it { expect(instance.immutable? ary).to be true }
        end
      end

      describe 'with an array of mutable strings' do
        let(:ary) { [+'ichi', +'ni', +'san'] }

        it { expect(instance.immutable? ary).to be false }

        context 'when the array is frozen' do
          include_context 'when the array is frozen'

          it { expect(instance.immutable? ary).to be false }

          context 'when some of the strings are frozen' do
            before(:example) do
              ary.each.with_index { |item, index| item.freeze if index.odd? }
            end

            it { expect(instance.immutable? ary).to be false }
          end

          context 'when all of the strings are frozen' do
            before(:example) { ary.each(&:freeze) }

            it { expect(instance.immutable? ary).to be true }
          end
        end
      end

      describe 'with a heterogenous array' do
        let(:ary) { [+'0', 1.0, :'2', 3, 4..5] }

        it { expect(instance.immutable? ary).to be false }

        context 'when the array is frozen' do
          include_context 'when the array is frozen'

          it { expect(instance.immutable? ary).to be false }

          context 'when the mutable items are frozen' do
            before(:example) do
              ary.each do |item|
                unless SleepingKingStudios::Tools::ObjectTools.immutable?(item)
                  item.freeze
                end
              end
            end

            it { expect(instance.immutable? ary).to be true }
          end
        end
      end
    end
  end
end
