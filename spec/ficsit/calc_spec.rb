# frozen_string_literal: true

RSpec.describe Ficsit::Calc do
  it 'has a version number' do
    expect(Ficsit::VERSION).not_to be nil
  end

  context 'when calculating complex recipe' do
    subject(:calculator) { described_class.new(recipe, amount).call }

    let(:recipe) { 'Motor' }
    let(:amount) { 20 }
    let(:expected_result) do
      JSON.parse(File.read('spec/fixtures/calc/motor.json'), symbolize_names: true)
    end

    it 'returns complete list of resources to be made' do
      expect(subject).to eq(expected_result)
    end
  end
end
