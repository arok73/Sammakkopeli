local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local physics = require( "physics" )
physics.start()
physics.setGravity(0, 2)
physics.setDrawMode("normal")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Asetetaan muuttujat helpottamaan näytön asetuksia 
local acw = display.actualContentWidth
local ach = display.actualContentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.contentWidth-(display.screenOriginX*2)
local screenRight = display.contentWidth - display.screenOriginX
local screenTop = display.screenOriginY
local screenHeight = display.contentHeight-(display.screenOriginY*2)
local screenBottom = display.contentHeight-display.screenOriginY


-- Muuttujien ja funktioiden ennakkoesittelyt

local flySprite, ajastinFly
local fly
local frogSprite
local frog 
local frogDiesSprite
local deadFrog
local poistaFrog
local pisteet 
local pisteLaskuri = 0 
local loppupisteet
local sydan = 5
local maxSydamet = 5
local sydanKuvakkeet = {}
local i
   
local luodaanTakiainen, ajastinTakiainen
local takiainen
local tongue
local FlySheetData
local FlySpriteSheet
local FlySequenceData
local onLocalCollision
local topbar
-- pelin äänien lataaminen
--local backgroundMusic = audio.loadSound( "aanet/pimpoy.mp3" ) 
local flySound = audio.loadSound("aanet/flying_fly.mp3")
local gameoverSound = audio.loadSound("aanet/gameover.mp3") 
local frogSound = audio.loadSound("aanet/frog_croak.mp3")
local yuckSound = audio.loadSound("aanet/frog_yuck.mp3")
local tongueSound = audio.loadSound("aanet/frog_tongue.mp3")


local isPlayingMusic = composer.getVariable( "isAudio" )

-- -----------------------------------------------------------------------------------
-- Scene event functions


local function stopGame()

    frogDiesSprite()

    audio.stop(1)
    frog:removeEventListener( "touch", frog )
    timer.cancel(ajastinTakiainen)
    timer.cancel(ajastinFly)
    composer.setVariable( "finalScore", pisteLaskuri )
    
    
end

-- Funktio menun näyttämiseksi pelaajan painettua asetus-kuvaketta ruudun yläpalkissa
local function onMenuTouch( event )
  if ( "ended" == event.phase ) then
    stopGame()
    composer.gotoScene("scene-menu")    
  end
end

local function lisaaPisteita()
    pisteLaskuri = pisteLaskuri + 10
    pisteet.text = "Pisteet: "..pisteLaskuri
end

-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Taustakuvan luonti
    local background = display.newImageRect(sceneGroup, "kuvat/forest_bground.png", 350, 570)
        background.x = centerX
        background.y = centerY

    -- Palkki näytön yläosaan
    topbar = display.newImageRect(sceneGroup, "kuvat/palkki.png", 350, 31)        
        topbar.anchorY = 0
        topbar.x = centerX
        topbar.y = screenTop


    -- Tekstiobjekti pelaajan tuloksien näyttämiseksi
    pisteet = display.newText(sceneGroup, "Pisteet: "..pisteLaskuri, 0, 0, native.systemFont, 18)
        -- pisteet:setFillColor(1)
        pisteet.anchorX = 1
        pisteet.x = screenRight - 5
        pisteet.y = topbar.y + 15


    for i = 1, maxSydamet do
       sydanKuvakkeet[i] = display.newImageRect(sceneGroup, "kuvat/elama.png",20,20)     
       sydanKuvakkeet[i].x = centerX - 60 + (sydanKuvakkeet[i].contentWidth * (i - 1))
       sydanKuvakkeet[i].y = screenTop + 15 
    end






    -- Luodaan nappi menuun palaamiseksi
    local btn_menu = widget.newButton({
      defaultFile = "kuvat/options.png",
      overFile = "kuvat/options2.png",  
      onEvent = onMenuTouch
    })
    btn_menu.x = screenLeft + 15
    btn_menu.y = topbar.y + 15
    sceneGroup:insert(btn_menu)    

    -- Luodaan sammakko sprite
    frogSprite = function()
    local FrogSheetData =  { width = 580, height= 250, numFrames = 11, sheetContentWidth=6380, sheetContentHeight=250 }
    
    -- yhdistetään spritesheet grafiikkaan
    local FrogSpriteSheet = graphics.newImageSheet("kuvat/frog_spritesheet.png" , FrogSheetData)
 
    -- sekvenssit: voi olla esim. juoksu, hengitys, ampuminen
    local FrogSequenceData = { 
        {name = "idle", frames={1} },
        {name = "eating", start=1, count=10, time=300, loopCount=1 },
        {name = "blinking", frames={1,11,1}, time=150, loopCount=4 },
        {name = "hide", frames={11} }

    }       
    
    -- luodaan frog-objekti

    frog = display.newSprite (sceneGroup, FrogSpriteSheet, FrogSequenceData)
    frog.type = "frog"
    frog.anchorX=0.8
    frog.anchorY=0.5
    frog.x = centerX +80
    frog.y = screenBottom - 50
    frog:setSequence( "idle" )
    frog:play()
    
    frog:scale(0.5,0.5)

    -- touch listener funktio
    function frog:touch( event )
        if event.phase == "began" then
            frog:setSequence( "eating" )
            frog:play()
            tongue = display.newRect(centerX +80, screenBottom - 50, 200, 10)
            tongue.alpha = 0
            tongue.id = "tongue"
            physics.addBody(tongue, "kinematic", {density = 1, friction = 0, bounce = 0})
            tongue.x = frog.x - 200
            tongue.y = frog.y 
            local function kieliTaakse()
                transition.moveTo( tongue, { x=frog.x-250, y=frog.y, time=150 } )
            end
            if not isPlayingMusic then
            local tongueAudio = audio.play(tongueSound)
            end
            transition.moveTo( tongue, { x=frog.x+200, y=frog.y, time=150, onComplete=kieliTaakse } )
            
        end
        return true
    end
    frog:addEventListener( "touch", frog )
