def update_quality(items)
  items.each do |item|
    ItemQualityUpdater.update_quality(item)
  end
end

class ItemQualityUpdater
  def self.update_quality(item)
    calculator = get_quality_calculator_for(item)
    item.sell_in = calculator.calculate_sell_in(item)
    item.quality = calculator.calculate_quality(item)
  end

  private

  class BaseItemQualityCalculator
    MIN_QUALITY = 0
    MAX_QUALITY = 50

    def calculate_sell_in(item)
      item.sell_in - 1
    end

    def calculate_quality(item)
      raise NotImplentedError
    end

    def increase_quality_by(item, amount)
      quality = item.quality + amount
      quality > MAX_QUALITY ? MAX_QUALITY : quality
    end

    def degrease_quality_by(item, amount)
      quality = item.quality - amount
      quality < MIN_QUALITY ? MIN_QUALITY : quality
    end

    def is_after_sell_date?(item)
      item.sell_in < 0
    end
  end

  class NormalItemQualityCalculator < BaseItemQualityCalculator
    def calculate_quality(item)
      amount = is_after_sell_date?(item) ? 2 : 1
      degrease_quality_by(item, amount)
    end
  end

  class ConjuredItemQualityCalculator < BaseItemQualityCalculator
    def calculate_quality(item)
      amount = is_after_sell_date?(item) ? 4 : 2
      degrease_quality_by(item, amount)
    end
  end

  class AgedBrieQualityCalculator < BaseItemQualityCalculator
    def calculate_quality(item)
      amount = is_after_sell_date?(item) ? 2 : 1
      increase_quality_by(item, amount)
    end
  end

  class BackstagePassQualityCalculator < BaseItemQualityCalculator
    def calculate_quality(item)
      if is_after_sell_date?(item)
        0
      elsif is_very_close_to_sell_date?(item)
        increase_quality_by(item, 3)
      elsif is_medium_close_to_sell_date?(item)
        increase_quality_by(item, 2)
      else
        increase_quality_by(item, 1)
      end
    end

    def is_very_close_to_sell_date?(item)
      item.sell_in < 5
    end

    def is_medium_close_to_sell_date?(item)
      item.sell_in < 10
    end
  end

  class SulfurasQualityCalculator < BaseItemQualityCalculator
    def calculate_sell_in(item)
      item.sell_in
    end

    def calculate_quality(item)
      item.quality
    end
  end

  CALCULATORS = { "Backstage passes to a TAFKAL80ETC concert" => BackstagePassQualityCalculator.new,
                  "Aged Brie" => AgedBrieQualityCalculator.new,
                  "Sulfuras, Hand of Ragnaros" => SulfurasQualityCalculator.new,
                  "Conjured Mana Cake" => ConjuredItemQualityCalculator.new }

  DEFAULT_CALCULATOR = NormalItemQualityCalculator.new

  def self.get_quality_calculator_for(item)
    CALCULATORS.fetch(item.name, DEFAULT_CALCULATOR)
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

