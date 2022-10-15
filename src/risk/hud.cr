require "./font"

module Risk
  class HUD
    getter text
    getter manager : Manager

    Margin = 10

    TextColor = SF::Color::White

    def initialize(manager)
      @manager = manager

      @text = SF::Text.new("", Font.default, 24)
      @text.fill_color = TextColor
      @text.position = {Margin, Margin}
    end

    def update(frame_time)
      if (manager.phase == :allocate_territories && manager.auto_allocate_territories?) ||
          (manager.phase == :allocate_armies && manager.auto_allocate_armies?)
        text.string = ""
      else
        text.string = "#{manager.player.name}'s turn"
      end

      if manager.phase == :play
        text.string += ", #{manager.turn_phase} phase"
      end
    end

    def draw(window : SF::RenderWindow)
      window.draw(text)
    end
  end
end
