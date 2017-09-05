# -*- encoding : utf-8 -*-
#
# Calculate amount + 20% tax for a Stripe::Plan
#
# Example
#
#   plan = Stripe::Plan.retrieve('pro')
#   @plan = PlanWithTax.new(plan)
#   @plan.amount
#   # => 833
#   @plan.amount_with_tax
#   # => 1000
class AlaveteliPro::PlanWithTax < SimpleDelegator
  TAX_RATE = BigDecimal('0.20').freeze

  def amount_with_tax
    net = BigDecimal(amount * 0.01, 0).round(2)
    vat = (net * TAX_RATE).round(2)
    gross = net + vat
    (gross * 100).floor
  end
end
