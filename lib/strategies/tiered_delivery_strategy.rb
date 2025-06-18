# frozen_string_literal: true

require 'bigdecimal'

class TieredDeliveryStrategy
  def initialize(rules)
    @rules = rules.transform_keys { |key| BigDecimal(key.to_s) }
    @sorted_thresholds = @rules.keys.sort
  end

  def cost_for(subtotal)
    threshold = @sorted_thresholds.find { |limit| subtotal < limit }

    @rules.fetch(threshold, 0)
  end
end
