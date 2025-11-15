-- main.lua

-- colors (Compy palette)
COLOR_BG = Color[Color.black]
COLOR_FG = Color[Color.white + Color.bright]
COLOR_FRAME = Color[Color.cyan]
COLOR_EMPTY = Color[Color.white]
COLOR_TILE_BG = Color[Color.yellow]
COLOR_TILE_FG = Color[Color.black]

-- size from single base unit
BASE_SIZE = 40
GRID_SIZE = 4
FRAME_THICK = BASE_SIZE
CELL_SIZE = BASE_SIZE * 2
CELL_GAP = math.floor(BASE_SIZE / 5 + 0.5)

BOARD_LEFT = FRAME_THICK
BOARD_TOP = FRAME_THICK
BOARD_WIDTH = GRID_SIZE * CELL_SIZE
BOARD_HEIGHT = GRID_SIZE * CELL_SIZE
HUD_Y = BOARD_TOP + BOARD_HEIGHT + BASE_SIZE

Game = {
  rows = GRID_SIZE,
  cols = GRID_SIZE,
  cells = {},
  state = "start",
  score = 0,
  empty_count = 0
}

MoveTable = {}
KeyPress  = {}
gfx = love.graphics

-- reset board: only rows, cells are nil by default
function game_clear()
  Game.empty_count = Game.rows * Game.cols
  Game.cells = {}
  Row = 1
  while Row <= Game.rows do
    Game.cells[Row] = {}
    Row = Row + 1
  end
end

-- choose random value 2 or 4
function tile_random_value()
  if love.math.random() < 0.9 then
    return 2
  end
  return 4
end

-- find N-th empty cell (by scan order)
function find_empty_by_index(Target)
  Seen = 0
  Row = 1
  while Row <= Game.rows do
    Col = 1
    while Col <= Game.cols do
      if Game.cells[Row][Col] == nil then
        Seen = Seen + 1
        if Seen == Target then return Row, Col
        end
      end
      Col = Col + 1 end
    Row = Row + 1 end
end

-- add one random 2 or 4
function game_add_random_tile()
  if Game.empty_count == 0 then
    return
  end
  Target = love.math.random(Game.empty_count)
  Row, Col = find_empty_by_index(Target)
  if Row ~= nil then
    Game.cells[Row][Col] = tile_random_value()
    Game.empty_count = Game.empty_count - 1
  end
end

-- full reset of the game
function game_reset()
  game_clear()
  Game.score = 0
  game_add_random_tile()
  game_add_random_tile()
  Game.state = "play"
end

-- slide row left by one pass
function slide_row_left_once(RowIndex)
  Moved = false; 
  Col = 1
  while Col < Game.cols do
    A = Game.cells[RowIndex][Col]
    B = Game.cells[RowIndex][Col + 1]
    if A == nil and B ~= nil then
      Game.cells[RowIndex][Col] = B
      Game.cells[RowIndex][Col + 1] = nil
      Moved = true end
    Col = Col + 1 end
  return Moved
end

-- merge neighbours in row to the left
function merge_row_left(RowIndex)
  Moved = false; 
  Col = 1
  while Col < Game.cols do
    A = Game.cells[RowIndex][Col]
    if A ~= nil and Game.cells[RowIndex][Col + 1] == A then
      Value = A * 2; 
      Game.cells[RowIndex][Col] = Value
      Game.cells[RowIndex][Col + 1] = nil; 
      Moved = true
      Game.score = Game.score + Value;
      Game.empty_count = Game.empty_count + 1 end
    Col = Col + 1 end
  return Moved
end

-- one full left move for a row
function move_row_left(RowIndex)
  Any = false
  if slide_row_left_once(RowIndex) then Any = true end
  if slide_row_left_once(RowIndex) then Any = true end
  if slide_row_left_once(RowIndex) then Any = true end
  if merge_row_left(RowIndex) then Any = true end
  if slide_row_left_once(RowIndex) then Any = true end
  return Any
end

-- slide row right by one pass
function slide_row_right_once(RowIndex)
  Moved = false; 
  Col = Game.cols
  while Col > 1 do
    A = Game.cells[RowIndex][Col]
    B = Game.cells[RowIndex][Col - 1]
    if A == nil and B ~= nil then
      Game.cells[RowIndex][Col] = B
      Game.cells[RowIndex][Col - 1] = nil
      Moved = true
    end
    Col = Col - 1 end
  return Moved
