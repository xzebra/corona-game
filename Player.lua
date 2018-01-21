local Player = {}

function Player:new(playerObj)

	-- player = display.newImageRect(
	-- 	 "assets/testtileset/11.png", 
	--	 playerObj.width, 
	--	 playerObj.height
	-- )

	local playerSheet = graphics.newImageSheet("assets/player.png", {
		width = 214,
		height = 370,
		numFrames = 23
	})
	local sequence = {
		{
			name = "run",
			start = 1,
			count = 13,
			time = 800,
			loopCount = 0,
			loopDirection = "forward"
		},
		{
			name = "jump",
			start = 14,
			count = 23,
			time = 800,
			loopCount = 1,
			loopDirection = "forward"
		},
	}
	player = display.newSprite(playerSheet, sequence)

	player.pscale = 0.5
	player.x, player.y = playerObj.x, playerObj.y
	player.speed = 350
	player.jumpForce = -500
	player.jumping = false
	player.dx = 1
	player.hasAlreadyJumped = false
	player.rwidth = player.width * player.pscale
	player.rheight = player.height * player.pscale

	timer.performWithDelay(50, createCollisionBox)

	-- Animations
	player.setAnimation = function(self, animationName)
		self:setSequence(animationName)
		self:play()
	end
	-- rescale animation
	player:scale(player.pscale,player.pscale)

	return player
end

function createCollisionBox()
	-- Collision settings (box2d)
	local bodyUp = {
		-player.rwidth/2+1,-player.rheight/2, 
		player.rwidth/2-1,-player.rheight/2, 
		player.rwidth/2-1,-player.rheight/2+2, 
		-player.rwidth/2+1, -player.rheight/2+2
	}
	local bodyLeft = { 
		-player.rwidth/2, -player.rheight/2+12,
		-player.rwidth/2 + 6, -player.rheight/2+12,
		-player.rwidth/2 + 6, player.rheight/2-12, 
		-player.rwidth/2, player.rheight/2-12
	}
	local bodyRight = {
		player.rwidth/2-6, -player.rheight/2+12,
		player.rwidth/2, -player.rheight/2+12,
		player.rwidth/2-6, player.rheight/2-12, 
		player.rwidth/2, player.rheight/2-12
	}
	local bodyDown = {
		-player.rwidth/2+1, player.rheight/2-2,
		player.rwidth/2-1, player.rheight/2-2,
		player.rwidth/2-1, player.rheight/2,
		-player.rwidth/2+1, player.rheight/2
	}

	physics.addBody(player, "dynamic",
		{ shape=bodyUp },
		{ shape=bodyRight },
		{ shape=bodyDown },
		{ shape=bodyLeft }
	)

	player:setLinearVelocity(player.speed*player.dx, 0)

	player.collisions = { false, false, false, false }  -- up, right, down, left
	player.isFixedRotation = true
end

return Player