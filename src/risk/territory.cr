module Risk
  class Territory
    getter name : String
    getter x : Int32
    getter y : Int32
    getter width : Int32
    getter height : Int32
    getter image : SF::Image
    getter sprite : SF::Sprite
    getter sprite_outline : SF::Sprite
    getter player : Player
    getter text : SF::Text
    getter units : Int32
    getter? hover

    TextColor = SF::Color::White
    OutlineDefaultColor = SF::Color::White
    OutlineHoverColor = SF::Color.new(255, 0, 255)

    def initialize(name, x, y, width, height, unit_cx = 16, unit_cy = 16, player = Player.empty, units = 0)
      @name = name
      @x = x
      @y = y
      @width = width
      @height = height
      @player = player
      @units = 0
      @hover = false

      filename = "assets/#{name}.png"

      @image = SF::Image.from_file(filename)

      texture = SF::Texture.from_image(image, SF::IntRect.new(0, 0, width, height))
      texture.smooth = true

      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      sprite.color = player.color

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

    def player=(player : Player)
      @player = player
      @sprite.color = player.color
    end

    def player?(player : Player)
      @player == player
    end

    def units=(units : Int32)
      @units = units
      @text.string = units.to_s
    end

    def empty?
      @player == Player.empty && units == 0
    end

    def clear_hover
      @hover = false
      sprite.color = player.color
    end

    def check_hover(mouse_coords)
      if hover?(mouse_coords)
        @hover = true
        sprite.color = OutlineHoverColor

        true
      else
        false
      end
    end

    def inside_bounds?(mouse_coords)
      mouse_coords.x > x && mouse_coords.x < x + width &&
        mouse_coords.y > y && mouse_coords.y < y + height
    end

    def hover?(mouse_coords)
      return false unless inside_bounds?(mouse_coords)

      px = mouse_coords.x.round.to_i - x
      py = mouse_coords.y.round.to_i - y

      pixel = image.get_pixel(px, py)

      pixel.a > 30
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
