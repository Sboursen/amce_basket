# frozen_string_literal: true

require 'bigdecimal'
require_relative '../../lib/strategies/tiered_delivery_strategy'
require_relative '../../lib/strategies/delivery_rule' # We will create this file next

RSpec.describe TieredDeliveryStrategy do
  subject(:strategy) { described_class.new(rules) }

  let(:rules) do
    [
      DeliveryRule.new(range: (BigDecimal('0')...BigDecimal('50')), cost: 4.95),
      DeliveryRule.new(range: (BigDecimal('50')...BigDecimal('90')), cost: 2.95),
      DeliveryRule.new(range: (BigDecimal('90')..), cost: 0.0)
    ]
  end

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
      expect(strategy.cost_for(BigDecimal('90.00'))).to eq(0.0)
    end

    it 'returns 0.00 for a subtotal above 90.00' do
      expect(strategy.cost_for(BigDecimal('200.00'))).to eq(0.0)
    end

    context 'when no rules match' do
      let(:rules) { [DeliveryRule.new(range: (0...10), cost: 5.00)] }

      it 'returns a default cost of 0.0' do
        expect(strategy.cost_for(BigDecimal('100.00'))).to eq(0.0)
      end
    end
  end
end
