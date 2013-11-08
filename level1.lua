-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view


	local perspective = require( "perspective" )
	local camera = perspective.createView()

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 128 )
	
	-- make a crate (off-screen), position it, and rotate slightly
	local crate = display.newImageRect( "crate.png", 90, 90 )
	crate.x, crate.y = 160, -100
	crate.rotation = 15

	-- add physics to the crate
	physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )

	-- make a planet
	local planet = display.newImage( "sprites/planet1.png" );

	local function onTouch(event)
		planet.x = planet.x + 10

	end

	camera:setFocus(planet)
	camera:track()

	planet.x, planet.y = 160, 200
	planet:addEventListener( "touch", onTouch )

	physics.addBody( planet, "static", {density=1.0, friction=0.2, bounce=0.2, radius=94 } );


	
	
	
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( crate )
	group:insert(planet)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene