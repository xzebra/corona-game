local Player = {}

function Player:new(playerObj)
	player = display.newImageRect(
		"assets/tileset/hero.png", 
		playerObj.width, 
		playerObj.height
	)

	player.x, player.y = playerObj.x, playerObj.y
	player.speed = 200
	player.jumping = false
	player.dx = 1
	player.hasAlreadyJumped = false

	timer.performWithDelay(50, create_collision_box)

	return player
end

function create_collision_box()
	-- Collision settings (box2d) --
	local bodyUp = {
		-player.width/2+1,-player.height/2, 
		player.width/2-1,-player.height/2, 
		player.width/2-1,-player.height/2+2, 
		-player.width/2+1, -player.height/2+2
	}
	local bodyLeft = { 
		-player.width/2, -player.height/2+4,
		-player.width/2 + 2, -player.height/2+4,
		-player.width/2 + 2, player.height/2-4, 
		-player.width/2, player.height/2-4
	}
	local bodyRight = {
		player.width/2-2, -player.height/2+4,
		player.width/2, -player.height/2+4,
		player.width/2-2, player.height/2-4, 
		player.width/2, player.height/2-4
	}
	local bodyDown = {
		-player.width/2+1, player.height/2-2,
		player.width/2-1, player.height/2-2,
		player.width/2-1, player.height/2,
		-player.width/2+1, player.height/2
	}

	physics.addBody(player, "dynamic",
		{ shape=bodyUp },
		{ shape=bodyRight },
		{ shape=bodyDown },
		{ shape=bodyLeft }
	)
	player:setLinearVelocity(player.speed*player.dx, 0)
	print("added physics")

	player.collisions = { false, false, false, false }  -- up, right, down, left
	player.isFixedRotation = true
end

return Player