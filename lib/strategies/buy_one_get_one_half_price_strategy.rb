# frozen_string_literal: true

require_relative '../discount'

class BuyOneGetOneHalfPriceStrategy
  def initialize(product_code)
    @product_code = product_code
  end

  def discounts_for(line_items)
    ledger = Hash.new { |h, k| h[k] = [] }.compare_by_identity
    eligible_items = find_eligible_items(line_items)

    eligible_items.each_slice(2) do |pair|
      add_discount_for_pair(pair, ledger) if pair.size == 2
    end

    ledger
  end

  private

  def find_eligible_items(line_items)
    line_items.select { |item| item.code == @product_code }
  end

  def add_discount_for_pair(pair, ledger)
    discounted_item = pair.last
    discount_amount = discounted_item.price / 2.0
    discount = Discount.new(amount: discount_amount, description: 'BOGO 50% off')

    ledger[discounted_item] << discount
  end
end
