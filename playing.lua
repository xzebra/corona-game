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
				player.xScale = player.dx
				-- save old velocities as they could be reseted when
				-- applying linear velocity
				local vx, vy = player:getLinearVelocity()
				player:setLinearVelocity(player.speed*player.dx, vy)
			end
		elseif not player.jumping then
			if player.collisions[2] or player.collisions[4] then
				--inefficient way but there are some problems with bottom collision
				local vx, vy = player:getLinearVelocity()
				if vy == 0 then
					-- basically checks if player 
					-- is not jumping or falling 
					player.dx = player.dx * -1
					player.xScale = player.dx
				end
			end
			player:setLinearVelocity(player.speed*player.dx, player.jumpForce)
		 	player.jumping = true
		elseif PlayerSave.wallJump and (player.collisions[2] or player.collisions[4]) then
			-- check if colliding horizontally
		 	player.dx = player.dx * -1
			player.xScale = player.dx
		 	player:setLinearVelocity(player.speed*player.dx, player.jumpForce)
		elseif PlayerSave.doubleJump and not player.hasAlreadyJumped then
		 	player:setLinearVelocity(player.speed*player.dx, player.jumpForce)
		 	player.hasAlreadyJumped = true
		end
	end
end


local function onPlayerCollision(self, event)

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

-- -----------------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------------

local player

function playing:clearLevel()

	self.map:removeSelf()
	self.camera:destroy()
	player:removeSelf()

end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function playing:create( event )

	local sceneGroup = self.view

	-- create camera
	self.camera = Perspective.createView()

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

	player.collision = onPlayerCollision
	player:addEventListener("collision", player)
	Runtime:addEventListener("touch", onTouch)

	local doors = self.map:listTypes("door")
	for i, door in pairs(doors) do
		door.collision = playerOnDoor
		door:addEventListener("collision", door)
	end

	local water = self.map:listTypes("water")
	for i, water in pairs(water) do
		water.collision = playerOnWater
		water:addEventListener("collision", water)
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