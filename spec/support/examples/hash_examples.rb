# frozen_string_literal: true

require 'support/examples'

module Spec::Examples
  module HashExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the hash is frozen' do
      let(:hsh) { super().freeze }
    end

    shared_context 'when the hash keys are frozen' do
      before(:example) do
        hsh.each { |key, _| key.freeze }
      end
    end

    shared_context 'when the hash values are frozen' do
      before(:example) do
        hsh.each { |_, value| value.freeze }
      end
    end

    shared_examples 'should create a deep copy of a hash' do
      describe 'with a hash with mutable keys' do
        let(:key_class) { Struct.new :value }
        let(:hsh) do
          {
            key_class.new(+'foo') => 'foo',
            key_class.new(+'bar') => 'bar',
            key_class.new(+'baz') => 'baz'
          }
        end
        let(:cpy) { instance.deep_dup hsh }

        def normalize(hsh)
          hsh.each.with_object({}) do |(key, value), copy|
            normalized = key.value.dup

            copy[normalized] = value
          end
          hsh.keys.map(&:value).map(&:dup)
        end

        it { expect(cpy).to be == hsh }

        it { expect(normalize cpy).to be == normalize(hsh) }

        it 'should return a copy of the hash', :aggregate_failures do
          expect { cpy[key_class.new 'wibble'] = 'wibble' }
            .not_to(change { normalize hsh })

          expect { cpy[key_class.new 'foo'] = 'FOO' }
            .not_to(change { normalize hsh })
        end

        it 'should return a copy of the hash values' do
          expect { cpy[key_class.new 'foo'] << 'wobble' }
            .not_to(change { normalize hsh })
        end

        it 'should return a shallow copy of the hash keys' do
          expect do
            cpy.keys.find { |key| key.value == 'foo' }.value << 'wobble'
          end.to(change { normalize hsh })
        end

        context 'with a defined #deep_dup method' do
          before(:example) do
            key_class.send :define_method, :deep_dup do
              self.class.new(value.dup)
            end
          end

          it 'should return a deep copy of the hash keys' do
            copy = instance.deep_dup hsh

            expect do
              copy.keys.find { |key| key.value == 'foo' }.value << 'wobble'
            end.not_to(change { normalize hsh })
          end
        end
      end

      describe 'with a hash with string keys' do
        let(:hsh) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }
        let(:cpy) { instance.deep_dup hsh }

        it { expect(cpy).to be == hsh }

        it 'should return a copy of the hash', :aggregate_failures do
          expect { cpy['wibble'] = 'wibble' }.not_to(change { hsh })

          expect { cpy['foo'] = 'FOO' }.not_to(change { hsh })
        end

        it 'should return a copy of the hash values' do
          expect { cpy['foo'] << 'wobble' }.not_to(change { hsh })
        end
      end

      describe 'with a hash with symbol keys' do
        let(:hsh) { { foo: 'foo', bar: 'bar', baz: 'baz' } }
        let(:cpy) { instance.deep_dup hsh }

        it { expect(cpy).to be == hsh }

        it 'should return a copy of the hash', :aggregate_failures do
          expect { cpy[:wibble] = 'wibble' }.not_to(change { hsh })

          expect { cpy[:foo] = 'FOO' }.not_to(change { hsh })
        end

        it 'should return a copy of the hash values' do
          expect { cpy[:foo] << 'wobble' }.not_to(change { hsh })
        end
      end

      describe 'with a hash with hash values' do
        let(:hsh) do
          {
            english:  {
              'one'   => '1',
              'two'   => '2',
              'three' => '3'
            },
            japanese: {
              'yon'  => '4',
              'go'   => '5',
              'roku' => '6'
            },
            spanish:  {
              'siete' => '7',
              'ocho'  => '8',
              'nueve' => '9'
            }
          }
        end
        let(:cpy) { instance.deep_dup hsh }

        it { expect(cpy).to be == hsh }

        it 'should return a copy of the hash', :aggregate_failures do
          expect { cpy[:german]  = {} }.not_to(change { hsh })

          expect { cpy[:english] = {} }.not_to(change { hsh })
        end

        it 'should return a copy of the child hashes', :aggregate_failures do
          child = cpy[:english]

          expect { child['ten'] = '10' }.not_to(change { hsh })

          expect { child['one'] = '1.0' }.not_to(change { hsh })
        end

        it 'should return a copy of the child hash values' do
          child = cpy[:english]

          expect { child['one'] << '.0' }.not_to(change { hsh })
        end
      end
    end

    shared_examples 'should perform a deep freeze of the hash' do
      describe 'with a hash with mutable keys' do
        let(:key_class) { Struct.new :value }
        let(:hsh) do
          {
            key_class.new('foo') => 'foo',
            key_class.new('bar') => 'bar',
            key_class.new('baz') => 'baz'
          }
        end

        it 'should freeze the hash' do
          expect { instance.deep_freeze hsh }
            .to change(hsh, :frozen?)
            .to be true
        end

        it 'should freeze the hash keys' do
          instance.deep_freeze hsh

          expect(hsh.keys.all?(&:frozen?)).to be true
        end

        it 'should freeze the hash values' do
          instance.deep_freeze hsh

          expect(hsh.values.all?(&:frozen?)).to be true
        end
      end

      describe 'with a hash with string keys' do
        let(:hsh) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }

        it 'should freeze the hash' do
          expect { instance.deep_freeze hsh }
            .to change(hsh, :frozen?)
            .to be true
        end

        it 'should freeze the hash keys' do
          instance.deep_freeze hsh

          expect(hsh.keys.all?(&:frozen?)).to be true
        end

        it 'should freeze the hash values' do
          instance.deep_freeze hsh

          expect(hsh.values.all?(&:frozen?)).to be true
        end
      end

      describe 'with a hash with symbol keys' do
        let(:hsh) { { foo: 'foo', bar: 'bar', baz: 'baz' } }

        it 'should freeze the hash' do
          expect { instance.deep_freeze hsh }
            .to change(hsh, :frozen?)
            .to be true
        end

        it 'should freeze the hash keys' do
          instance.deep_freeze hsh

          expect(hsh.keys.all?(&:frozen?)).to be true
        end

        it 'should freeze the hash values' do
          instance.deep_freeze hsh

          expect(hsh.values.all?(&:frozen?)).to be true
        end
      end

      describe 'with a hash with hash values' do
        let(:hsh) do
          {
            english:  {
              'one'   => '1',
              'two'   => '2',
              'three' => '3'
            },
            japanese: {
              'yon'  => '4',
              'go'   => '5',
              'roku' => '6'
            },
            spanish:  {
              'siete' => '7',
              'ocho'  => '8',
              'nueve' => '9'
            }
          }
        end

        it 'should freeze the hash' do
          expect { instance.deep_freeze hsh }
            .to change(hsh, :frozen?)
            .to be true
        end

        it 'should freeze the hash keys' do
          instance.deep_freeze hsh

          expect(hsh.keys.all?(&:frozen?)).to be true
        end

        it 'should freeze the hash values' do
          instance.deep_freeze hsh

          expect(hsh.values.all?(&:frozen?)).to be true
        end
      end
    end

    shared_examples 'should test if the hash is immutable' do
      describe 'with a hash with mutable keys' do
        let(:key_class) { Struct.new :value }
        let(:hsh) do
          {
            key_class.new(+'foo') => +'foo',
            key_class.new(+'bar') => +'bar',
            key_class.new(+'baz') => +'baz'
          }
        end

        it { expect(instance.immutable? hsh).to be false }

        context 'when the hash is frozen' do
          include_context 'when the hash is frozen'

          it { expect(instance.immutable? hsh).to be false }

          context 'when the hash keys are frozen' do
            include_context 'when the hash keys are frozen'

            it { expect(instance.immutable? hsh).to be false }
          end

          context 'when the hash values are frozen' do
            include_context 'when the hash values are frozen'

            it { expect(instance.immutable? hsh).to be false }
          end

          context 'when the hash keys and values are frozen' do
            include_context 'when the hash keys are frozen'
            include_context 'when the hash values are frozen'

            it { expect(instance.immutable? hsh).to be true }
          end
        end
      end

      describe 'with a hash with string keys' do
        let(:hsh) { { 'foo' => +'foo', 'bar' => +'bar', 'baz' => +'baz' } }

        it { expect(instance.immutable? hsh).to be false }

        context 'when the hash is frozen' do
          include_context 'when the hash is frozen'

          it { expect(instance.immutable? hsh).to be false }

          context 'when the hash values are frozen' do
            include_context 'when the hash values are frozen'

            it { expect(instance.immutable? hsh).to be true }
          end
        end
      end

      describe 'with a hash with symbol keys' do
        let(:hsh) { { foo: +'foo', bar: +'bar', baz: +'baz' } }

        it { expect(instance.immutable? hsh).to be false }

        context 'when the hash is frozen' do
          include_context 'when the hash is frozen'

          it { expect(instance.immutable? hsh).to be false }

          context 'when the hash values are frozen' do
            include_context 'when the hash values are frozen'

            it { expect(instance.immutable? hsh).to be true }
          end
        end
      end

      describe 'with a hash with hash values' do
        let(:hsh) do
          {
            english:  {
              'one'   => +'1',
              'two'   => +'2',
              'three' => +'3'
            },
            japanese: {
              'yon'  => +'4',
              'go'   => +'5',
              'roku' => +'6'
            },
            spanish:  {
              'siete' => +'7',
              'ocho'  => +'8',
              'nueve' => +'9'
            }
          }
        end

        it { expect(instance.immutable? hsh).to be false }

        context 'when the hash is frozen' do
          include_context 'when the hash is frozen'

          it { expect(instance.immutable? hsh).to be false }

          context 'when the hash values are frozen' do
            include_context 'when the hash values are frozen'

            it { expect(instance.immutable? hsh).to be false }

            context 'when the hash child values are frozen' do
              before(:example) do
                hsh.each { |_, child| child.each { |_, value| value.freeze } }
              end

              it { expect(instance.immutable? hsh).to be true }
            end
          end
        end
      end
    end
  end
end
