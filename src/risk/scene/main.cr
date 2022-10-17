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
    getter? restart

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      @map = Map.new

      view.zoom(1 / Screen.scaling_factor)
      view.center(Map::MapWidth / 2, Map::MapHeight / 2)
      view.zoom(0.5)

      @players = [] of Player

      @players << Player.new("red player", SF::Color::Red)
      @players << Player.new("green player", SF::Color::Green)
      @players << Player.new("blue player", SF::Color::Blue)

      @players.each(&.initial_units(@players.size.to_u8))

      @manager = Manager.new(players: players, map: map)

      @hud = HUD.new(manager: manager)
      @restart = false
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      mouse_coords = mouse.view_coords(view)

      manager.update(frame_time, keys, mouse, mouse_coords)
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
