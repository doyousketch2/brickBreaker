push = require 'push'
Class = require 'class'

require 'Ball'
require 'Paddle'

--  Runs once when game first starts up;  used to initialize settings.
function love .load()
    -- seed the random number generator, then shake those dice a few times
    math.randomseed( os.time() ) ; math.random() ; math.random() ; math.random()
    love .graphics .setDefaultFilter( 'nearest', 'nearest' )

    WINDOW_WIDTH = love .graphics .getWidth()
    WINDOW_HEIGHT = love .graphics .getHeight()

    VIRTUAL_WIDTH = WINDOW_WIDTH /2
    VIRTUAL_HEIGHT = WINDOW_HEIGHT /2

    push :setupScreen( VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    } )

    timer = 0  --  timer since the game began
    block_pos  = {}  --  table to store block positions

    rows, columns  = 30, 30  --  you decide how many would fill the entire screen

    block_width  = math .floor( VIRTUAL_WIDTH /columns )
    block_height  = math .floor( VIRTUAL_HEIGHT /rows )

    local function generate_column( col )
        for  row = 0,  rows -1  do
            if love .math .random() *100 <= chance_of_block then
                local xpos  = col *block_width -( block_width /2 )
                local ypos  = row *block_height +1

                local red  = 1 -row /rows
                local green  = math.random() /2
                local blue  = math.random() +0.5 /2

                surprise = nil
                if math.random() *100 <= chance_of_surprise then
                    local choice  = math.random() *100

                    if choice < 10 then
                        surprise = 'two_points'
                    elseif choice < 20 then
                        surprise = 'three_points'

                    elseif choice < 30 then
                        surprise = 'smaller_ball'
                    elseif choice < 40 then
                        surprise = 'bigger_ball'
                    elseif choice < 50 then
                        surprise = 'slower_ball'
                    elseif choice < 60 then
                        surprise = 'faster_ball'
                    elseif choice < 70 then
                        surprise = 'reset_ball'

                    elseif choice < 80 then
                        surprise = 'smaller_paddle'
                    elseif choice < 90 then
                        surprise = 'bigger_paddle'
                    else  --  100
                        surprise = 'reset_paddle'
                    end  --  choice
                end  -- chance

                block_pos[ #block_pos +1 ] = { x = xpos,  y = ypos,  r = red,  g = green,  b = blue,  s = surprise }
            end  --  rand
        end  --  #rows
    end  --  generate_column()

    chance_of_block  = 33  --  % chance of placing a block
    chance_of_surprise  = 90  --  % chance of bonus
    generate_column( columns )  --  rightmost, final column

    chance_of_block  = 44
    chance_of_surprise  = 80
    generate_column( columns -1 )  --  repeat, for second to last column

    chance_of_block  = 55
    chance_of_surprise  = 70
    generate_column( columns -2 )

    chance_of_block  = 66
    chance_of_surprise  = 60
    generate_column( columns -3 )

    chance_of_block  = 77
    chance_of_surprise  = 50
    generate_column( columns -4 )

    chance_of_block  = 88
    chance_of_surprise  = 40
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
end  --  load()


function love .resize( w, h )
    push :resize( w, h )
end  --  resize()


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
    end  --  'enter'
end  --  keypressed()


function love .update( dt )
    timer = timer +dt

    if gameState == 'play' then
        paddle :update( dt )
        ball :update( dt )

        if ball :collides( paddle ) then
            ball .dx = -ball .dx  --  horizontal deflection
            ball .x = paddle .x +paddle .width /2 +ball .size /2

            if paddle .height < paddle .original_size then paddle .height = paddle .height +1
            elseif paddle .height > paddle .original_size then paddle .height = paddle .height -1 end
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
        end  --  'up down'

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

                    if block .s then  --  found a surprise block
                        local surprise = block.s

                        if surprise == 'two_points' then
                            score = score +1  --  in addition to the standard 1 point given

                        elseif surprise == 'three_points' then
                            score = score +2


                        elseif surprise == 'smaller_ball' then
                            ball .size = ball .size -1

                        elseif surprise == 'bigger_ball' then
                            ball .size = ball .size +3

                        elseif surprise == 'slower_ball' then
                            ball .dx = ball .dx *0.95
                            ball .dy = ball .dy *0.95

                        elseif surprise == 'faster_ball' then
                            ball .dx = ball .dx *1.05
                            ball .dy = ball .dy *1.05

                        elseif surprise == 'reset_ball' then
                            ball .size = ball .original_size

                            if ball.dx > 0 then ball.dx = 100
                            else ball .dx = -100 end

                            if ball.dy > 0 then ball.dy = 50
                            else ball .dy = -50 end


                        elseif surprise == 'smaller_paddle' then
                            paddle .height = paddle .height -8
                            if paddle .height < paddle .minimum then paddle .height = paddle .minimum end

                        elseif surprise == 'bigger_paddle' then
                            paddle .y = paddle .y -1
                            paddle .height = paddle .height +16
                            if paddle .height > paddle .maximum then paddle .height = paddle .maximum end

                        elseif surprise == 'reset_paddle_size' then
                            paddle .height = paddle .original_size

                        end  --  various effects
                    end  --  surprise block

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
    end  --  'play'

    --  printing
    love .graphics .setFont( scoreFont )
    love .graphics .printf( 'Score : ' ..score ..'', 20, 1, 170, 'left' )

    for b = 1, #block_pos do  --  draw blocks
        local block  = block_pos[b]

        love .graphics .setColor( block .r,  block. g,  block .b )
        love .graphics .rectangle( 'line',  block.x,  block.y,  block_width -3,  block_height -3 )
    end  --  #block_pos

    push :apply('end')
end  --  draw()

