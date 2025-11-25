-- graphics.lua
-- Basic drawing: board, tiles, score, game over

require("model")

-- size from single base unit
BASE_SIZE = 56
FRAME_THICK = BASE_SIZE
CELL_SIZE = BASE_SIZE * 2
CELL_GAP = math.floor(BASE_SIZE / 5 + 0.5)
BOARD_LEFT = FRAME_THICK
BOARD_TOP = FRAME_THICK
BOARD_WIDTH = GRID_SIZE * CELL_SIZE
BOARD_HEIGHT = GRID_SIZE * CELL_SIZE
HUD_Y = BOARD_TOP + BOARD_HEIGHT + BASE_SIZE

-- layout constants
TILE_TEXT_OFFSET_X = 10
TILE_TEXT_OFFSET_Y = 10
GAME_OVER_OFFSET_Y = 30

-- colors
COLOR_BG = Color[Color.black]
COLOR_FG = Color[Color.white + Color.bright]
COLOR_FRAME = Color[Color.cyan]
COLOR_EMPTY = Color[Color.white]
COLOR_TILE_BG = Color[Color.yellow]
COLOR_TILE_FG = Color[Color.black]

gfx = love.graphics

-- draw board frame with uniform thickness
function draw_board_frame()
  gfx.setColor(COLOR_FRAME)
  gfx.rectangle(
    "fill",
    BOARD_LEFT - FRAME_THICK,
    BOARD_TOP  - FRAME_THICK,
    BOARD_WIDTH  + FRAME_THICK * 2,
    BOARD_HEIGHT + FRAME_THICK * 2
  )
end

-- draw a single tile
function draw_cell(row, col, value)
  local x = BOARD_LEFT + (col - 1) * CELL_SIZE
  local y = BOARD_TOP + (row - 1) * CELL_SIZE
  local size = CELL_SIZE - CELL_GAP
  if value then
    gfx.setColor(COLOR_TILE_BG)
  else
    gfx.setColor(COLOR_EMPTY)
  end
  gfx.rectangle("fill", x, y, size, size)
  if value then
    gfx.setColor(COLOR_TILE_FG)
    gfx.print(
      value,
      x + TILE_TEXT_OFFSET_X,
      y + TILE_TEXT_OFFSET_Y
    )
  end
end

-- draw whole board
function draw_board()
  for row = 1, Game.rows do
    for col = 1, Game.cols do
      draw_cell(row, col, Game.cells[row][col])
    end
  end
end

-- draw score text
function draw_score()
  gfx.setColor(COLOR_FG)
  gfx.print("Score: " .. Game.score, BOARD_LEFT, HUD_Y)
end

function draw_game_over()
  if Game.state == "gameover" then
    gfx.print("GAME OVER", BOARD_LEFT, HUD_Y + GAME_OVER_OFFSET_Y)
  end
end

