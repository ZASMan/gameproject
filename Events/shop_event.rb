require_relative '../broadcast'

class ShopEvent
  include Broadcast

  def initialize(shopName)
    @shopName = shopName
  end

  def act
    broadcast "Shop: Welcome to #{@shopName}."

  end
end