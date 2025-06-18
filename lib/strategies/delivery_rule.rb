# frozen_string_literal: true

class DeliveryRule
  attr_reader :cost

  def initialize(range:, cost:)
    @range = range
    @cost = cost
  end

  def applies_to?(subtotal)
    @range.cover?(subtotal)
  end
end
