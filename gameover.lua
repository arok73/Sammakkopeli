local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 -- asetetaan muuttujat helpottamaan näytön asetuksia
centerX = display.contentCenterX
centerY = display.contentCenterY
screenLeft = display.screenOriginX
screenWidth = display.contentWidth-(display.screenOriginX*2)
screenRight = display.contentWidth - display.screenOriginX
screenTop = display.screenOriginY
screenHeight = display.contentHeight-(display.screenOriginY*2)
screenBottom = display.contentHeight-display.screenOriginY
-- -----------------------------------------------------------------------------------
-- Scene event functions

-- siirrytään game sceneen
local function onPlayTouch( event )
  if ( "ended" == event.phase ) then
    composer.gotoScene("scene-game")
  end
end
-- -----------------------------------------------------------------------------------


function scene:create( event )
 
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  local background = display.newImageRect(sceneGroup, "kuvat/forest_bground.png", 475, 713) -- I make the background larger than the width/height specified in config.lua. This allows the entire device screen to be filled up with the background graphic without stretching it.
	   background.x = centerX
	   background.y = centerY

  -- luodaan otsikko
  local title = display.newImageRect(sceneGroup, "kuvat/teksti.png", 300, 230)
  	title.x = centerX
  	title.y = 175
	
	-- luodaan menu painike
	local btn_play = widget.newButton({
      left = 100,
      top = 200,
      defaultFile = "kuvat/btn_aloita.png",
      overFile = "kuvat/btn_aloita2.png",      
      onEvent = onPlayTouch
    }
	)
	btn_play.x = centerX
	btn_play.y = centerY + 100
	sceneGroup:insert(btn_play)

 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        -- This will remove the game scene when available. This is important to allow the game scene to reset itself.
        local prevScene = composer.getSceneName( "previous" )
        if(prevScene) then 
          composer.removeScene( prevScene )
        end
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene