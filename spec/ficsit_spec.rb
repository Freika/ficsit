# frozen_string_literal: true

RSpec.describe Ficsit do
  it 'has a version number' do
    expect(Ficsit::VERSION).not_to be nil
  end

  context 'when calculating complex recipe' do # rubocop:disable RSpec/BlockLength
    subject(:calculator) { Ficsit::Calc.new(recipe, amount).call }

    let(:recipe) { 'Motor' }
    let(:amount) { 20 }
    let(:expected_result) do # rubocop:disable Metrics/BlockLength
      {
        name: 'Motor',
        machines: 4.0,
        inputs: [
          [
            { name: 'Rotor', pieces_total: 40.0, machines: 10.0 },
            { name: 'Stator', pieces_total: 40.0, machines: 8.0 }
          ],
          [
            { name: 'Steel Pipe', pieces_total: 120.0, machines: 6.0 },
            { name: 'Wire', pieces_total: 320.0, machines: 10.666666666666666 }
          ],
          [
            { name: 'Copper Ingot', pieces_total: 160.0, machines: 5.333333333333333 }
          ],
          [
            { name: 'Copper', pieces_total: 160.0, machines: 0 }
          ],
          [
            { name: 'Steel Ingot', pieces_total: 180.0, machines: 4.0 }
          ],
          [
            { name: 'Iron', pieces_total: 180.0, machines: 0 },
            { name: 'Coal', pieces_total: 180.0, machines: 0 }
          ],
          [
            { name: 'Iron Rod', pieces_total: 200.0, machines: 13.333333333333334 },
            { name: 'Screws', pieces_total: 1000.0, machines: 25.0 }
          ],
          [
            { name: 'Iron Rod', pieces_total: 250.0, machines: 16.666666666666668 }
          ],
          [
            { name: 'Iron Ingot', pieces_total: 250.00000000000003, machines: 8.333333333333334 }
          ],
          [
            { name: 'Iron', pieces_total: 250.00000000000003, machines: 0 }
          ],
          [
            { name: 'Iron Ingot', pieces_total: 200.0, machines: 6.666666666666667 }
          ],
          [
            { name: 'Iron', pieces_total: 200.0, machines: 0 }
          ]
        ],
        total_data: [
          { name: 'Screws', pieces_total: 1000.0 },
          { name: 'Iron Rod', pieces_total: 450.0 },
          { name: 'Iron Ingot', pieces_total: 450.0 },
          { name: 'Iron', pieces_total: 630.0 },
          { name: 'Copper', pieces_total: 160.0 },
          { name: 'Coal', pieces_total: 180.0 },
          { name: 'Stator', pieces_total: 40.0 },
          { name: 'Rotor', pieces_total: 40.0 },
          { name: 'Wire', pieces_total: 320.0 },
          { name: 'Steel Pipe', pieces_total: 120.0 },
          { name: 'Copper Ingot', pieces_total: 160.0 },
          { name: 'Steel Ingot', pieces_total: 180.0 }
        ]
      }
    end

    it 'returns complete list of resources to be made' do
      expect(subject).to eq(expected_result)
    end
  end
end
