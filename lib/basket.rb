# frozen_string_literal: true

require 'bigdecimal'
require_relative 'line_item'
require_relative 'discount'

class Basket
  def initialize(product_catalogue, delivery_strategy, offer_strategies)
    @product_catalogue = product_catalogue
    @delivery_strategy = delivery_strategy
    @offer_strategies = offer_strategies
    @line_items = []
  end

  def add(product_code)
    product_data = @product_catalogue.fetch(product_code)

    line_item = LineItem.new(
      code: product_code,
      price: BigDecimal(product_data[:price].to_s)
    )

    @line_items << line_item
  end

  def total
    return BigDecimal('0.0') if @line_items.empty?

    final_ledger = build_final_discount_ledger(@line_items)
    net_subtotal = calculate_net_subtotal(@line_items, final_ledger)

    delivery_cost = BigDecimal(@delivery_strategy.cost_for(net_subtotal).to_s)

    (net_subtotal + delivery_cost).round(2, :truncate)
  end

  private

  def build_final_discount_ledger(line_items)
    final_ledger = Hash.new { |h, k| h[k] = [] }.compare_by_identity

    @offer_strategies.each do |strategy|
      strategy.discounts_for(line_items).each do |item, discounts|
        final_ledger[item].concat(discounts)
      end
    end

    final_ledger
  end

  def calculate_net_subtotal(line_items, final_ledger)
    initial_value = BigDecimal('0.0')

    line_items.sum(initial_value) do |item|
      item_discounts = final_ledger[item]
      total_discount_for_item = item_discounts.sum(initial_value, &:amount)

      item.price - total_discount_for_item
    end
  end
end
