require "../map"
require "../player"
require "../manager"
require "../hud"

module Risk::Scene
  class Main < GSF::Scene
    getter view : GSF::View
    getter map : Map
    getter players : Array(Player)
    getter manager : Manager
    getter hud : HUD

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @map = Map.new

      @players = [] of Player

      @players << Player.new("red player", SF::Color::Red)
      @players << Player.new("green player", SF::Color::Green)

      @players.each(&.initial_units(@players.size.to_u8))

      @manager = Manager.new(players: players, map: map)

      @hud = HUD.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      mouse_coords = mouse.view_coords(view)

      manager.update(frame_time, mouse, mouse_coords)
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
