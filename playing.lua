local composer = require("composer")
local playing = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Requires
-- -----------------------------------------------------------------------------------

local tiled = require "com.ponywolf.ponytiled"
local physics = require "physics"
local json = require "json"

local Vector2 = require("lib.Vector2")
local Perspective = require "com.gymbylcoding.perspective"

local Player = require("Player")
local PlayerSave = require("PlayerSave")

-- -----------------------------------------------------------------------------------
-- Events
-- -----------------------------------------------------------------------------------

local function onTouch(event)

	if event.phase == "ended" then
		if math.abs(event.xStart - event.x) >= 40 then
			-- swipping finger on screen
			if PlayerSave.swipeOnAir or PlayerSave.swipeAbility and not player.jumping then
				-- depending on the direction of the finger
				if event.xStart - event.x >= 40 then 
					player.dx = -1
				else
					player.dx = 1
				end
				-- flip player horizontally
				player.xScale = player.pscale * player.dx
				-- save old velocities as they could be reseted when
				-- applying linear velocity
				local vx, vy = player:getLinearVelocity()
				player:setLinearVelocity(player.speed*player.dx, vy)
			end
		elseif not player.jumping then
			if player.collisions[2] or player.collisions[4] then
				--inefficient way but there are some problems with bottom collision
				local vx, vy = player:getLinearVelocity()
				if vy == 0 or player.collisions[3] then
					-- basically checks if player 
					-- is not jumping or falling 
					player.dx = player.dx * -1
					player.xScale = player.pscale * player.dx
				end
			end
			player:setAnimation("jump")
			player:setLinearVelocity(player.speed*player.dx, player.jumpForce)
		 	player.jumping = true
		elseif PlayerSave.wallJump and (player.collisions[2] or player.collisions[4]) then
			-- check if colliding horizontally
			if player.collisions[2] then
		 		player.dx = -1
		 	else
		 		player.dx = 1
		 	end
			player.xScale = player.pscale * player.dx
		 	player:setLinearVelocity(player.speed*player.dx, player.jumpForce-400)
		elseif PlayerSave.doubleJump and not player.hasAlreadyJumped then
			player:setAnimation("jump")
		 	player:setLinearVelocity(player.speed*player.dx, player.jumpForce)
		 	player.hasAlreadyJumped = true
		end
	end
end


local function onPlayerPreCollision(self, event)

	if event.contact == nil then return end

	if event.other.isWater and PlayerSave.walkOnWater then
		event.contact.isEnabled = false
	end

end

local function onPlayerCollision(self, event)

	if event.other.isObject then return nil end
	if event.phase == "began" then
		-- not the best way to do it as im having some issues
		-- when player goes from one tile to another and they
		-- are too close
		self.collisions[event.selfElement] = true
		if self.jumping and event.selfElement == 3 then 
			-- player lands

			-- check if player actually has linear velocity variable
			-- as when player is created may give some problems
			if self.setLinearVelocity then
				-- reset the walking
				self:setLinearVelocity(self.speed*self.dx, 0)
				-- back to run animation
				self:setAnimation("run")
			end
			--reset jumping and double jump
			self.jumping = false
			self.hasAlreadyJumped = false
		end
	elseif event.phase == "ended" then
		self.collisions[event.selfElement] = false
	end

end

local function playerOnDoor(self, event)

	-- gets property called map set in Tiled
	PlayerSave.map = self.map

	-- clears everything
	Runtime:removeEventListener("touch", onTouch)
	playing:clearLevel()

	composer.removeScene("playing")
	composer.gotoScene("restart")

end

local function playerOnWater(self, event)

	if not PlayerSave.walkOnWater then
		playing:clearLevel()

		composer.removeScene("playing")
		composer.gotoScene("restart")
	end

end

local function playerOnSpike(self, event)

	playing:clearLevel()
	composer.removeScene("playing")
	composer.gotoScene("restart")

end

local function playerTookObject(objectName)
	local text = display.newText(objectName, display.contentCenterX, display.contentCenterY - 100, native.systemFontBold, 32)
	text:setFillColor(0,0,0)

	return text
end

