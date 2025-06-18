# frozen_string_literal: true

class TieredDeliveryStrategy
  def initialize(rules)
    @rules = rules
    @sorted_thresholds = @rules.keys.sort
  end

  def cost_for(subtotal)
    threshold = @sorted_thresholds.find { |limit| subtotal < limit }
    @rules.fetch(threshold, 0)
  end
end
