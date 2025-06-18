# frozen_string_literal: true

require_relative '../../lib/strategies/buy_one_get_one_half_price_strategy'
require_relative '../../lib/line_item'

RSpec.describe BuyOneGetOneHalfPriceStrategy do
  subject(:strategy) { described_class.new('R01') }

  let(:red_widget) { LineItem.new(code: 'R01', price: 32.95) }
  let(:another_red_widget) { LineItem.new(code: 'R01', price: 32.95) }
  let(:green_widget) { LineItem.new(code: 'G01', price: 24.95) }

  describe '#discounts_for' do
    it 'returns an empty ledger for an empty list' do
      expect(strategy.discounts_for([])).to be_empty
    end

    it 'returns an empty ledger for a single item' do
      line_items = [red_widget]
      expect(strategy.discounts_for(line_items)).to be_empty
    end

    it 'returns a ledger with a discount for the second item in a pair' do # rubocop:disable RSpec/MultipleExpectations
      line_items = [red_widget, another_red_widget]
      ledger = strategy.discounts_for(line_items)

      # The ledger should have one entry.
      expect(ledger.size).to eq(1)
      # The key should be the second red widget instance.
      expect(ledger).to have_key(another_red_widget)
      # The discount amount should be 50% of the price.
      expect(ledger[another_red_widget].first.amount).to be_within_a_cent_of(16.475)
    end

    it 'does not include non-eligible items in the ledger' do
      line_items = [red_widget, green_widget]
      expect(strategy.discounts_for(line_items)).to be_empty
    end

    it 'correctly creates the ledger when items are mixed' do # rubocop:disable RSpec/MultipleExpectations
      line_items = [red_widget, green_widget, another_red_widget]

      ledger = strategy.discounts_for(line_items)

      expect(ledger.size).to eq(1)
      expect(ledger).to have_key(another_red_widget)
    end

    it 'returns a ledger with two discounted items for four eligible items' do # rubocop:disable RSpec/MultipleExpectations
      line_items = Array.new(4) { LineItem.new(code: 'R01', price: 32.95) }

      ledger = strategy.discounts_for(line_items)

      # The ledger should have entries for two of the items.
      expect(ledger.size).to eq(2)
      # The keys should be the 2nd and 4th items.
      expect(ledger).to have_key(line_items[1])
      expect(ledger).to have_key(line_items[3])
    end
  end
end