end

    frogDiesSprite = function()

       local deadFrogSheetData =  { width = 175, height= 200, numFrames = 5, sheetContentWidth=875, sheetContentHeight=200 }
    
    -- yhdistetään spritesheet grafiikkaan
    local deadFrogSpriteSheet = graphics.newImageSheet("kuvat/frog_dies_spritesheet.png" , deadFrogSheetData)
 
    -- sekvenssit: voi olla esim. juoksu, hengitys, ampuminen
    local deadFrogSequenceData = { 
        {name = "idle", frames={1} },
        {name = "dying", frames={1,2,3,4,5} , time=400, loopCount=1 }
        
    }       
     
    deadFrog = display.newSprite (sceneGroup, deadFrogSpriteSheet, deadFrogSequenceData)
            deadFrog.anchorX=0.8
            deadFrog.anchorY=0.5
            deadFrog.x = centerX - 70
            deadFrog.y = screenBottom - 50
            deadFrog:setSequence( "dying" )
            deadFrog:play()
            deadFrog:scale(0.5,0.5)
    end

    -- Game over funktio. Taustaruudun, otsikon ja menu-napin luonti
    gameOver = function()    
        
        local gameOverBackground = display.newImageRect(sceneGroup, "kuvat/forest_bground.png", 350, 570)
            gameOverBackground.x = centerX
            gameOverBackground.y = centerY
            loppupisteet = display.newText(sceneGroup, "Loppupisteet: "..pisteLaskuri, 0, 0, native.systemFont, 18)
            loppupisteet.anchorX = 1
            loppupisteet.x = screenRight - 5
            loppupisteet.y = topbar.y + 15

        local gameOverTitle = display.newImageRect(sceneGroup, "kuvat/gameover.png", 180, 65)
            gameOverTitle.x = centerX
            gameOverTitle.y = 175

        local gameOverMenu = display.newImageRect(sceneGroup, "kuvat/btn_menu.png", 150, 65)
            gameOverMenu.x = centerX
            gameOverMenu.y = gameOverTitle.y + 120
            gameOverMenu:addEventListener("touch", onMenuTouch)

            
            stopGame() -- pysäytetään peli, kun on Game Over
    end
    flySprite = function()

        -- luodaan kärpäs-sprite
        FlySheetData =  { width = 300, height= 300, numFrames = 24, sheetContentWidth=2100, sheetContentHeight=1200 }
        
        -- yhdistetään spritesheet grafiikkaan
        FlySpriteSheet = graphics.newImageSheet("kuvat/fly_sprite.png" , FlySheetData)
     
        -- kärpäs sekvenssit
        FlySequenceData = { 
            {name = "idle", frames={5} },
            {name = "flying", start=1, count=24, time=150, loopCount=0 }
            
        } 

        -- luodaan fly-objekti. Kärpäset näyttävät lentävän ruudun yläosasta alaspäin satunnaisista kohdista.
        fly = display.newSprite (sceneGroup, FlySpriteSheet, FlySequenceData)
        fly.id = "fly"
        fly.x = math.random(screenLeft + 105, screenRight - 5)
        fly.y = screenTop - 10
        fly:setSequence( "flying" )
        fly:play()
        fly:scale(0.1,0.1)
        physics.addBody( fly, "dynamic", { friction=0.3, bounce=0, radius=10 } )
        fly.isSensor=true
        fly.isBullet=true
            function onLocalCollision(self,event)
                local function tuhoaFly()
                    if not isPlayingMusic then
                    local munchAudio = audio.play(munchSound)
                    end
                    display.remove( event.target )
                    event.target = nil
                end
        
            if (event.phase=="began" and event.other.id=="tongue") then
                transition.moveTo( event.target, { x= centerX -50, y=screenBottom - 50, time=100, onComplete=tuhoaFly } )
                pisteLaskuri = pisteLaskuri + 100
                pisteet.text = "Pisteet: "..pisteLaskuri
            end
            end
                fly.collision = onLocalCollision
                fly:addEventListener( "collision" )
    end
    -- luodaan takias-objekti. Takiaiset näyttävät putoavan ruudun yläosasta alaspäin satunnaisista kohdista.
    luodaanTakiainen = function()

        takiainen = display.newImageRect(sceneGroup, "kuvat/takiainen.png", 20, 20)
        takiainen.type = "takiainen"
        takiainen.x = math.random(screenLeft+ 105, screenRight - 5)
        takiainen.y = screenTop -10
        
        takiainen:scale(0.8,0.8)
        physics.addBody( takiainen, "dynamic", { friction=0.3, bounce=0, radius=10 } )
        takiainen.isSensor=true
        takiainen.isBullet=true
    
        -- Törmäys funktio. Jos sammakko syö takiaisen vähennetään yksi sydän. Kun sydämet loppuvat, siirrytään gameover-funktioon.
        function onLocalCollision(self, event)
    
            local function tuhoaTakiainen()
                
                
                display.remove( event.target )
                event.target = nil
                    if 
                        sydan == 1 then
                        sydanKuvakkeet[sydan].isVisible = false
                        sydan = sydan - 1
                        frog:setSequence("hide")
                        frog:play()
                        display.remove( event.target )
                        event.target = nil
                        
                        if not isPlayingMusic then
                        local gameoverAudio = audio.play(gameoverSound)
                        end
                        gameOver()
                        else if sydan > 1 then 
                        sydanKuvakkeet[sydan].isVisible = false
                        sydan = sydan - 1
                        frog:setSequence("blinking")
                        frog:play()

                        if not isPlayingMusic then
                        local yuckAudio = audio.play(yuckSound)
                        end
                        display.remove( event.target )
                        event.target = nil
                        else
                            if not isPlayingMusic then
                            local gameoverAudio = audio.play(gameoverSound)
                            end
                            gameOver()
                        end
                    end

            end 
       
                    if (event.phase=="began" and event.other.id=="tongue") then

                        transition.moveTo( event.target, { x= centerX -50, y=screenBottom - 50, time=100, onComplete=tuhoaTakiainen } )
                        
                    end

        end
        takiainen.collision = onLocalCollision
        takiainen:addEventListener( "collision")
    end 

end



-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        -- Pelin kulku käynnistyy täältä. 
        if isPlayingMusic then
            audio.pause()
            else
            audio.resume()
			
        local flyAudio = audio.play(flySound, {channel= 1, loops = -1})
		--local bgAudio = audio.play(backgroundMusic, {channel= 2, loops = -1})
        end
        ajastinFly = timer.performWithDelay(900, flySprite, 0)
        ajastinTakiainen = timer.performWithDelay(1500, luodaanTakiainen, 0)
        sydan = 5
        frogSprite()
    end
end

-- hide(), this function is not used in this template and here for learning purposes only.
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy(), this function is not used in this template and here for learning purposes only.
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