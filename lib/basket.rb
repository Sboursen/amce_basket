# frozen_string_literal: true

require_relative 'line_item'
require_relative 'discount'

class Basket
  def initialize(product_catalogue, delivery_strategy, offer_strategies)
    @product_catalogue = product_catalogue
    @delivery_strategy = delivery_strategy
    @offer_strategies = offer_strategies
    @items = []
  end

  def add(product_code)
    @product_catalogue.fetch(product_code)
    @items << product_code
  end

  def total
    return 0.0 if @items.empty?

    line_items = build_line_items
    final_ledger = build_final_discount_ledger(line_items)

    net_subtotal = calculate_net_subtotal(line_items, final_ledger)
    delivery_cost = @delivery_strategy.cost_for(net_subtotal)

    (net_subtotal + delivery_cost).truncate(2)
  end

  private

  def build_line_items
    @items.map do |code|
      price = @product_catalogue.fetch(code)[:price]
      LineItem.new(code: code, price: price)
    end
  end

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
    line_items.sum do |item|
      item_discounts = final_ledger[item]
      total_discount_for_item = item_discounts.sum(&:amount)

      item.price - total_discount_for_item
    end
  end
end
