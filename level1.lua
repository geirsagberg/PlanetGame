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
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

bullets = {}


function onTouch(event)
	reticule.x = event.x
	reticule.y = event.y
	reticule.isVisible = event.phase ~= "ended"
	cannon:face(reticule)

	if(event.phase == "ended") then
		local bullet = display.newRect( halfW, screenH - 10, 3, 3 )
		physics.addBody( bullet, {density=1.0, friction=0.2, bounce=0.3 } )
		local angle = getFaceAngle(cannon, reticule)
		local distance = getDistance(cannon, reticule)
		local factor = 0.001 * distance
		local y = math.sin( angle ) * factor
		local x = math.cos( angle ) * factor
		bullet:applyLinearImpulse(x, y, 0, 0)
	end
end

function getDistance(obj1, obj2)
	local dx = obj2.x - obj1.x
	local dy = obj2.y - obj1.y
	local distance = math.sqrt( dx*dx + dy*dy )
	return distance
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	planets = {}
	for i=1,5 do
		local radius = math.random( 50 ) + 25
		local planet = display.newImageRect( "sprites/planet"..i..".png", radius * 2, radius * 2 )
		planet.x = math.random( screenW )
		planet.y = screenH * (i - 1) / 5  
		local realRadius = radius * 0.66
		planet.radius = realRadius
		physics.addBody( planet, "static", {density=1.0, friction=0, bounce=1, radius=realRadius } )
		group:insert( planet )
		table.insert( planets, planet )
	end

	physics.setGravity( 0, 0 )

	reticule = display.newCircle( group, halfW, halfH, 10 )
	reticule.isVisible = false

	cannon = display.newRect( group, halfW, screenH - 20, 10, 20 )


	function cannon:face(object)
		local angle = getFaceAngle(cannon, object)
		cannon.rotation = math.deg(angle) + 90
	end

	Runtime:addEventListener( "touch", onTouch )
end

function getFaceAngle(obj1, obj2)
	local deltaX = obj2.x - obj1.x
	local deltaY = obj2.y - obj1.y
	local angle = math.atan2( deltaY, deltaX )
	return angle
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	--physics.setDrawMode( "debug" )
	
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



function gameLoop(event)
	for i,v in ipairs(planets) do
		calculateForce(v)
	end
end

gravityConstant = 10000000

function calculateForce(planet)
	print(planet.radius)

	local area = math.pow(planet.radius, 2) * math.pi
	local mass = area * planet.density

	for i=1,bullets.length do
		local bullet = bullets[i]
		local distance = getDistance(bullet, planet)
		local force = mass * gravityConstant / math.pow(distance, 2)
		local xForce = cos(force) * distance
		local yForce = sin(force) * distance
		bullet:applyForce( xForce, yForce, 0, 0 )

	end

	local force = mass * gravityConstant / math.pow(distance, 2)
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

Runtime:addEventListener( "enterFrame", gameLoop )
-----------------------------------------------------------------------------------------

return scene