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

      if manager.phase == :turns
        text.string += ", #{manager.turn_phase} phase"

        if manager.turn_phase == :draft
          text.string += ", units: #{manager.player.units}"
        elsif manager.turn_phase == :attack
          text.string += ", #{manager.attack_phase}"

          if manager.attack_phase == :attack
            text.string += ", rolls: a: #{manager.attacker_values} d: #{manager.defender_values} losses: a: #{manager.attacker_losses} d: #{manager.defender_losses}"
          end

          if [:choose_dice, :attack].includes?(manager.attack_phase)
            text.string += ", dice: a: #{manager.attacker_dice} d: #{manager.defender_dice}"
          end
        end
      end
    end

    def draw(window : SF::RenderWindow)
      window.draw(text)
    end
  end
end
