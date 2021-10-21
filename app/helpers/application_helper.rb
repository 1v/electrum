module ApplicationHelper
  def format_balance(balance)
    "%.8f" % (balance.to_f / 100000000)
  end
end