end

-- merge neighbours in row to the right
function merge_row_right(RowIndex)
  Moved = false; 
  Col = Game.cols
  while Col > 1 do
    A = Game.cells[RowIndex][Col]
    if A ~= nil and Game.cells[RowIndex][Col - 1] == A then
      Value = A * 2; 
      Game.cells[RowIndex][Col] = Value
      Game.cells[RowIndex][Col - 1] = nil; 
      Moved = true
      Game.score = Game.score + Value;
      Game.empty_count = Game.empty_count + 1 end
    Col = Col - 1 end
  return Moved
end

-- one full right move for a row
function move_row_right(RowIndex)
  Any = false
  if slide_row_right_once(RowIndex) then 
    Any = true end
  if slide_row_right_once(RowIndex) then 
    Any = true end
  if slide_row_right_once(RowIndex) then 
    Any = true end
  if merge_row_right(RowIndex) then 
    Any = true end
  if slide_row_right_once(RowIndex) then 
    Any = true end
  return Any
end

-- slide column up by one pass
function slide_col_up_once(ColIndex)
  Moved = false; 
  Row = 1
  while Row < Game.rows do
    A = Game.cells[Row][ColIndex]
    B = Game.cells[Row + 1][ColIndex]
    if A == nil and B ~= nil then
      Game.cells[Row][ColIndex] = B
      Game.cells[Row + 1][ColIndex] = nil
      Moved = true
    end
    Row = Row + 1
  end
  return Moved
end

-- merge neighbours in column up
function merge_col_up(ColIndex)
  Moved = false; Row = 1
  while Row < Game.rows do
    A = Game.cells[Row][ColIndex]
    if A ~= nil and Game.cells[Row + 1][ColIndex] == A then
      Value = A * 2; Game.cells[Row][ColIndex] = Value
      Game.cells[Row + 1][ColIndex] = nil; Moved = true
      Game.score = Game.score + Value;
      Game.empty_count = Game.empty_count + 1
    end
    Row = Row + 1
  end
  return Moved
end

-- one full up move for a column
function move_col_up(ColIndex)
  Any = false
  if slide_col_up_once(ColIndex) then 
    Any = true end
  if slide_col_up_once(ColIndex) then 
    Any = true end
  if slide_col_up_once(ColIndex) then 
    Any = true end
  if merge_col_up(ColIndex) then 
    Any = true end
  if slide_col_up_once(ColIndex) then 
    Any = true end
  return Any
end

-- slide column down by one pass
function slide_col_down_once(ColIndex)
  Moved = false; Row = Game.rows
  while Row > 1 do
    A = Game.cells[Row][ColIndex]
    B = Game.cells[Row - 1][ColIndex]
    if A == nil and B ~= nil then
      Game.cells[Row][ColIndex] = B
      Game.cells[Row - 1][ColIndex] = nil
      Moved = true
    end
    Row = Row - 1
  end
  return Moved
end

-- merge neighbours in column down
function merge_col_down(ColIndex)
  Moved = false; 
  Row = Game.rows
  while Row > 1 do
    A = Game.cells[Row][ColIndex]
    if A ~= nil and Game.cells[Row - 1][ColIndex] == A then
      Value = A * 2; 
      Game.cells[Row][ColIndex] = Value
      Game.cells[Row - 1][ColIndex] = nil; 
      Moved = true
      Game.score = Game.score + Value;
      Game.empty_count = Game.empty_count + 1 end
    Row = Row - 1 end
  return Moved
end

-- one full down move for a column
function move_col_down(ColIndex)
  Any = false
  if slide_col_down_once(ColIndex) then 
    Any = true end
  if slide_col_down_once(ColIndex) then 
    Any = true end
  if slide_col_down_once(ColIndex) then 
    Any = true end
  if merge_col_down(ColIndex) then 
    Any = true end
  if slide_col_down_once(ColIndex) then 
    Any = true end
  return Any
end

