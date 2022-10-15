module Risk
  class Territory
    getter name : String
    getter x : Int32
    getter y : Int32
    getter width : Int32
    getter height : Int32
    getter sprite : SF::Sprite
    getter sprite_outline : SF::Sprite

    DefaultColor = SF::Color.new(96, 96, 96)

    def initialize(name, x, y, width, height, color = DefaultColor)
      @name = name
      @x = x
      @y = y
      @width = width
      @height = height

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
    end

    def draw(window)
      window.draw(sprite)
      window.draw(sprite_outline)
    end
  end
end
