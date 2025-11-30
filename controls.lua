-- controls.lua
-- Keyboard handlers
-- Mouse control

require("model")
require("logic")

KeyPress = { }

SWIPE_MIN_DISTANCE2 = 40 * 40
SWIPE_DIR_RATIO = 1.5
POINTER_ACTIVE = false
POINTER_X = 0
POINTER_Y = 0

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

SwipeDir = {
  left = KeyPress.left,
  right = KeyPress.right,
  up = KeyPress.up,
  down = KeyPress.down
}

SwipeMap = {
  ["x+"] = "right",
  ["x-"] = "left",
  ["y+"] = "down",
  ["y-"] = "up"
}

local function pointer_xy(a, b, c)
  if type(a) == "number" and type(b) == "number" 
  then
    return a, b      
  end
  return b, c        
end

function pointer_begin(a, b, c)
  local x, y = pointer_xy(a, b, c)
  POINTER_ACTIVE = true
  POINTER_X = x
  POINTER_Y = y
end

function swipe_direction(dx, dy)
  local absx = math.abs(dx)
  local absy = math.abs(dy)
  if absx * absx + absy * absy < SWIPE_MIN_DISTANCE2 then
    return nil
  end
  if absx >= absy * SWIPE_DIR_RATIO then
    return dx > 0 and "x+" or "x-"
  end
  if absy >= absx * SWIPE_DIR_RATIO then
    return dy > 0 and "y+" or "y-"
  end
end

function pointer_end(a, b, c)
  local x, y = pointer_xy(a, b, c)
  if not POINTER_ACTIVE then return end
  POINTER_ACTIVE = false

  local dir = swipe_direction(x - POINTER_X, y - POINTER_Y)
  if not dir then return end

  SwipeDir[ SwipeMap[dir] ]()
end
