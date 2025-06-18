# frozen_string_literal: true

require_relative '../lib/basket'
require_relative '../lib/strategies/tiered_delivery_strategy'
require_relative '../lib/strategies/buy_one_get_one_half_price_strategy'
require_relative '../lib/discount'

RSpec.describe Basket do
  let(:product_catalogue) do
    {
      'R01' => { name: 'Red Widget', price: 32.95 },
      'G01' => { name: 'Green Widget', price: 24.95 },
      'B01' => { name: 'Blue Widget', price: 7.95 }
    }
  end

  # --- Integration Tests ---
  context 'when testing with real strategies (integration)' do
    subject(:basket) { described_class.new(product_catalogue, delivery_strategy, offer_strategies) }

    let(:delivery_strategy) { TieredDeliveryStrategy.new({ 50 => 4.95, 90 => 2.95, Float::INFINITY => 0 }) }
    let(:offer_strategies) { [BuyOneGetOneHalfPriceStrategy.new('R01')] }

    it 'raises an error when adding an invalid product code' do
      expect { basket.add('X99') }.to raise_error(KeyError)
    end

    context 'with an empty basket' do
      it 'has a total of 0.00' do
        expect(basket.total).to eq(0.00)
      end
    end

    context 'with items B01 and G01' do
      it 'calculates the total cost correctly' do
        basket.add('B01')
        basket.add('G01')
        expect(basket.total).to be_within_a_cent_of(37.85)
      end
    end

    context 'with two R01 items (triggering BOGO offer)' do
      it 'calculates the total cost correctly' do
        basket.add('R01')
        basket.add('R01')
        expect(basket.total).to be_within_a_cent_of(54.37)
      end
    end

    context 'with items R01 and G01' do
      it 'calculates the total cost correctly' do
        basket.add('R01')
        basket.add('G01')
        expect(basket.total).to be_within_a_cent_of(60.85)
      end
    end

    context 'with a complex basket (B01, B01, R01, R01, R01)' do
      it 'calculates the total cost correctly' do
        %w[B01 B01 R01 R01 R01].each { |code| basket.add(code) }
        expect(basket.total).to be_within_a_cent_of(98.27)
      end
    end
  end

  # --- Unit Tests ---
  context 'when unit testing in isolation with test doubles' do
    subject(:basket) { described_class.new(product_catalogue, delivery_strategy, offer_strategies) }

    let(:product_catalogue) { { 'R01' => { price: 10.00 }, 'G01' => { price: 20.00 } } }
    let(:delivery_strategy) { instance_double(TieredDeliveryStrategy, 'Delivery Strategy') }

    # Use descriptive names for let blocks to improve readability.
    let(:strategy_with_discount) { instance_double(BuyOneGetOneHalfPriceStrategy, 'BOGO Strategy') }
    let(:strategy_without_discount) { instance_double(BuyOneGetOneHalfPriceStrategy, 'Inactive Strategy') }
    let(:offer_strategies) { [strategy_with_discount, strategy_without_discount] }

    it 'correctly orchestrates the calculation flow' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      basket.add('R01')
      basket.add('G01')

      allow(strategy_with_discount).to receive(:discounts_for) do |line_items|
        { line_items.first => [Discount.new(amount: 2.0, description: 'Offer 1')] }
      end
      allow(strategy_without_discount).to receive(:discounts_for).and_return({})

      expect(delivery_strategy).to receive(:cost_for).with(28.00).and_return(4.95) # rubocop:disable RSpec/StubbedMock,RSpec/MessageSpies

      expect(basket.total).to be_within_a_cent_of(32.95)
    end
  end
end
