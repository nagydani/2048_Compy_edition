-- main.lua
-- Wire modules into LOVE callbacks

require("model")
require("logic")
require("graphics")
require("controls")

function love.keypressed(key)
  local handler = KeyPress[key]
  if handler then
    handler()
  end
end

function love.update(dt)
  game_update_animations(dt)
end

love.mousepressed   = pointer_begin
love.mousereleased  = pointer_end
love.touchpressed   = pointer_begin
love.touchreleased  = pointer_end

function love.draw()
  gfx.clear(COLOR_BG)
  draw_board_frame()
  draw_board()
  draw_animations()
  draw_score()
  draw_game_over()
end

-- start game immediately
game_reset()
