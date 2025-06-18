# frozen_string_literal: true

class BuyOneGetOneHalfPriceStrategy
  def initialize(product_code)
    @product_code = product_code
  end

  def apply_to(line_items)
    eligible_items = line_items.select { |item| item.code == @product_code }

    eligible_items.each_slice(2) do |pair|
      next unless pair.size == 2

      discounted_price = pair.last.price / 2.0
      pair.last.price = discounted_price
    end
  end
end
