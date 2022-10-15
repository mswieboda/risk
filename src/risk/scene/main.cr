require "../territory"
require "../hud"

module Risk::Scene
  class Main < GSF::Scene
    getter hud

    def initialize
      super(:main)

      @territory = Territory.new(name: "venezula", x: 300, y: 300, width: 160, height: 80, color: SF::Color::Green)

      @hud = HUD.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      hud.update(frame_time)
    end

    def draw(window)
      @territory.draw(window)
      hud.draw(window)
    end
  end
end
