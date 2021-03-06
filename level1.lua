-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
-- include Corona's "widget" library
local widget = require "widget"

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

gravityConstant = 0.2
maxNumOfBullets = 100
numOfBullets = 0
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

-- table.indexOf( array, object ) returns the index
-- of object in array. Returns 'nil' if not in array.
table.indexOf = function( t, object )
	local result
	 
	if "table" == type( t ) then
		for i=1,#t do
			if object == t[i] then
				result = i
				break
			end
		end
	end
	 
	return result
end

function onCollision( event )
	local bullet
	if(event.object1.myName == "bullet") then
		bullet = event.object1 
	elseif(event.object2.myName == "bullet") then
		bullet = event.object2
	end

	if(bullet ~= nil) then
		local index = table.indexOf( bullets, bullet )
		table.remove(bullets, index)
		bullet:removeSelf( )
		bullet = nil
	end

	local myGoal
	if(event.object1.myName == "goal") then
		myGoal = event.object1
	elseif(event.object2.myName == "goal") then
		myGoal = event.object2 
	end

	if(myGoal ~= nil) then
		winCounter = winCounter + 255 / maxNumOfBullets
		goal:setFillColor( 255-winCounter, 255, 255-winCounter  )
	end

	if(#bullets == 0 and numOfBullets == 0) then
		--gameover
		winText = display.newText( "Score: "..winCounter, halfW - 100, halfH, "Helvetica", 40 )
		winText:setReferencePoint( display.CenterReferencePoint )

		playBtn = widget.newButton{
		label="Play again",
		labelColor = { default={255}, over={128} },
		defaultFile="button.png",
		overFile="button-over.png",
		width=154, height=40,
		onRelease = onReplay	-- event listener function
	}
	playBtn:setReferencePoint( display.CenterReferencePoint )
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight - 125
	end
end

function onReplay()
	storyboard.gotoScene("dummy")
end

winCounter = 0

isFiring = false

function onTouch(event)
	reticule.x = event.x
	reticule.y = event.y
	reticule.isVisible = event.phase ~= "ended"
	cannon:face(reticule)

	isFiring = event.phase ~= "ended"
end

function fireBullet()
	if numOfBullets > 0 then
		local bullet = display.newRect( halfW, screenH - 10, 3, 3 )
		table.insert( bullets, bullet )
		physics.addBody( bullet, {density=1.0, friction=0.2, bounce=0.3 } )
		local angle = getFaceAngle(cannon, reticule)
		local distance = getDistance(cannon, reticule)
		local distanceFactor = 0.1
		--local factor = 0.01 + distanceFactor * distance / screenH
		local factor = distanceFactor
		local y = math.sin( angle ) * factor
		local x = math.cos( angle ) * factor
		bullet:applyLinearImpulse(x, y, 0, 0)

		print("Fired bullet with force: "..factor)

		bullet.myName = "bullet"
		numOfBullets = numOfBullets - 1
		bulletCount.text = numOfBullets
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

	physics = require( "physics" )
	physics.start( )

	numOfBullets = maxNumOfBullets
	winCounter = 0

	if(playBtn ~= nil) then 
		playBtn:removeSelf()
		playBtn = nil 
	end
	if(winText ~= nil) then 
		winText:removeSelf()
		winText = nil
	end

	planets = {}
	for i=2,4 do
		local radius = math.random( 50 ) + 50
		local planet = display.newImageRect( "sprites/planet"..i..".png", radius * 2, radius * 2 )
		planet.x = math.random( screenW )
		planet.y = screenH * 0.7  * (i ) / 4  
		local realRadius = radius * 0.66
		planet.radius = realRadius
		local density = 1.0
		planet.density = density
		physics.addBody( planet, "static", {density=density, friction=0, bounce=1, radius=realRadius } )



		group:insert( planet )
		table.insert( planets, planet )
	end

	local goalRadius = 20
	goal = display.newCircle( group, halfW, 30, goalRadius )
	goal.myName = "goal"
	physics.addBody( goal, "static", {density=1, friction=0, bounce=1, radius=goalRadius } )

	leftWall = display.newRect( group, -100, 0, 100, screenH )
	topWall = display.newRect( group, 0, -100, screenW, 100 )
	rightWall = display.newRect( group, screenW, 0, 100, screenH )
	bottomWall = display.newRect( group, 0, screenH, screenW, 100 )
	physics.addBody( leftWall, "static", {density=1, friction=0, bounce=1 } )
	physics.addBody( topWall, "static", {density=1, friction=0, bounce=1 } )
	physics.addBody( rightWall, "static", {density=1, friction=0, bounce=1 } )
	physics.addBody( bottomWall, "static", {density=1, friction=0, bounce=1 } )

	physics.setGravity( 0, 0 )

	reticule = display.newCircle( group, halfW, halfH, 10 )
	reticule.isVisible = false

	cannon = display.newRect( group, halfW, screenH - 20, 10, 20 )

	if(bulletCount ~= nil) then
		bulletCount:removeSelf( )
		bulletCount = nil
	end
	bulletCount = display.newText( numOfBullets, 20, screenH - 20, "Helvetica", 16 )

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
	storyboard.purgeAll( )
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end



function gameLoop(event)
	--print("gameloop called")
	for i,v in ipairs(planets) do
		--print("planet"..i)

		calculateForce(v)
	end

	if(isFiring) then
		fireBullet()
	end
end


function calculateForce(planet)

	local area = math.pow(planet.radius, 2) * math.pi
	local mass = area * planet.density

	for i=1,#bullets do
		local bullet = bullets[i]
		local distance = getDistance(bullet, planet)
		local force = mass * gravityConstant / math.pow(distance, 2)
		local angle = getFaceAngle(bullet, planet)
		local xForce = math.cos(angle) * force
		local yForce = math.sin(angle) * force
		bullet:applyForce( xForce, yForce, bullet.x, bullet.y )
		--print("xForce: "..xForce.." yForce: "..yForce)
	end
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

Runtime:addEventListener( "collision", onCollision )
-----------------------------------------------------------------------------------------

return scene