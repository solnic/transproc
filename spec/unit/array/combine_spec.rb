require 'spec_helper'

describe Transproc::ArrayTransformations do
  describe '.combine' do
    subject(:result) { described_class.t(:combine, mappings)[input] }

    let(:input) { [[]] }
    let(:mappings) { [] }

    it { is_expected.to be_a(Array) }

    it { is_expected.to eq([]) }

    context 'without groups' do
      let(:input) do
        [
          [
            {name: 'Jane', email: 'jane@doe.org'}.freeze,
            {name: 'Joe', email: 'joe@doe.org'}.freeze
          ].freeze
        ].freeze
      end

      it { is_expected.to eq input.first }
    end

    context 'with one group' do
      let(:input) do
        [
          [
            {name: 'Jane', email: 'jane@doe.org'}.freeze,
            {name: 'Joe', email: 'joe@doe.org'}.freeze
          ].freeze,
          [
            [
              {user: 'Jane', title: 'One'}.freeze,
              {user: 'Jane', title: 'Two'}.freeze,
              {user: 'Joe', title: 'Three'}.freeze
            ]
          ]
        ].freeze
      end
      let(:mappings) { [[:tasks, {name: :user}]] }

      it 'merges hashes from arrays using provided join keys' do
        output = [
          {name: 'Jane', email: 'jane@doe.org', tasks: [
            {user: 'Jane', title: 'One'},
            {user: 'Jane', title: 'Two'}
          ]},
          {name: 'Joe', email: 'joe@doe.org', tasks: [
            {user: 'Joe', title: 'Three'}
          ]}
        ]
        is_expected.to eql(output)
      end
    end

    context 'with empty nodes' do
      let(:input) do
        [
          [{name: 'Jane', email: 'jane@doe.org'}.freeze].freeze,
          [
            []
          ]
        ].freeze
      end

      let(:mappings) { [[:tasks, {name: :user}]] }

      it { is_expected.to eq([{name: 'Jane', email: 'jane@doe.org', tasks: []}]) }
    end

    context 'with double mapping' do
      let(:input) do
        [
          [
            {name: 'Jane', email: 'jane@doe.org'}.freeze
          ].freeze,
          [
            [
              {user: 'Jane', user_email: 'jane@doe.org', title: 'One'}.freeze,
              {user: 'Jane', user_email: '', title: 'Two'}.freeze
            ].freeze
          ].freeze
        ].freeze
      end

      let(:mappings) { [[:tasks, {name: :user, email: :user_email}]] }

      it 'searches by two keys simultaneously' do
        output = [
          {name: 'Jane', email: 'jane@doe.org', tasks: [
            {user: 'Jane', user_email: 'jane@doe.org', title: 'One'}
          ]}
        ]
        is_expected.to eql(output)
      end
    end

    context 'with empty array' do
      let(:input) do
        []
      end

      let(:mappings) { [[:page, {page_id: :id}]] }

      it { is_expected.to eq [] }
    end

    context 'with empty nested array' do
      let(:input) do
        [
          [],
          [
            []
          ]
        ]
      end

      let(:mappings) { [[:menu_items, {id: :menu_id}, [[:page, {page_id: :id}]]]] }

      it 'does not crash' do
        expect { result }.not_to raise_error
      end
    end

    describe 'integration test' do
      let(:input) do
        [
          [
            {name: 'Jane', email: 'jane@doe.org'},
            {name: 'Joe', email: 'joe@doe.org'}
          ],
          [
            [
              # user tasks
              [
                {user: 'Jane', title: 'One'},
                {user: 'Jane', title: 'Two'},
                {user: 'Joe', title: 'Three'}
              ],
              [
                # task tags
                [
                  {task: 'One', tag: 'red'},
                  {task: 'Three', tag: 'blue'}
                ]
              ]
            ]
          ]
        ]
      end

      let(:mappings) { [[:tasks, {name: :user}, [[:tags, title: :task]]]] }

      it 'merges hashes from arrays using provided join keys' do
        output = [
          {name: 'Jane', email: 'jane@doe.org', tasks: [
            {user: 'Jane', title: 'One', tags: [{task: 'One', tag: 'red'}]},
            {user: 'Jane', title: 'Two', tags: []}
          ]},
          {
            name: 'Joe', email: 'joe@doe.org', tasks: [
              {
                user: 'Joe', title: 'Three', tags: [
                  {task: 'Three', tag: 'blue'}
                ]
              }
            ]
          }
        ]
        is_expected.to eql(output)
      end
    end
  end
end
