module Risk::Scene
  class Start < GSF::Scene
    getter start_scene : Symbol?
    getter? continue
    getter items

    def initialize
      super(:start)

      @start_scene = nil
      @continue = false
      @items = GSF::MenuItems.new(
        font: Font.default,
        labels: ["new", "continue", "exit"],
        size: (36 * Screen.scaling_factor).to_i,
        use_keyboard: false,
        use_mouse: true
      )
    end

    def reset
      super

      @start_scene = nil
      @continue = false
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      items.update(frame_time, keys, mouse)

      # TODO: refactor this to some just_pressed?(:action) etc pattern per scene
      #       with defined input config per scene
      if mouse.just_pressed?(Mouse::Left)
        case items.focused
        when "new"
          @start_scene = :main
        when "continue"
          @continue = true
        when "exit"
          @exit = true
        end
      elsif keys.just_pressed?(Keys::Escape)
        @exit = true
      end
    end

    def draw(window : SF::RenderWindow)
      items.draw(window)
    end
  end
end
