# frozen_string_literal: true

require 'bigdecimal'
require_relative '../../lib/strategies/tiered_delivery_strategy'

RSpec.describe TieredDeliveryStrategy do
  subject(:strategy) { described_class.new(rules) }

  let(:rules) { { 50 => 4.95, 90 => 2.95, Float::INFINITY => 0 } }

  describe '#cost_for' do
    it 'returns 4.95 for subtotals under 50' do
      expect(strategy.cost_for(BigDecimal('49.99'))).to eq(4.95)
    end

    it 'returns 2.95 for a subtotal of exactly 50.00' do
      expect(strategy.cost_for(BigDecimal('50.00'))).to eq(2.95)
    end

    it 'returns 2.95 for a subtotal just under 90.00' do
      expect(strategy.cost_for(BigDecimal('89.99'))).to eq(2.95)
    end

    it 'returns 0.00 for a subtotal of exactly 90.00' do
      expect(strategy.cost_for(BigDecimal('90.00'))).to eq(0)
    end

    it 'returns 0.00 for a subtotal above 90.00' do
      expect(strategy.cost_for(BigDecimal('200.00'))).to eq(0)
    end
  end
end
