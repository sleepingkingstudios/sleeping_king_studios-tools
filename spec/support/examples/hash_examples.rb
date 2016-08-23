# spec/support/examples/hash_examples.rb

require 'support/examples'

module Spec::Examples
  module HashExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the hash is frozen' do
      let(:hsh) { super().freeze }
    end # shared_context

    shared_context 'when the hash keys are frozen' do
      before(:example) do
        hsh.each { |key, _| key.freeze }
      end # before example
    end # shared_context

    shared_context 'when the hash values are frozen' do
      before(:example) do
        hsh.each { |_, value| value.freeze }
      end # before example
    end # shared_context

    shared_examples 'should create a deep copy of a hash' do
      describe 'with a hash with mutable keys' do
        let(:key_class) { Struct.new :value }
        let(:hsh)       { { key_class.new('foo') => 'foo', key_class.new('bar') => 'bar', key_class.new('baz') => 'baz' } }
        let(:cpy)       { instance.deep_dup hsh }

        def normalize hsh
          hsh.each.with_object({}) do |(key, value), copy|
            normalized = key.value.dup

            copy[normalized] = value
          end # each
          hsh.keys.map(&:value).map(&:dup)
        end # method normalize

        it { expect(cpy).to be == hsh }

        it { expect(normalize cpy).to be == normalize(hsh) }

        it 'should return a copy of the hash' do
          expect { cpy[key_class.new 'wibble'] = 'wibble' }.not_to change { normalize hsh }

          expect { cpy[key_class.new 'foo']    = 'FOO' }.not_to change { normalize hsh }
        end # it

        it 'should return a copy of the hash values' do
          expect { cpy[key_class.new 'foo']   << 'wobble' }.not_to change { normalize hsh }
        end # it

        it 'should return a shallow copy of the hash keys' do
          expect {
            cpy.keys.find { |key| key.value == 'foo' }.value << 'wobble'
          }.to change { normalize hsh }
        end # it

        context 'with a defined #deep_dup method' do
          before(:example) do
            key_class.send :define_method, :deep_dup do
              self.class.new(value.dup)
            end # method deep_dup
          end # before example

          it 'should return a deep copy of the hash keys' do
            copy = instance.deep_dup hsh

            expect {
              copy.keys.find { |key| key.value == 'foo' }.value << 'wobble'
            }.not_to change { normalize hsh }
          end # it
        end # context
      end # describe

      describe 'with a hash with string keys' do
        let(:hsh) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }
        let(:cpy) { instance.deep_dup hsh }

        it { expect(cpy).to be == hsh }

        it 'should return a copy of the hash' do
          expect { cpy['wibble'] = 'wibble' }.not_to change { hsh }

          expect { cpy['foo']    = 'FOO' }.not_to change { hsh }
        end # it

        it 'should return a copy of the hash values' do
          expect { cpy['foo']   << 'wobble' }.not_to change { hsh }
        end # it
      end # describe

      describe 'with a hash with symbol keys' do
        let(:hsh) { { :foo => 'foo', :bar => 'bar', :baz => 'baz' } }
        let(:cpy) { instance.deep_dup hsh }

        it { expect(cpy).to be == hsh }

        it 'should return a copy of the hash' do
          expect { cpy[:wibble] = 'wibble' }.not_to change { hsh }

          expect { cpy[:foo]    = 'FOO' }.not_to change { hsh }
        end # it

        it 'should return a copy of the hash values' do
          expect { cpy[:foo]   << 'wobble' }.not_to change { hsh }
        end # it
      end # describe

      describe 'with a hash with hash values' do
        let(:hsh) do
          {
            :english => {
              'one'   => '1',
              'two'   => '2',
              'three' => '3'
            }, # end hash
            :japanese => {
              'yon'  => '4',
              'go'   => '5',
              'roku' => '6'
            }, # end hash
            :spanish => {
              'siete' => '7',
              'ocho'  => '8',
              'nueve' => '9'
            } # end hash
          } # end hash
        end # let
        let(:cpy) { instance.deep_dup hsh }

        it { expect(cpy).to be == hsh }

        it 'should return a copy of the hash' do
          expect { cpy[:german]  = {} }.not_to change { hsh }

          expect { cpy[:english] = {} }.not_to change { hsh }
        end # it

        it 'should return a copy of the child hashes' do
          child = cpy[:english]

          expect { child['ten'] = '10' }.not_to change { hsh }

          expect { child['one'] = '1.0' }.not_to change { hsh }
        end # it

        it 'should return a copy of the child hash values' do
          child = cpy[:english]

          expect { child['one'] << '.0' }.not_to change { hsh }
        end # it
      end # describe
    end # shared_examples

    shared_examples 'should test if the hash is immutable' do
      describe 'with a hash with mutable keys' do
        let(:key_class) { Struct.new :value }
        let(:hsh)       { { key_class.new('foo') => 'foo', key_class.new('bar') => 'bar', key_class.new('baz') => 'baz' } }

        it { expect(instance.immutable? hsh).to be false }

        wrap_context 'when the hash is frozen' do
          it { expect(instance.immutable? hsh).to be false }

          wrap_context 'when the hash keys are frozen' do
            it { expect(instance.immutable? hsh).to be false }
          end # wrap_context

          wrap_context 'when the hash values are frozen' do
            it { expect(instance.immutable? hsh).to be false }
          end # wrap_context

          context 'when the hash keys and values are frozen' do
            include_context 'when the hash keys are frozen'
            include_context 'when the hash values are frozen'

            it { expect(instance.immutable? hsh).to be true }
          end # context
        end # wrap_context
      end # describe

      describe 'with a hash with string keys' do
        let(:hsh) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }

        it { expect(instance.immutable? hsh).to be false }

        wrap_context 'when the hash is frozen' do
          it { expect(instance.immutable? hsh).to be false }

          wrap_context 'when the hash values are frozen' do
            it { expect(instance.immutable? hsh).to be true }
          end # wrap_context
        end # wrap_context
      end # describe

      describe 'with a hash with symbol keys' do
        let(:hsh) { { :foo => 'foo', :bar => 'bar', :baz => 'baz' } }

        it { expect(instance.immutable? hsh).to be false }

        wrap_context 'when the hash is frozen' do
          it { expect(instance.immutable? hsh).to be false }

          wrap_context 'when the hash values are frozen' do
            it { expect(instance.immutable? hsh).to be true }
          end # wrap_context
        end # wrap_context
      end # describe

      describe 'with a hash with hash values' do
        let(:hsh) do
          {
            :english => {
              'one'   => '1',
              'two'   => '2',
              'three' => '3'
            }, # end hash
            :japanese => {
              'yon'  => '4',
              'go'   => '5',
              'roku' => '6'
            }, # end hash
            :spanish => {
              'siete' => '7',
              'ocho'  => '8',
              'nueve' => '9'
            } # end hash
          } # end hash
        end # let

        it { expect(instance.immutable? hsh).to be false }

        wrap_context 'when the hash is frozen' do
          it { expect(instance.immutable? hsh).to be false }

          wrap_context 'when the hash values are frozen' do
            it { expect(instance.immutable? hsh).to be false }

            context 'when the hash child values are frozen' do
              before(:example) do
                hsh.each { |_, child| child.each { |_, value| value.freeze } }
              end # before example

              it { expect(instance.immutable? hsh).to be true }
            end # context
          end # wrap_context
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
