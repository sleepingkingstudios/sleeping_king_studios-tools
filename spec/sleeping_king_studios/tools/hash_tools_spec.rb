# frozen_string_literal: true

require 'sleeping_king_studios/tools/hash_tools'

RSpec.describe SleepingKingStudios::Tools::HashTools do
  subject(:hash_tools) { described_class.new(**constructor_options) }

  shared_context 'when the hash is frozen' do
    let(:hsh) { super().freeze }
  end

  shared_context 'when the hash keys are frozen' do
    before(:example) do
      hsh.each_key(&:freeze)
    end
  end

  shared_context 'when the hash values are frozen' do
    before(:example) do
      hsh.each_value(&:freeze)
    end
  end

  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:toolbelt)
    end
  end

  describe '#convert_keys_to_strings' do
    it 'should define the method' do
      expect(hash_tools)
        .to respond_to(:convert_keys_to_strings)
        .with(1).argument
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:convert_keys_to_strings)
        .with(1).argument
    end

    it 'should alias the method' do
      expect(hash_tools)
        .to have_aliased_method(:convert_keys_to_strings)
        .as(:stringify_keys)
    end

    it 'should define the aliased class method' do
      expect(described_class)
        .to respond_to(:stringify_keys)
        .with(1).argument
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { hash_tools.convert_keys_to_strings nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { hash_tools.convert_keys_to_strings Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an empty hash' do
      let(:hsh) { {} }

      it { expect(hash_tools.convert_keys_to_strings(hsh)).to be_a(Hash) }

      it { expect(hash_tools.convert_keys_to_strings(hsh)).to be_empty }

      it { expect(hash_tools.convert_keys_to_strings(hsh)).not_to be hsh }
    end

    describe 'with a hash with string keys' do
      let(:hsh) { { 'ichi' => 1, 'ni' => 2, 'san' => 3 } }

      it { expect(hash_tools.convert_keys_to_strings(hsh)).to be == hsh }

      it { expect(hash_tools.convert_keys_to_strings(hsh)).not_to be hsh }
    end

    describe 'with a hash with symbol keys' do
      let(:hsh)      { { ichi: 1, ni: 2, san: 3 } }
      let(:expected) { { 'ichi' => 1, 'ni' => 2, 'san' => 3 } }

      it 'should convert the keys to strings' do
        expect(hash_tools.convert_keys_to_strings(hsh)).to be == expected
      end
    end

    describe 'with a hash with nested arrays' do
      let(:hsh) do
        {
          languages: [
            { one:  1, two: 2, three: 3 },
            { ichi: 1, ni:  2, san:   3 },
            { uno:  1, dos: 2, tres:  3 }
          ]
        }
      end
      let(:expected) do
        {
          'languages' => [
            { 'one'  => 1, 'two' => 2, 'three' => 3 },
            { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
            { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
          ]
        }
      end

      it 'should convert the keys to strings' do
        cpy = hash_tools.convert_keys_to_strings(hsh)

        expect(cpy).to be == expected
      end
    end

    describe 'with a hash with nested hashes' do
      let(:hsh) do
        {
          english:  { one:  1, two: 2, three: 3 },
          japanese: { ichi: 1, ni:  2, san:   3 },
          spanish:  { uno:  1, dos: 2, tres:  3 }
        }
      end
      let(:expected) do
        {
          'english'  => { 'one'  => 1, 'two' => 2, 'three' => 3 },
          'japanese' => { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
          'spanish'  => { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
        }
      end

      it 'should convert the keys to strings' do
        cpy = hash_tools.convert_keys_to_strings(hsh)

        expect(cpy).to be == expected
      end
    end
  end

  describe '#convert_keys_to_symbols' do
    it 'should define the method' do
      expect(hash_tools)
        .to respond_to(:convert_keys_to_symbols)
        .with(1).argument
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:convert_keys_to_symbols)
        .with(1).argument
    end

    it 'should alias the method' do
      expect(hash_tools)
        .to have_aliased_method(:convert_keys_to_symbols)
        .as(:symbolize_keys)
    end

    it 'should define the aliased class method' do
      expect(described_class)
        .to respond_to(:symbolize_keys)
        .with(1).argument
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { hash_tools.convert_keys_to_symbols nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { hash_tools.convert_keys_to_symbols Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an empty hash' do
      let(:hsh) { {} }

      it { expect(hash_tools.convert_keys_to_symbols(hsh)).to be_a(Hash) }

      it { expect(hash_tools.convert_keys_to_symbols(hsh)).to be_empty }

      it { expect(hash_tools.convert_keys_to_symbols(hsh)).not_to be hsh }
    end

    describe 'with a hash with string keys' do
      let(:hsh)      { { 'ichi' => 1, 'ni' => 2, 'san' => 3 } }
      let(:expected) { { ichi: 1, ni: 2, san: 3 } }

      it 'should convert the keys to symbols' do
        cpy = hash_tools.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end
    end

    describe 'with a hash with symbol keys' do
      let(:hsh) { { ichi: 1, ni: 2, san: 3 } }

      it { expect(hash_tools.convert_keys_to_symbols(hsh)).to be == hsh }

      it { expect(hash_tools.convert_keys_to_symbols(hsh)).not_to be hsh }
    end

    describe 'with a hash with nested arrays' do
      let(:hsh) do
        {
          'languages' => [
            { 'one'  => 1, 'two' => 2, 'three' => 3 },
            { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
            { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
          ]
        }
      end
      let(:expected) do
        {
          languages: [
            { one:  1, two: 2, three: 3 },
            { ichi: 1, ni:  2, san:   3 },
            { uno:  1, dos: 2, tres:  3 }
          ]
        }
      end

      it 'should convert the keys to symbols' do
        cpy = hash_tools.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end
    end

    describe 'with a hash with nested hashes' do
      let(:hsh) do
        {
          'english'  => { 'one'  => 1, 'two' => 2, 'three' => 3 },
          'japanese' => { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
          'spanish'  => { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
        }
      end
      let(:expected) do
        {
          english:  { one:  1, two: 2, three: 3 },
          japanese: { ichi: 1, ni:  2, san:   3 },
          spanish:  { uno:  1, dos: 2, tres:  3 }
        }
      end

      it 'should convert the keys to symbols' do
        cpy = hash_tools.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end
    end
  end

  describe '#deep_dup' do
    it { expect(hash_tools).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { hash_tools.deep_dup nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { hash_tools.deep_dup Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with a hash with mutable keys' do
      let(:key_class) { Struct.new :value }
      let(:hsh) do
        {
          key_class.new(+'foo') => 'foo',
          key_class.new(+'bar') => 'bar',
          key_class.new(+'baz') => 'baz'
        }
      end
      let(:cpy) { hash_tools.deep_dup hsh }

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
          copy = hash_tools.deep_dup hsh

          expect do
            copy.keys.find { |key| key.value == 'foo' }.value << 'wobble'
          end.not_to(change { normalize hsh })
        end
      end
    end

    describe 'with a hash with string keys' do
      let(:hsh) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }
      let(:cpy) { hash_tools.deep_dup hsh }

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
      let(:cpy) { hash_tools.deep_dup hsh }

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
      let(:cpy) { hash_tools.deep_dup hsh }

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

  describe '#deep_freeze' do
    it { expect(hash_tools).to respond_to(:deep_freeze).with(1).argument }

    it { expect(described_class).to respond_to(:deep_freeze).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { hash_tools.deep_freeze nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { hash_tools.deep_freeze Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

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
        expect { hash_tools.deep_freeze hsh }
          .to change(hsh, :frozen?)
          .to be true
      end

      it 'should freeze the hash keys' do
        hash_tools.deep_freeze hsh

        expect(hsh.keys.all?(&:frozen?)).to be true
      end

      it 'should freeze the hash values' do
        hash_tools.deep_freeze hsh

        expect(hsh.values.all?(&:frozen?)).to be true
      end
    end

    describe 'with a hash with string keys' do
      let(:hsh) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }

      it 'should freeze the hash' do
        expect { hash_tools.deep_freeze hsh }
          .to change(hsh, :frozen?)
          .to be true
      end

      it 'should freeze the hash keys' do
        hash_tools.deep_freeze hsh

        expect(hsh.keys.all?(&:frozen?)).to be true
      end

      it 'should freeze the hash values' do
        hash_tools.deep_freeze hsh

        expect(hsh.values.all?(&:frozen?)).to be true
      end
    end

    describe 'with a hash with symbol keys' do
      let(:hsh) { { foo: 'foo', bar: 'bar', baz: 'baz' } }

      it 'should freeze the hash' do
        expect { hash_tools.deep_freeze hsh }
          .to change(hsh, :frozen?)
          .to be true
      end

      it 'should freeze the hash keys' do
        hash_tools.deep_freeze hsh

        expect(hsh.keys.all?(&:frozen?)).to be true
      end

      it 'should freeze the hash values' do
        hash_tools.deep_freeze hsh

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
        expect { hash_tools.deep_freeze hsh }
          .to change(hsh, :frozen?)
          .to be true
      end

      it 'should freeze the hash keys' do
        hash_tools.deep_freeze hsh

        expect(hsh.keys.all?(&:frozen?)).to be true
      end

      it 'should freeze the hash values' do
        hash_tools.deep_freeze hsh

        expect(hsh.values.all?(&:frozen?)).to be true
      end
    end
  end

  # rubocop:disable RSpec/NestedGroups
  describe '#fetch' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:fetch)
        .with(2..3).arguments
        .and_keywords(:indifferent_key)
        .and_a_block
    end

    it 'should define the method' do
      expect(hash_tools)
        .to respond_to(:fetch)
        .with(2..3).arguments
        .and_keywords(:indifferent_key)
        .and_a_block
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { hash_tools.fetch(nil, :name) }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { hash_tools.fetch(Object.new.freeze, :name) }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with a Hash' do
      let(:author)     { Data.define(:name) }
      let(:author_key) { author.new(name: 'J.R.R. Tolkien') }
      let(:hsh) do
        {
          author_key => 'J.R.R. Tolkien',
          :name      => 'The Hobbit',
          'slug'     => 'the-hobbit',
          'topic'    => 'hobbits',
          :topic     => :goblins
        }
      end

      describe 'with an invalid Object key' do
        let(:invalid_key) { author.new(name: 'Ursula K. LeGuin') }
        let(:error_message) do
          "key not found: #{invalid_key.inspect}"
        end

        it 'should raise an error' do
          expect { hash_tools.fetch(hsh, invalid_key) }
            .to raise_error KeyError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(key) { "missing key #{key.inspect}" } }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, &default))
              .to be == "missing key #{invalid_key.inspect}"
          end
        end

        describe 'with default: value' do
          let(:default) { 'missing key' }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, default)).to be == default
          end
        end
      end

      describe 'with an invalid String key' do
        let(:invalid_key) { 'publisher' }
        let(:error_message) do
          "key not found: #{invalid_key.inspect}"
        end

        it 'should raise an error' do
          expect { hash_tools.fetch(hsh, invalid_key) }
            .to raise_error KeyError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(key) { "missing key #{key.inspect}" } }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, &default))
              .to be == "missing key #{invalid_key.inspect}"
          end
        end

        describe 'with default: value' do
          let(:default) { 'missing key' }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, default)).to be == default
          end
        end

        context 'when the equivalent Symbol key is defined' do
          let(:invalid_key) { 'name' }

          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, &default))
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, default))
                .to be == default
            end
          end
        end

        describe 'with indifferent_key: true' do
          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key, indifferent_key: true) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  indifferent_key: true,
                  &default
                )
              )
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  default,
                  indifferent_key: true
                )
              ).to be == default
            end
          end

          context 'when the equivalent Symbol key is defined' do
            let(:invalid_key) { 'name' }

            it 'should return the value for the Symbol key' do
              expect(hash_tools.fetch(hsh, invalid_key, indifferent_key: true))
                .to be == 'The Hobbit'
            end
          end
        end
      end

      describe 'with an invalid Symbol key' do
        let(:invalid_key) { :publisher }
        let(:error_message) do
          "key not found: #{invalid_key.inspect}"
        end

        it 'should raise an error' do
          expect { hash_tools.fetch(hsh, invalid_key) }
            .to raise_error KeyError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(key) { "missing key #{key.inspect}" } }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, &default))
              .to be == "missing key #{invalid_key.inspect}"
          end
        end

        describe 'with default: value' do
          let(:default) { 'missing key' }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, default)).to be == default
          end
        end

        context 'when the equivalent String key is defined' do
          let(:invalid_key) { :slug }

          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, &default))
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, default))
                .to be == default
            end
          end
        end

        describe 'with indifferent_key: true' do
          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key, indifferent_key: true) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  indifferent_key: true,
                  &default
                )
              )
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  default,
                  indifferent_key: true
                )
              ).to be == default
            end
          end

          context 'when the equivalent String key is defined' do
            let(:invalid_key) { :slug }

            it 'should return the value for the String key' do
              expect(hash_tools.fetch(hsh, invalid_key, indifferent_key: true))
                .to be == 'the-hobbit'
            end
          end
        end
      end

      describe 'with a valid Object key' do
        it 'should retrieve the value' do
          expect(hash_tools.fetch(hsh, author_key)).to be == 'J.R.R. Tolkien'
        end
      end

      describe 'with a valid String key' do
        it 'should retrieve the value' do
          expect(hash_tools.fetch(hsh, 'slug')).to be == 'the-hobbit'
        end

        describe 'with indifferent_key: true' do
          it 'should retrieve the value' do
            expect(hash_tools.fetch(hsh, 'topic', indifferent_key: true))
              .to be == 'hobbits'
          end
        end
      end

      describe 'with a valid Symbol key' do
        it 'should retrieve the value' do
          expect(hash_tools.fetch(hsh, :name)).to be == 'The Hobbit'
        end

        describe 'with indifferent_key: true' do
          it 'should retrieve the value' do
            expect(hash_tools.fetch(hsh, :topic, indifferent_key: true))
              .to be == :goblins
          end
        end
      end
    end

    describe 'with a Hash-like object' do
      let(:author)     { Data.define(:name) }
      let(:author_key) { author.new(name: 'J.R.R. Tolkien') }
      let(:hsh) do
        Spec::HashLike.new(
          {
            author_key => 'J.R.R. Tolkien',
            :name      => 'The Hobbit',
            'slug'     => 'the-hobbit',
            'topic'    => 'hobbits',
            :topic     => :goblins
          }
        )
      end

      example_class 'Spec::HashLike' do |klass|
        klass.define_method :initialize do |data|
          @data = data
        end

        klass.attr_reader :data

        klass.define_method :[] do |key|
          data[key]
        end

        klass.define_method :count do
          # :nocov:
          data.count
          # :nocov:
        end

        klass.define_method :each do |&block|
          # :nocov:
          data.each(&block)
          # :nocov:
        end

        klass.define_method :each_key do |&block|
          # :nocov:
          data.each_key(&block)
          # :nocov:
        end

        klass.define_method :each_pair do |&block|
          # :nocov:
          data.each_pair(&block)
          # :nocov:
        end

        klass.define_method :key? do |key|
          data.key?(key)
        end
      end

      describe 'with an invalid Object key' do
        let(:invalid_key) { author.new(name: 'Ursula K. LeGuin') }
        let(:error_message) do
          "key not found: #{invalid_key.inspect}"
        end

        it 'should raise an error' do
          expect { hash_tools.fetch(hsh, invalid_key) }
            .to raise_error KeyError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(key) { "missing key #{key.inspect}" } }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, &default))
              .to be == "missing key #{invalid_key.inspect}"
          end
        end

        describe 'with default: value' do
          let(:default) { 'missing key' }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, default)).to be == default
          end
        end
      end

      describe 'with an invalid String key' do
        let(:invalid_key) { 'publisher' }
        let(:error_message) do
          "key not found: #{invalid_key.inspect}"
        end

        it 'should raise an error' do
          expect { hash_tools.fetch(hsh, invalid_key) }
            .to raise_error KeyError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(key) { "missing key #{key.inspect}" } }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, &default))
              .to be == "missing key #{invalid_key.inspect}"
          end
        end

        describe 'with default: value' do
          let(:default) { 'missing key' }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, default)).to be == default
          end
        end

        context 'when the equivalent Symbol key is defined' do
          let(:invalid_key) { 'name' }

          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, &default))
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, default))
                .to be == default
            end
          end
        end

        describe 'with indifferent_key: true' do
          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key, indifferent_key: true) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  indifferent_key: true,
                  &default
                )
              )
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  default,
                  indifferent_key: true
                )
              ).to be == default
            end
          end

          context 'when the equivalent Symbol key is defined' do
            let(:invalid_key) { 'name' }

            it 'should return the value for the Symbol key' do
              expect(hash_tools.fetch(hsh, invalid_key, indifferent_key: true))
                .to be == 'The Hobbit'
            end
          end
        end
      end

      describe 'with an invalid Symbol key' do
        let(:invalid_key) { :publisher }
        let(:error_message) do
          "key not found: #{invalid_key.inspect}"
        end

        it 'should raise an error' do
          expect { hash_tools.fetch(hsh, invalid_key) }
            .to raise_error KeyError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(key) { "missing key #{key.inspect}" } }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, &default))
              .to be == "missing key #{invalid_key.inspect}"
          end
        end

        describe 'with default: value' do
          let(:default) { 'missing key' }

          it 'should return the default value' do
            expect(hash_tools.fetch(hsh, invalid_key, default)).to be == default
          end
        end

        context 'when the equivalent String key is defined' do
          let(:invalid_key) { :slug }

          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, &default))
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do
              expect(hash_tools.fetch(hsh, invalid_key, default))
                .to be == default
            end
          end
        end

        describe 'with indifferent_key: true' do
          it 'should raise an error' do
            expect { hash_tools.fetch(hsh, invalid_key, indifferent_key: true) }
              .to raise_error KeyError, error_message
          end

          describe 'with default: block' do
            let(:default) { ->(key) { "missing key #{key.inspect}" } }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  indifferent_key: true,
                  &default
                )
              )
                .to be == "missing key #{invalid_key.inspect}"
            end
          end

          describe 'with default: value' do
            let(:default) { 'missing key' }

            it 'should return the default value' do # rubocop:disable RSpec/ExampleLength
              expect(
                hash_tools.fetch(
                  hsh,
                  invalid_key,
                  default,
                  indifferent_key: true
                )
              ).to be == default
            end
          end

          context 'when the equivalent String key is defined' do
            let(:invalid_key) { :slug }

            it 'should return the value for the String key' do
              expect(hash_tools.fetch(hsh, invalid_key, indifferent_key: true))
                .to be == 'the-hobbit'
            end
          end
        end
      end

      describe 'with a valid Object key' do
        it 'should retrieve the value' do
          expect(hash_tools.fetch(hsh, author_key)).to be == 'J.R.R. Tolkien'
        end
      end

      describe 'with a valid String key' do
        it 'should retrieve the value' do
          expect(hash_tools.fetch(hsh, 'slug')).to be == 'the-hobbit'
        end

        describe 'with indifferent_key: true' do
          it 'should retrieve the value' do
            expect(hash_tools.fetch(hsh, 'topic', indifferent_key: true))
              .to be == 'hobbits'
          end
        end
      end

      describe 'with a valid Symbol key' do
        it 'should retrieve the value' do
          expect(hash_tools.fetch(hsh, :name)).to be == 'The Hobbit'
        end

        describe 'with indifferent_key: true' do
          it 'should retrieve the value' do
            expect(hash_tools.fetch(hsh, :topic, indifferent_key: true))
              .to be == :goblins
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups

  describe '#generate_binding' do
    it { expect(hash_tools).to respond_to(:generate_binding).with(1).argument }

    it 'should define the method' do
      expect(described_class).to respond_to(:generate_binding).with(1).argument
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { hash_tools.generate_binding nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an empty hash' do
      it { expect(hash_tools.generate_binding({})).to be_a Binding }
    end

    describe 'with a hash with values' do
      let(:hash) do
        {
          first:  1,
          second: 'a String',
          third:  Object.new
        }
      end

      it { expect(hash_tools.generate_binding(hash)).to be_a Binding }

      it 'should bind the hash values', :aggregate_failures do
        binding = hash_tools.generate_binding(hash)

        hash.each do |key, value|
          expect(binding.local_variable_defined?(key)).to be true
          expect(binding.local_variable_get(key)).to be == value
        end
      end
    end
  end

  describe '#hash?' do
    it { expect(hash_tools).to respond_to(:hash?).with(1).argument }

    it { expect(described_class).to respond_to(:hash?).with(1).argument }

    describe 'with nil' do
      it { expect(hash_tools.hash? nil).to be false }
    end

    describe 'with an object' do
      it { expect(hash_tools.hash? Object.new).to be false }
    end

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:title) }
      let(:struct)       { struct_class.new 'The Art of War' }

      it { expect(hash_tools.hash? struct).to be false }
    end

    describe 'with a string' do
      it { expect(hash_tools.hash? 'greetings,programs').to be false }
    end

    describe 'with an integer' do
      it { expect(hash_tools.hash? 42).to be false }
    end

    describe 'with an empty array' do
      it { expect(hash_tools.hash? []).to be false }
    end

    describe 'with a non-empty array' do
      it { expect(hash_tools.hash? %w[ichi ni san]).to be false }
    end

    describe 'with an empty hash' do
      it { expect(hash_tools.hash?({})).to be true }
    end

    describe 'with a non-empty hash' do
      it { expect(hash_tools.hash?({ greetings: 'programs' })).to be true }
    end

    describe 'with a hash-like object' do
      let(:hash_like) do
        Spec::ExampleHash.new({ greetings: 'programs' })
      end

      example_class 'Spec::ExampleHash', Struct.new(:data) do |klass|
        klass.extend Forwardable

        klass.def_delegators :data,
          :[],
          :count,
          :each,
          :each_key,
          :each_pair
      end

      it { expect(hash_tools.hash?(hash_like)).to be true }
    end
  end

  describe '#immutable?' do
    it { expect(hash_tools).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { hash_tools.immutable? nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { hash_tools.immutable? Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with a hash with mutable keys' do
      let(:key_class) { Struct.new :value }
      let(:hsh) do
        {
          key_class.new(+'foo') => +'foo',
          key_class.new(+'bar') => +'bar',
          key_class.new(+'baz') => +'baz'
        }
      end

      it { expect(hash_tools.immutable? hsh).to be false }

      context 'when the hash is frozen' do
        include_context 'when the hash is frozen'

        it { expect(hash_tools.immutable? hsh).to be false }

        context 'when the hash keys are frozen' do
          include_context 'when the hash keys are frozen'

          it { expect(hash_tools.immutable? hsh).to be false }
        end

        context 'when the hash values are frozen' do
          include_context 'when the hash values are frozen'

          it { expect(hash_tools.immutable? hsh).to be false }
        end

        context 'when the hash keys and values are frozen' do
          include_context 'when the hash keys are frozen'
          include_context 'when the hash values are frozen'

          it { expect(hash_tools.immutable? hsh).to be true }
        end
      end
    end

    describe 'with a hash with string keys' do
      let(:hsh) { { 'foo' => +'foo', 'bar' => +'bar', 'baz' => +'baz' } }

      it { expect(hash_tools.immutable? hsh).to be false }

      context 'when the hash is frozen' do
        include_context 'when the hash is frozen'

        it { expect(hash_tools.immutable? hsh).to be false }

        context 'when the hash values are frozen' do
          include_context 'when the hash values are frozen'

          it { expect(hash_tools.immutable? hsh).to be true }
        end
      end
    end

    describe 'with a hash with symbol keys' do
      let(:hsh) { { foo: +'foo', bar: +'bar', baz: +'baz' } }

      it { expect(hash_tools.immutable? hsh).to be false }

      context 'when the hash is frozen' do
        include_context 'when the hash is frozen'

        it { expect(hash_tools.immutable? hsh).to be false }

        context 'when the hash values are frozen' do
          include_context 'when the hash values are frozen'

          it { expect(hash_tools.immutable? hsh).to be true }
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

      it { expect(hash_tools.immutable? hsh).to be false }

      context 'when the hash is frozen' do
        include_context 'when the hash is frozen'

        it { expect(hash_tools.immutable? hsh).to be false }

        context 'when the hash values are frozen' do
          include_context 'when the hash values are frozen'

          it { expect(hash_tools.immutable? hsh).to be false }

          context 'when the hash child values are frozen' do # rubocop:disable RSpec/NestedGroups
            before(:example) do
              hsh.each_value { |child| child.each_value(&:freeze) }
            end

            it { expect(hash_tools.immutable? hsh).to be true }
          end
        end
      end
    end
  end

  describe '#mutable?' do
    let(:hsh) { {} }

    it { expect(hash_tools).to respond_to(:mutable?).with(1).argument }

    it { expect(described_class).to respond_to(:mutable?).with(1).argument }

    it 'should delegate to #immutable?' do
      allow(hash_tools).to receive(:immutable?) # rubocop:disable RSpec/SubjectStub

      hash_tools.mutable?(hsh)

      expect(hash_tools).to have_received(:immutable?).with(hsh) # rubocop:disable RSpec/SubjectStub
    end

    describe 'with an immutable Hash' do
      let(:hsh) { super().freeze }

      it { expect(hash_tools.mutable?(hsh)).to be false }
    end

    describe 'with a mutable Hash' do
      it { expect(hash_tools.mutable?(hsh)).to be true }
    end
  end

  describe '#toolbelt' do
    let(:expected) { SleepingKingStudios::Tools::Toolbelt.global }

    it { expect(hash_tools.toolbelt).to be expected }

    it { expect(hash_tools).to have_aliased_method(:toolbelt).as(:tools) }

    context 'when initialized with toolbelt: value' do
      let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.new }
      let(:constructor_options) do
        super().merge(toolbelt:)
      end

      it { expect(hash_tools.toolbelt).to be toolbelt }
    end
  end
end
