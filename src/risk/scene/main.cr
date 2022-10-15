require "../map"
require "../hud"

module Risk::Scene
  class Main < GSF::Scene
    getter hud : HUD
    getter map : Map

    def initialize
      super(:main)

      @map = Map.new
      @hud = HUD.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      map.update(frame_time)
      hud.update(frame_time)
    end

    def draw(window)
      map.draw(window)
      hud.draw(window)
    end
  end
end
