require "./stage"

module Risk
  class Game < GSF::Game
    getter manager

    def initialize
      mode = SF::VideoMode.desktop_mode
      style = SF::Style::None

      {% if flag?(:linux) %}
        mode.width -= 50
        mode.height -= 100

        style = SF::Style::Default
      {% end %}

      super(title: "risk", mode: mode, style: style)

      window.framerate_limit = 60

      @stage = Stage.new(window)
    end
  end
end