-- move the whole board in one direction
function game_move_left()
  Moved = false; Row = 1
  while Row <= Game.rows do
    if move_row_left(Row) then Moved = true end
    Row = Row + 1
  end
  return Moved
end

function game_move_right()
  Moved = false; Row = 1
  while Row <= Game.rows do
    if move_row_right(Row) then Moved = true end
    Row = Row + 1
  end
  return Moved
end

function game_move_up()
  Moved = false; Col = 1
  while Col <= Game.cols do
    if move_col_up(Col) then Moved = true end
    Col = Col + 1
  end
  return Moved
end

function game_move_down()
  Moved = false; Col = 1
  while Col <= Game.cols do
    if move_col_down(Col) then Moved = true end
    Col = Col + 1
  end
  return Moved
end

MoveTable.left  = game_move_left
MoveTable.right = game_move_right
MoveTable.up    = game_move_up
MoveTable.down  = game_move_down

-- empty cell check
function game_has_empty()
  return Game.empty_count > 0
end

-- neighbour merge check for a single cell
function can_merge_neighbours(Row, Col)
  Value = Game.cells[Row][Col]
  if Value == nil then
    return false
  end
  if Col < Game.cols and Game.cells[Row][Col + 1] == Value then
    return true
  end
  if Row < Game.rows and Game.cells[Row + 1][Col] == Value then
    return true
  end
  return false
end

-- true if at least one merge is possible
function game_can_merge()
  Row = 1
  while Row <= Game.rows do
    Col = 1
    while Col <= Game.cols do
      if can_merge_neighbours(Row, Col) then
        return true
      end
      Col = Col + 1
    end
    Row = Row + 1
  end
  return false
end

-- true when no moves left
function game_is_over()
  if game_has_empty() then
    return false
  end
  if game_can_merge() then
    return false
  end
  return true
end

-- run one move in a given direction
function game_handle_move(Dir)
  MoveFunc = MoveTable[Dir]
  if not MoveFunc then
    return
  end
  if MoveFunc() then
    game_add_random_tile()
    if game_is_over() then
      Game.state = "gameover"
    end
  end
end

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
function draw_cell(Row, Col, Value)
  X = BOARD_LEFT + (Col - 1) * CELL_SIZE
  Y = BOARD_TOP  + (Row - 1) * CELL_SIZE
  Size = CELL_SIZE - CELL_GAP
  if Value ~= nil then
    gfx.setColor(COLOR_TILE_BG)
  else
    gfx.setColor(COLOR_EMPTY)
  end
  gfx.rectangle("fill", X, Y, Size, Size)
  if Value ~= nil then
    gfx.setColor(COLOR_TILE_FG)
    gfx.print(Value, X + 10, Y + 10)
  end
end

-- draw whole board
function draw_board()
  Row = 1
  while Row <= Game.rows do
    Col = 1
    while Col <= Game.cols do
      draw_cell(Row, Col, Game.cells[Row][Col])
      Col = Col + 1
    end
    Row = Row + 1
  end
end

-- draw score text
function draw_score()
  gfx.setColor(COLOR_FG[1], COLOR_FG[2], COLOR_FG[3])
  gfx.print("Score: " .. Game.score, BOARD_LEFT, HUD_Y)
end

-- keyboard handlers
function KeyPress.left()
  game_handle_move("left")
end

function KeyPress.right()
  game_handle_move("right")
end

function KeyPress.up()
  game_handle_move("up")
end

function KeyPress.down()
  game_handle_move("down")
end

KeyPress.a = KeyPress.left
KeyPress.d = KeyPress.right
KeyPress.w = KeyPress.up
KeyPress.s = KeyPress.down

function KeyPress.escape()
  love.event.quit()
end

function KeyPress.r()
  game_reset()
end

-- keyboard input
function love.keypressed(Key)
  Handler = KeyPress[Key]
  if Handler then
    Handler()
  end
end

-- main draw
function love.draw()
  gfx.clear(COLOR_BG[1], COLOR_BG[2], COLOR_BG[3])
  draw_board_frame()
  draw_board()
  draw_score()
  if Game.state == "gameover" then
    gfx.print("GAME OVER", BOARD_LEFT, HUD_Y + 30)
  end
end

-- start game
game_reset()