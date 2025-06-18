# frozen_string_literal: true

require_relative 'delivery_rule'

class TieredDeliveryStrategy
  def initialize(rules)
    @rules = rules
  end

  def cost_for(subtotal)
    matching_rule = @rules.find { |rule| rule.applies_to?(subtotal) }

    matching_rule ? matching_rule.cost : 0.0
  end
end
