require "./font"

module Risk
  class HUD
    getter manager : Manager
    getter text
    getter player_text

    Margin = 10

    TextColor = SF::Color::White

    def initialize(manager)
      @manager = manager

      @text = SF::Text.new("", Font.default, (24 * Screen.scaling_factor).to_i)
      @text.fill_color = TextColor
      @text.position = {Margin, Margin}

      @player_text = SF::Text.new("", Font.default, (24 * Screen.scaling_factor).to_i)
      @player_text.fill_color = TextColor
      @player_text.position = {Margin, Margin}
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
      text.position = {Margin, Margin}

      window.draw(text)

      draw_player_info(window)
    end

    def draw_player_info(window)
      player_text.position = {Margin, Screen.height - Margin}
      player_text.position = {Margin, player_text.position.y - player_text.character_size - Margin}

      manager.players.reverse.each.with_index do |player, index|
        player_text.fill_color = player.color
        player_text.position = {Margin, player_text.position.y - player_text.character_size - Margin}

        if manager.player == player
          player_text.string = "> #{manager.players.size - index}. #{player.name}"
        else
          player_text.string = "  #{manager.players.size - index}. #{player.name}"
        end

        window.draw(player_text)
      end
    end
  end
end
