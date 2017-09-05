def update_quality(items)
  items.each do |item|
    ItemQualityUpdater.update_quality(item)
  end
end

class ItemQualityUpdater
  def self.update_quality(item)
    get_quality_updater_for(item).update_quality
  end

  private

  def self.get_quality_updater_for(item)
    case item.name
    when /^Backstage/
      BackstagePassQualityUpdater.new(item)
    when /^Aged Brie/
      AgedBrieQualityUpdater.new(item)
    when /^Sulfuras/
      SulfurasQualityUpdater.new(item)
    when /^Conjured/
      ConjuredItemQualityUpdater.new(item)
    else
      NormalItemQualityUpdater.new(item)
    end
  end
end

class BaseItemQualityUpdater
  attr_reader :item, :max_quality, :min_quality

  def initialize(item)
    @item = item
    @max_quality = 50
    @min_quality = 0
  end

  def update_quality
    degrease_sell_in
    set_new_quality
  end

  def degrease_sell_in
    item.sell_in -= 1
  end

  def set_new_quality
    raise NotImplementedError
  end

  def is_after_sell_date?
    item.sell_in < 0
  end

  def increase_quality_by(amount)
    item.quality += amount
    item.quality = max_quality if item.quality > max_quality
  end

  def degrease_quality_by(amount)
    item.quality -= amount
    item.quality = min_quality if item.quality < min_quality
  end
end

class NormalItemQualityUpdater < BaseItemQualityUpdater
  def set_new_quality
    is_after_sell_date? ? degrease_quality_by(2) : degrease_quality_by(1)
  end
end

class ConjuredItemQualityUpdater < BaseItemQualityUpdater
  def set_new_quality
    is_after_sell_date? ? degrease_quality_by(4) : degrease_quality_by(2)
  end
end

class AgedBrieQualityUpdater < BaseItemQualityUpdater
  def set_new_quality
    is_after_sell_date? ? increase_quality_by(2) : increase_quality_by(1)
  end
end

class BackstagePassQualityUpdater < BaseItemQualityUpdater
  def set_new_quality
    if is_after_sell_date?
      item.quality = 0
    elsif is_very_close_to_sell_date?
      increase_quality_by(3)
    elsif is_medium_close_to_sell_date?
      increase_quality_by(2)
    else
      increase_quality_by(1)
    end
  end

  def is_very_close_to_sell_date?
    item.sell_in < 5
  end

  def is_medium_close_to_sell_date?
    item.sell_in < 10
  end
end

class SulfurasQualityUpdater < BaseItemQualityUpdater
  def update_quality
    # does nothing
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

