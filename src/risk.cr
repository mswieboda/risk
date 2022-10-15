require "game_sf"

require "./risk/game"

module Risk
  alias Screen = GSF::Screen
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks

  Game.new.run
end
