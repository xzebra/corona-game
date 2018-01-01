
local composer = require( "composer" )

local menu = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function on_play()
	composer.gotoScene("playing")
end

local function on_exit()
	if  system.getInfo("platformName")=="Android" then
		native.requestExit()
	else
		os.exit()
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function menu:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local title = display.newImageRect( sceneGroup, "assets/title.png", 408, 120 )
    title.x = display.contentCenterX
    title.y = display.contentHeight/4
     
    local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, display.contentHeight/2, native.systemFont, 60 )
    playButton:setFillColor( 0.82, 0.86, 1 )
    playButton:addEventListener("tap", on_play)
 
    local exitButton = display.newText( sceneGroup, "Exit", display.contentCenterX, 3*display.contentHeight/4, native.systemFont, 60 )
    exitButton:setFillColor( 0.75, 0.78, 1 )
    exitButton:addEventListener("tap", on_exit)
end


-- show()
function menu:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function menu:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function menu:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
menu:addEventListener( "create", menu )
menu:addEventListener( "show", menu )
menu:addEventListener( "hide", menu )
menu:addEventListener( "destroy", menu )
-- -----------------------------------------------------------------------------------

return menu
