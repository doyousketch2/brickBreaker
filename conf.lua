function love .conf( config_table )
  local win  = config_table .window
  local mod  = config_table .modules
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  win .title  = 'Brick Breaker'
  win .icon   = 'icon.png'

  win .width  = 1280
  win .height = 720
  win .vsync  = true                     --  Enable vertical sync  (boolean)

  config_table .version  = '11.3'                 --  LÖVE version this game was made for

  config_table .identity  = 'brickBreaker'        --  Name of the save directory
  config_table .externalstorage  = false          --  Read & write from external storage on Android
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- enable modules you need, for functionality.
-- disble ones you don't, for speed, and reduced memory consumption.

  mod .window  = true       -- Modify and retrieve information about the program's window.
  mod .timer   = true       -- High-resolution timing functionality,
                          --- Disabling will result 0 delta time in love.update

  mod .event   = true       -- Manage events, like keypresses.
  mod .math    = true       -- System-independent mathematical functions.
  mod .data    = true       -- Provides functionality for creating and transforming data.

  mod .keyboard  = true     -- Interface to user's keyboard.
  mod .mouse     = true     --             user's mouse.
  mod .touch     = true     --            touch-screen presses.
  mod .joystick  = true    --           connected joysticks.

  mod .font      = true     -- Allows you to work with fonts.
  mod .image     = true     -- Decode encoded image data.
  mod .graphics  = true     -- Draw lines, shapes, text, Images and other Drawable objects onto screen.
                            --- Its secondary responsibilities include:
                            --- loading Images and Fonts into memory,   managing screen geometry,
                            --- creating drawable objects,  such as ParticleSystems or Canvases.

  mod .sound    = true      -- Decode sound files.  It can't play sounds, see love.audio for that.
  mod .audio    = true      -- Output sound to user's speakers.

  mod .video    = false     -- Decode, control, and stream video files.
  mod .physics  = false     -- Simulate 2D rigid body physics in a realistic manner,  based on Box2D

  mod .system   = false     -- Information about user's system.
  mod .thread   = false     -- Allows you to work with multiple threads.

--  filesystem            ** Interface to user's filesystem;  always enabled.
end
