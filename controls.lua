-- controls.lua
-- Keyboard handlers

require("model")
require("logic")

KeyPress = { }

function KeyPress.left()
  game_handle_move(move_left)
end

function KeyPress.right()
  game_handle_move(move_right)
end

function KeyPress.up()
  game_handle_move(move_up)
end

function KeyPress.down()
  game_handle_move(move_down)
end

KeyPress.a = KeyPress.left
KeyPress.d = KeyPress.right
KeyPress.w = KeyPress.up
KeyPress.s = KeyPress.down
KeyPress.escape = love.event.quit
KeyPress.r = game_reset
