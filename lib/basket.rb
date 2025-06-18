# frozen_string_literal: true

class Basket
  def initialize(product_catalogue, delivery_rules, offers)
    @product_catalogue = product_catalogue
    @delivery_rules = delivery_rules
    @offers = offers
    @items = []
  end

  def add(product_code)
    @product_catalogue.fetch(product_code)
    @items << product_code
  end

  def total
    return 0.0 if @items.empty?

    post_offer_subtotal = calculate_post_offer_subtotal
    delivery_cost = calculate_delivery_cost(post_offer_subtotal)

    final_total = post_offer_subtotal + delivery_cost
    final_total.truncate(2)
  end

  private

  def calculate_post_offer_subtotal
    raw_subtotal = @items.sum { |code| @product_catalogue.fetch(code)[:price] }
    discount = calculate_total_discount
    raw_subtotal - discount
  end

  def calculate_total_discount
    @offers.sum do |offer|
      case offer[:type]
      when :bogo_half_price
        calculate_bogo_discount_for(offer)
      else
        0
      end
    end
  end

  def calculate_bogo_discount_for(offer)
    product_code = offer.fetch(:product_code)
    item_price = @product_catalogue.fetch(product_code)[:price]
    item_count = @items.count(product_code)

    num_of_pairs = item_count / 2
    discount_per_item = item_price / 2.0
    num_of_pairs * discount_per_item
  end

  def calculate_delivery_cost(subtotal)
    threshold = @delivery_rules.keys.sort.find { |limit| subtotal < limit }
    @delivery_rules.fetch(threshold, 0)
  end
end
