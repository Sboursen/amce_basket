# frozen_string_literal: true

require 'basket'

RSpec::Matchers.define :be_within_a_cent_of do |expected|
  match { |actual| (actual - expected).abs < 0.01 }
  failure_message do |actual|
    "expected that #{actual} would be within 0.01 of #{expected}"
  end
end

RSpec.describe Basket do
  let(:product_catalogue) do
    {
      'R01' => { name: 'Red Widget', price: 32.95 },
      'G01' => { name: 'Green Widget', price: 24.95 },
      'B01' => { name: 'Blue Widget', price: 7.95 }
    }
  end

  let(:delivery_rules) { { 50 => 4.95, 90 => 2.95, Float::INFINITY => 0 } }
  let(:offers) { [{ type: :bogo_half_price, product_code: 'R01' }] }

  subject(:basket) { Basket.new(product_catalogue, delivery_rules, offers) }

  describe '#add' do
    context 'with an invalid product code' do
      it 'raises an error' do
        expect { basket.add('X99') }.to raise_error(KeyError)
      end
    end
  end
  describe '#total' do
    context 'when the basket is empty' do
      it 'returns a total of 0.00' do
        expect(basket.total).to eq(0.00)
      end
    end
    context 'when the basket contains B01, G01' do
      it 'calculates the total cost correctly' do
        basket.add('B01')
        basket.add('G01')

        expect(basket.total).to be_within_a_cent_of(37.85)
      end
    end

    context 'when the basket contains R01, R01 (triggers offer)' do
      it 'calculates the total cost correctly' do
        basket.add('R01')
        basket.add('R01')

        expect(basket.total).to be_within_a_cent_of(54.37)
      end
    end

    context 'when the basket contains R01, G01' do
      it 'calculates the total cost correctly' do
        basket.add('R01')
        basket.add('G01')

        expect(basket.total).to be_within_a_cent_of(60.85)
      end
    end

    context 'when the basket contains B01, B01, R01, R01, R01' do
      it 'calculates the total cost correctly' do
        basket.add('B01')
        basket.add('B01')
        basket.add('R01')
        basket.add('R01')
        basket.add('R01')

        expect(basket.total).to be_within_a_cent_of(98.27)
      end
    end

    context 'when the BOGO offer applies to multiple pairs' do
      it 'calculates correctly for an even number of items (4)' do
        4.times { basket.add('R01') }
    
        # Item Cost: 2 are full price, 2 are half price.
        # (2 * 32.95) + (2 * 32.95 / 2) = 65.90 + 32.95 = 98.85
        # Delivery Cost: 0 (since subtotal > 90)
        # Total: 98.85
        expect(basket.total).to be_within_a_cent_of(98.85)
      end
    
      it 'calculates correctly for an odd number of items (5)' do
        5.times { basket.add('R01') }
    
        # Item Cost: 3 are full price, 2 are half price.
        # (3 * 32.95) + (2 * 32.95 / 2) = 98.85 + 32.95 = 131.80
        # Delivery Cost: 0 (since subtotal > 90)
        # Total: 131.80
        expect(basket.total).to be_within_a_cent_of(131.80)
      end
    end
  end
end
