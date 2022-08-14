# frozen_string_literal: true

RSpec.describe Ficsit::Table do
  xcontext 'when calculating complex recipe' do
    subject(:calculator) { described_class.new(recipe, amount).construct_tables }

    let(:recipe) { 'Iron Ingot' }
    let(:amount) { 10 }
    let(:expected_result) do
      <<~TABLE
        ╭────────────────────────────────────────────────╮
        │                    Iron Ingot                  │
        ├────────────────────────┬───────────────────────┤
        │   Iron                 │                  10.0 │
        ├────────────────────────┼───────────────────────┤
        │   Machines             │                  0.33 │
        │   Out Iron Ingot       │                  10.0 │
        ╰────────────────────────┴───────────────────────╯

        ==========================================================
        ╭────────────────────────────────────────────────╮
        │                 Total Resources                │
        ├────────────────────────┬───────────────────────┤
        │   Iron                 │                  10.0 │
        ╰────────────────────────┴───────────────────────╯
      TABLE
    end

    it 'returns formatted tables' do
      expect(subject).to eq(expected_result)
    end
  end
end
