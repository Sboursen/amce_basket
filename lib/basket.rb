# frozen_string_literal: true

require_relative 'line_item'

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
    @offer_strategies.each { |offer| offer.apply_to(line_items) }
    subtotal = line_items.sum(&:price)
    delivery_cost = @delivery_strategy.cost_for(subtotal)
    (subtotal + delivery_cost).truncate(2)
  end

  private

  def build_line_items
    @items.map do |code|
      price = @product_catalogue.fetch(code)[:price]
      LineItem.new(code: code, price: price)
    end
  end
end
