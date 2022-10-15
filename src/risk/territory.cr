module Risk
  class Territory
    getter name : String
    getter x : Int32
    getter y : Int32
    getter width : Int32
    getter height : Int32
    getter sprite : SF::Sprite
    getter sprite_outline : SF::Sprite
    getter color : SF::Color
    getter text : SF::Text
    property units : Int32

    DefaultColor = SF::Color.new(96, 96, 96)
    TextColor = SF::Color::White

    def initialize(name, x, y, width, height, unit_cx = 16, unit_cy = 16, color = DefaultColor, units = 0)
      @name = name
      @x = x
      @y = y
      @width = width
      @height = height
      @color = color
      @units = 0

      filename = "assets/#{name}.png"

      texture = SF::Texture.from_file(filename, SF::IntRect.new(0, 0, width, height))
      texture.smooth = true

      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      sprite.color = color

      texture = SF::Texture.from_file(filename, SF::IntRect.new(width, 0, width, height))
      texture.smooth = true

      @sprite_outline = SF::Sprite.new(texture)
      @sprite_outline.position = {x, y}

      @text = SF::Text.new(units.to_s, Font.default, 16)
      @text.fill_color = TextColor

      tx = x + unit_cx - @text.global_bounds.width / 2
      ty = y + unit_cy - @text.global_bounds.height / 2

      @text.position = {tx, ty}
    end

    def color=(color : SF::Color)
      @color = color
      @sprite.color = color
    end

    def draw(window)
      window.draw(sprite)
      window.draw(sprite_outline)

      draw_units(window)
    end

    def draw_units(window)
      window.draw(text)
    end
  end
end
