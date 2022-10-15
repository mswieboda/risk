require "../map"
require "../hud"

module Risk::Scene
  class Main < GSF::Scene
    getter view : GSF::View
    getter map : Map
    getter hud : HUD

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

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
      # map view
      view.set_current

      map.draw(window)

      # default view
      view.set_default_current

      hud.draw(window)
    end
  end
end
