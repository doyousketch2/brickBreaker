push = require 'push'
Class = require 'class'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = love .graphics .getWidth()
WINDOW_HEIGHT = love .graphics .getHeight()

VIRTUAL_WIDTH = WINDOW_WIDTH /2
VIRTUAL_HEIGHT = WINDOW_HEIGHT /2

timer = 0  --  timer since the game began
block_pos  = {}  --  table to store block positions

rows, columns  = 30, 30  --  you decide how many would fill the entire screen

block_width  = math .floor( VIRTUAL_WIDTH /columns )
block_height  = math .floor( VIRTUAL_HEIGHT /rows )

--  Runs once when game first starts up;  used to initialize settings.
function love .load()
    -- seed the random number generator, then shake those dice a few times
    math.randomseed( os.time() ) ; math.random() ; math.random() ; math.random()
    love .graphics .setDefaultFilter('nearest', 'nearest')

    push :setupScreen( VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    } )

    local function generate_column( col )
        for  row = 0,  rows -1  do
            if love .math .random() *100 <= chance_of_block then
                local xpos  = col *block_width -( block_width /2 )
                local ypos  = row *block_height +1

                local red  = row /rows
                local green  = math.random()
                local blue  = 1 -col /columns

                block_pos[ #block_pos +1 ] = { x = xpos,  y = ypos,  r = red,  g = green,  b = blue }
            end  --  rand
        end  --  #rows
    end  --  generate_column()

    chance_of_block  = 33  --  % chance of placing a block
    generate_column( columns )  --  rightmost, final column

    chance_of_block  = 44
    generate_column( columns -1 )  --  repeat, for second to last column

    chance_of_block  = 55
    generate_column( columns -2 )

    chance_of_block  = 66
    generate_column( columns -3 )

    chance_of_block  = 77
    generate_column( columns -4 )

    chance_of_block  = 88
    generate_column( columns -5 )

    r, g, b  = 0.5, 0.5, 0.0
    love .graphics .setColor( r, g, b )

    smallFont = love .graphics .newFont( 'Fantasque/FantasqueSansMono-Regular.ttf', 8 )
    scoreFont = love .graphics .newFont( 'Fantasque/FantasqueSansMono-Bold.ttf', 16 )

    -- defining score
    score = 0

    -- defining paddle ( x, y, w, h )
    local thirds = VIRTUAL_HEIGHT /3
    local begin = thirds +math.random( thirds )
    paddle = Paddle( 5, begin, 5, 30 )

    -- defining ball position
    ball = Ball( VIRTUAL_WIDTH /2 -3,  VIRTUAL_HEIGHT /2 -3,  6,  6 )

    gameState = 'start'
end


function love .resize( w, h )
    push :resize( w, h )
end  --  resize


function love .keypressed( key )
    if key == 'escape' then  --  takes priority over other keys
        love .event .quit()

    -- to restart the whole game for testing purpose
    -- takes in consideration the changes done and load according to that
    elseif key == 'r' then
        timer = 0
        love .event .quit("restart")

    elseif key == 'enter' or key == 'return' or key == 'space' then
        if gameState == 'start' then
            gameState = 'play'

        elseif gameState == 'play' then
            gameState = 'start'
            ball :reset()
        end  --  gameState
    end  --  enter
end  --  keypressed


function love .update( dt )
    timer = timer +dt

    if gameState == 'play' then
        paddle :update( dt )
        ball :update( dt )

        if ball :collides( paddle ) then
            ball .dx = -ball .dx  --  horizontal deflection
            ball .x = paddle .x +paddle .width /2 +ball .size /2

            paddle .y = paddle .y -2
            paddle .height = paddle .height +4
            if paddle .height > paddle .maximum then paddle .height = paddle .maximum end
        end

        if ball .y <= 0 then  --  top wall
            ball .dy = -ball .dy  --  vertical deflection
            ball .y = 0
        end

        if ball .y >= VIRTUAL_HEIGHT -ball .size then  --  bottom wall
            ball .dy = -ball .dy  --  vertical deflection
            ball .y = VIRTUAL_HEIGHT -ball .size
        end

        if ball .x +ball .width >= VIRTUAL_WIDTH then  --  right wall
            ball .dx = -ball .dx  --  horizontal deflection
        end

        if love .keyboard .isDown( 'w', 'up' ) then
            paddle .dy = -paddle.speed  --  negative velocity to move paddle up

        elseif love .keyboard .isDown( 's', 'down' ) then
            paddle .dy = paddle .speed  --  positive velocity to move paddle down
        else
            paddle .dy = 0
        end

        if ball.x > VIRTUAL_WIDTH *0.5 then  --  only test for block-collision on right half of screen
            for index = 1, #block_pos do
                local block = block_pos[index]
                if ball :collides(  { x = block .x,  y = block .y,  width = block_width,  height = block_height }  ) then

                    for i = index,  #block_pos -1 do
                        block_pos[i] = block_pos[i +1]
                    end  --  shuffle every entry in list down one

                    block_pos [#block_pos] = nil  --  erase last entry
                    collectgarbage()  --  make sure that last position is empty
                        --  this should be automatic, but just to be certain there aren't any errors

                    paddle .height = paddle .height -1
                    if paddle .height < paddle .minimum then paddle .height = paddle .minimum end

                    score = score +1
                    ball .dx = -ball .dx  --  horizontal deflection
                    break  --  don't try to access last entry in block_pos, because it no longer exists
                end  --  test for collision
            end  --  loop through all block_pos
        end  --  right side of screen
    end  --  gameState == 'play'
end  --  update()


function love .draw()
    push :apply( 'start' )

    love .graphics .clear( 109/255, 76/255, 65/255 )
    ball :render()  --  print ball
    paddle :render()  --  print paddle

    love .graphics .setFont( smallFont )  --  sets active font

    if gameState == 'start' then
        love .graphics .printf(
            'Welcome to Brick Breaker!',  -- text to render
            0,                       -- starting X (0 since we're going to center it based on width)
            VIRTUAL_HEIGHT /6 -4,    -- starting Y (halfway down screen)  subtract half of font for proper alignment
            VIRTUAL_WIDTH,           -- number of pixels to center within (the entire screen here)
            'center' )               -- alignment mode, can be 'center', 'left', or 'right'

        love .graphics .printf( 'Press w and s, or arrows, to move the paddle',
            0,  VIRTUAL_HEIGHT /6 +10 ,  VIRTUAL_WIDTH,  'center' )

    elseif gameState == 'play' then
        if timer < 5 then
            love .graphics .printf( 'Goodluck!',  0,  VIRTUAL_HEIGHT /6 -4,  VIRTUAL_WIDTH,  'center' )
        end  --  three second timer
    end

    --  printing
    love .graphics .setFont( scoreFont )
    love .graphics .printf( 'Score : ' ..score ..'', 20, 1, 170, 'left' )

    for b = 1, #block_pos do  --  draw blocks
        local block  = block_pos[b]

        love .graphics .setColor( block .r,  block. g,  block .b )
        love .graphics .rectangle( 'line',  block.x,  block.y,  block_width -3,  block_height -3 )
    end  --  #block_pos

    push :apply('end')
end