local function playerOnObject(self, event)

	--wallJump = true, --jumping on walls
	--doubleJump = true,
	--swipeAbility = true, --change side by swiping the finger
	--swipeOnAir = true,
	--walkOnWater = true

	local text

	if self.object == "wallJump" then
		text = playerTookObject("Wall Jump")
		PlayerSave.wallJump = true
	elseif self.object == "doubleJump" then
		text = playerTookObject("Double Jump")
		PlayerSave.doubleJump = true
	elseif self.object == "swipeAbility" then
		text = playerTookObject("Swipe!")
		PlayerSave.swipeAbility = true
	elseif self.object == "swipeOnAir" then
		text = playerTookObject("Swipe on air!")
		PlayerSave.swipeOnAir = true
	elseif self.object == "walkOnWater" then
		text = playerTookObject("Walk on water")
		PlayerSave.walkOnWater = true
	elseif self.object == "win" then
		text = playerTookObject("You won")

		composer.removeScene("playing")
		timer.performWithDelay(1000, function() composer.gotoScene("menu") end)
	end

	timer.performWithDelay(1000, function() text:removeSelf() end)

	self:removeSelf()

end

-- -----------------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------------

local player
local backgroundMusicChannel

function playing:clearLevel()

	self.map:removeSelf()
	self.camera:destroy()
	player:removeSelf()
	audio.stop(backgroundMusicChannel)

end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function playing:create( event )

	local sceneGroup = self.view

	-- create camera
	self.camera = Perspective.createView()

	--audio
	local music
	if PlayerSave.map == "LVL9" then
		music = audio.loadStream("assets/music/lvl9.mp3")
	else
		music = audio.loadStream("assets/music/bg1.mp3")
	end
	audio.setMaxVolume(0.25)
	backgroundMusicChannel = audio.play(music, { loops = -1 })

	-- start physics before loading the map
	physics.start()
	physics.setGravity(0,20)
	--physics.setDrawMode("hybrid") --hitboxes

	--Load an object based map from a JSON file
	local mapData = json.decodeFile(
		system.pathForFile( -- load from json export
			"maps/" .. PlayerSave.map .. ".json", 
			system.ResourceDirectory
		)
	)
	self.map = tiled.new(mapData, "maps/") -- maps/../assets/tileset/

	-- get object in tiled map
	-- player must be invisible in tiledmap so the ponytiled library doesn't show it
	local playerObj = self.map:findObject("hero")
	playerObj.isVisible = false

	player = Player:new(playerObj)
	player:setAnimation("run")

	-- adds player and map to the camera
	self.camera:add(player, 1)
	self.camera:add(self.map, 2)
	self.camera:prependLayer()

	-- make player dragable for debug reasons
	-- local dragable = require "com.ponywolf.plugins.dragable"
	-- player = dragable.new(player)

	-- Event handling ----------
	self.camera.damping = 10 -- A bit more fluid tracking
	self.camera:setFocus(player) -- Set the focus to the player
	self.camera:track() -- Begin auto-tracking

	player.preCollision = onPlayerPreCollision
	player.collision = onPlayerCollision
	player:addEventListener("preCollision", player)
	player:addEventListener("collision", player)
	Runtime:addEventListener("touch", onTouch)

	local doors = self.map:listTypes("door")
	for i, door in pairs(doors) do
		door.collision = playerOnDoor
		door:addEventListener("collision", door)
	end

	local waterTiles = self.map:listTypes("water")
	for i, water in pairs(waterTiles) do
		water.collision = playerOnWater
		water.isWater = true
		water:addEventListener("collision", water)
	end

	local spikeTiles = self.map:listTypes("spike")
	for i, spike in pairs(spikeTiles) do
		spike.collision = playerOnSpike
		spike:addEventListener("collision", spike)
	end

	local objects = self.map:listTypes("habilidad")
	for i, object in pairs(objects) do
		object.collision = playerOnObject
		object.isObject = true
		object:addEventListener("collision", object )
	end

end

-- show()
function playing:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end

-- hide()
function playing:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end

-- destroy()
function playing:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
playing:addEventListener( "create", playing )
playing:addEventListener( "show", playing )
playing:addEventListener( "hide", playing )
playing:addEventListener( "destroy", playing )
-- -----------------------------------------------------------------------------------

return playing