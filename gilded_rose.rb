def update_quality(items)
  items.each do |item|
    ItemQualityUpdaterContext.update_quality(item)
  end
end

class ItemQualityUpdaterContext
  def self.update_quality(item)
    context = get_context(item)
    item.extend(context)
    item.update_quality
  end

  private

  def self.get_context(item)
    case item.name
    when /^Backstage/
      BackstagePassItem
    when /^Aged Brie/
      AgedBrieItem
    when /^Sulfuras/
      SulfurasItem
    when /^Conjured/
      ConjuredItem
    else
      NormalItem
    end
  end
end

module NormalItem
  def update_quality
    self.sell_in -= 1

    if self.sell_in < 0
      self.quality -= 2
    else
      self.quality -= 1
    end

    if self.quality < 0
      self.quality = 0
    end
  end
end

module ConjuredItem
  def update_quality
    self.sell_in -= 1

    if self.sell_in < 0
      self.quality -= 4
    else
      self.quality -= 2
    end

    if self.quality < 0
      self.quality = 0
    end
  end
end

module AgedBrieItem
  def update_quality
    self.sell_in -= 1

    self.quality += 1

    if self.sell_in < 0
      self.quality += 1
    end

    if self.quality > 50
      self.quality = 50
    end
  end
end

module BackstagePassItem
  def update_quality
    self.sell_in -= 1

    if self.sell_in < 0
      self.quality = 0
    elsif self.sell_in < 5
      self.quality += 3
    elsif self.sell_in < 10
      self.quality += 2
    else
      self.quality += 1
    end

    if self.quality > 50
      self.quality = 50
    end
  end
end

module SulfurasItem
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

