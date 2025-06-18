# frozen_string_literal: true

require_relative '../../lib/strategies/buy_one_get_one_half_price_strategy'
require_relative '../../lib/line_item'

RSpec.describe BuyOneGetOneHalfPriceStrategy do
  subject(:strategy) { described_class.new('R01') }

  let(:red_widget) { LineItem.new(code: 'R01', price: 32.95) }
  let(:another_red_widget) { LineItem.new(code: 'R01', price: 32.95) }
  let(:green_widget) { LineItem.new(code: 'G01', price: 24.95) }

  describe '#apply_to' do
    it 'does nothing to an empty list of items' do
      line_items = []
      strategy.apply_to(line_items)
      expect(line_items).to be_empty
    end

    it 'does not apply a discount for a single item' do
      line_items = [red_widget]
      strategy.apply_to(line_items)

      expect(line_items.first.price).to be_within_a_cent_of(red_widget.price)
    end

    it 'applies a 50% discount to the second item' do
      line_items = [red_widget, another_red_widget]
      strategy.apply_to(line_items)

      expected_discounted_price = red_widget.price / 2.0
      expect(line_items.last.price).to be_within_a_cent_of(expected_discounted_price)
    end

    it 'applies the discount for every pair (e.g., 4 items)' do
      line_items = Array.new(4) { LineItem.new(code: 'R01', price: red_widget.price) }
      strategy.apply_to(line_items)

      discounted_items = line_items.select { |item| item.price < red_widget.price }
      expect(discounted_items.count).to eq(2)
    end

    it 'does not discount items with different product codes' do
      line_items = [red_widget, green_widget, another_red_widget]
      strategy.apply_to(line_items)

      expect(line_items.find { |li| li.code == 'G01' }.price).to eq(green_widget.price)
    end

    it 'still applies discount to matching items when mixed with other products' do
      line_items = [red_widget, green_widget, another_red_widget]
      strategy.apply_to(line_items)

      expected_discounted_price = red_widget.price / 2.0
      expect(line_items.last.price).to be_within_a_cent_of(expected_discounted_price)
    end
  end
end
