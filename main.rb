# frozen_string_literal: true

# This script demonstrates how to use the Basket system. It sets up the
# product catalogue and strategies, then runs the example cases provided
# in the coding challenge.

require 'bigdecimal'
require_relative 'lib/basket'
require_relative 'lib/strategies/tiered_delivery_strategy'
require_relative 'lib/strategies/buy_one_get_one_half_price_strategy'
require_relative 'lib/strategies/delivery_rule'

# --- System Configuration ---

# Use strings for prices to ensure accurate BigDecimal conversion
PRODUCT_CATALOGUE = {
  'R01' => { name: 'Red Widget', price: '32.95' },
  'G01' => { name: 'Green Widget', price: '24.95' },
  'B01' => { name: 'Blue Widget', price: '7.95' }
}.freeze

# The delivery strategy is now initialized with an array of explicit rule objects.
# This makes the configuration much clearer and more robust.
DELIVERY_STRATEGY = TieredDeliveryStrategy.new(
  [
    DeliveryRule.new(range: (BigDecimal('0')...BigDecimal('50')), cost: 4.95),
    DeliveryRule.new(range: (BigDecimal('50')...BigDecimal('90')), cost: 2.95),
    DeliveryRule.new(range: (BigDecimal('90')..), cost: 0.0)
  ]
).freeze

OFFER_STRATEGIES = [
  BuyOneGetOneHalfPriceStrategy.new('R01')
].freeze

# --- Demonstration ---

def demonstrate_basket(item_codes)
  basket = Basket.new(PRODUCT_CATALOGUE, DELIVERY_STRATEGY, OFFER_STRATEGIES)
  item_codes.each { |code| basket.add(code) }

  puts format('%-<basket>30s | Total: $%<total>.2f', basket: "Basket: #{item_codes.join(', ')}", total: basket.total)
end

puts 'Acme Widget Co. Basket Examples'
puts '-' * 45

demonstrate_basket(%w[B01 G01])
demonstrate_basket(%w[R01 R01])
demonstrate_basket(%w[R01 G01])
demonstrate_basket(%w[B01 B01 R01 R01 R01])

puts '-' * 45
