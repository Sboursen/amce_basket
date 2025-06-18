# frozen_string_literal: true

require 'bigdecimal'
require_relative '../../lib/strategies/buy_one_get_one_half_price_strategy'
require_relative '../../lib/line_item'
require_relative '../../lib/discount'

RSpec.describe BuyOneGetOneHalfPriceStrategy do
  subject(:strategy) { described_class.new('R01') }

  # Initialize all LineItem prices with BigDecimal for accurate testing.
  let(:red_widget) { LineItem.new(code: 'R01', price: BigDecimal('32.95')) }
  let(:another_red_widget) { LineItem.new(code: 'R01', price: BigDecimal('32.95')) }
  let(:green_widget) { LineItem.new(code: 'G01', price: BigDecimal('24.95')) }

  describe '#discounts_for' do
    it 'returns an empty ledger for an empty list' do
      expect(strategy.discounts_for([])).to be_empty
    end

    it 'returns an empty ledger for a single item' do
      line_items = [red_widget]
      expect(strategy.discounts_for(line_items)).to be_empty
    end

    it 'returns a ledger with a discount for the second item in a pair' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      line_items = [red_widget, another_red_widget]
      ledger = strategy.discounts_for(line_items)

      expected_discount = BigDecimal('32.95') / 2

      expect(ledger.size).to eq(1)
      expect(ledger).to have_key(another_red_widget)
      expect(ledger[another_red_widget].first.amount).to eq(expected_discount)
    end

    it 'does not include non-eligible items in the ledger' do
      line_items = [red_widget, green_widget]
      expect(strategy.discounts_for(line_items)).to be_empty
    end

    it 'returns a ledger with two discounted items for four eligible items' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      price = BigDecimal('32.95')
      line_items = Array.new(4) { LineItem.new(code: 'R01', price: price) }

      ledger = strategy.discounts_for(line_items)

      expect(ledger.size).to eq(2)
      # The keys should be the 2nd and 4th items in the original array.
      expect(ledger).to have_key(line_items[1])
      expect(ledger).to have_key(line_items[3])
    end
  end
end
