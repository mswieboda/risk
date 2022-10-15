require "../territory"
require "../hud"

module Risk::Scene
  class Main < GSF::Scene
    getter hud
    getter territories : Array(Territory)

    def initialize
      super(:main)

      x = 300
      y = 300
      cell = 16

      @territories = [] of Territory

      # south america
      territory_data = [
        {name: "venezula", x: 0, y: 0, width: 160, height: 80},
        {name: "brazil", x: 2, y: 2, width: 208, height: 192},
        {name: "peru", x: 0, y: 3, width: 144, height: 160},
        {name: "argentina", x: 0, y: 9, width: 144, height: 224}
      ]

      territory_data.each do |data|
        @territories << Territory.new(
          name: data[:name],
          x: x + data[:x] * cell,
          y: y + data[:y] * cell,
          width: data[:width],
          height: data[:height]
        )
      end

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
      @territories.each(&.draw(window))

      hud.draw(window)
    end
  end
end
