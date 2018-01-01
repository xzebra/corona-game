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

	if event.phase == "began" then
		if not player.jumping then
			if player.collisions[2] or player.collisions[4] then
				--inefficient way but there are some problems with bottom collision
				local vx, vy = player:getLinearVelocity()
				if vy == 0 then
					player.dx = player.dx * -1
					player.xScale = player.dx
				end
			end
			player:setLinearVelocity(player.speed*player.dx, -400)
	 		player.jumping = true
	 	elseif PlayerSave.jumpAbility then
	 		if player.collisions[2] or player.collisions[4] then
	 			player.dx = player.dx * -1
				player.xScale = player.dx
	 			player:setLinearVelocity(player.speed*player.dx, -400)
	 		end
	 	end
	end

end


local function onPlayerCollision(self, event)

	if event.phase == "began" then
		self.collisions[event.selfElement] = true
		if self.jumping and event.selfElement == 3 then --lands
			if self.setLinearVelocity then
				self:setLinearVelocity(self.speed*self.dx, 0)
			end
			self.jumping = false
		end
	elseif event.phase == "ended" then
		if event.selfElement == 3 then --lands
		end
		self.collisions[event.selfElement] = false
	end

end

local function playerOnDoor(self, event)

	PlayerSave.map = self.map
	Runtime:removeEventListener("touch", onTouch)
	playing:clearLevel()

	composer.removeScene("playing")
	composer.gotoScene("restart")

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

	--create camera
	self.camera = Perspective.createView()

	-- start physics before loading the map
	physics.start()
	physics.setDrawMode("hybrid") --hitboxes

	--Load an object based map from a JSON file
	local mapData = json.decodeFile(
		system.pathForFile( -- load from json export
			"maps/" .. PlayerSave.map .. ".json", 
			system.ResourceDirectory
		)
	)
	self.map = tiled.new(mapData, "maps/") --maps/../assets/tileset/

	--get object in tiled map
	--player must be invisible in tiledmap so the ponytiled library doesn't show it
	local playerObj = self.map:findObject("hero")
	playerObj.isVisible = false

	player = Player:new(playerObj)

	--adds player and map to the camera
	self.camera:add(player, 1)
	self.camera:add(self.map, 2)
	self.camera:prependLayer()

	-- make player dragable for debug reasons
	--local dragable = require "com.ponywolf.plugins.dragable"
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