function love.load()
    --Added libraries
    anim8 = require 'libraries/anim8/anim8'
    sti=require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile= require 'libraries/hump/camera'
    cam=cameraFile()

    --Added sounds  
    sounds={}
    sounds.jump=love.audio.newSource("audio/jump.wav","static")
    sounds.jump:setVolume(0.75)

    sounds.music=love.audio.newSource("audio/music.mp3","stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.5)

    sounds.music:play()

    --Set Window size
    love.window.setMode(1000,768)
    
    --Added images
    sprites={}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')
    sprites.background = love.graphics.newImage('sprites/background.png')

    --Added grids for animating 
    local grid = anim8.newGrid(614,564,sprites.playerSheet:getWidth(),sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100,79,sprites.enemySheet:getWidth(),sprites.enemySheet:getHeight())
    
    --Animation initially setup
    animation={}
    animation.idle=anim8.newAnimation(grid('1-15',1),0.05)
    animation.jump=anim8.newAnimation(grid('1-7',2),0.05)
    animation.run=anim8.newAnimation(grid('1-15',3),0.05)
    animation.enemy=anim8.newAnimation(enemyGrid('1-2',1),0.03)

    --Library windfield added
    wf = require 'libraries/windfield/windfield'
    --Create new world and set gravity ,false to set objects in the world to no sleep 
    world = wf.newWorld(0,800,false)

    world:setQueryDebugDrawing(true)

    --Collision Classes added
    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')
    require('libraries/show')

    --Physics objects added
    dangerZone = world:newRectangleCollider(-500,800,5000,50,{collision_class="Danger"})
    --Type of collider set to static
    dangerZone:setType('static')

    --Created table to store all the platforms
    platforms={}

    --Set Flagposition
    flagX=0
    flagY=0

    --Data stored
    saveData={}
    saveData.currentLevel="level2"

    --Data load
    if love.filesystem.getInfo("data.lua") then
        local data=love.filesystem.load("data.lua")
        data()
    end

    --Call function loadMap
    loadMap(saveData.currentLevel)


end

function love.update(dt)
    --What needs to be updated
    playerUpdate(dt)
    updateEnemies(dt)
    world:update(dt)
    gameMap:update(dt)

    local colliders = world:queryCircleArea(flagX,flagY,10,{'Player'})
    if #colliders>0 then
        if saveData.currentLevel=="level1" then
            loadMap("level2")
        elseif saveData.currentLevel=="level2" then
            loadMap("level1")
        end
    end

    local px,py=player:getPosition()
    cam:lookAt(px,love.graphics.getHeight()/2)

end

function love.draw()
    love.graphics.draw(sprites.background,0,0)
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        --world:draw()
        drawPlayer()
        drawEnemies()
    cam:detach()
end

function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0,-4000)
            sounds.jump:play()
        end
    end
end

function spawnPlatform(x,y,width,height)
    local platform = world:newRectangleCollider(x,y,width,height,{collision_class="Platform"})
    platform:setType('static')
    table.insert(platforms,platform)
end

function destroyAll()

    local i = #platforms
    while i > -1 do  
        if platforms[i] ~= nil then
            platforms[i]:destroy()        
        end
        table.remove(platforms,i)
        i = i-1
    end


    local i = #enemies
    while i > -1 do 
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies,i)
        i = i-1
    end

end

function loadMap(mapName)
    saveData.currentLevel=mapName
    love.filesystem.write("data.lua",table.show(saveData,"saveData"))
    destroyAll()
    
    gameMap = sti("maps/" ..mapName.. ".lua")
    for i,obj in pairs(gameMap.layers["Start"].objects) do 
        playerStartX=obj.x
        playerStartY=obj.y
    end
    player:setPosition(playerStartX,playerStartY)
    for i,obj in pairs(gameMap.layers["Platforms"].objects) do 
        spawnPlatform(obj.x,obj.y,obj.width,obj.height)
    end
    for i,obj in pairs(gameMap.layers["Enemies"].objects) do 
        spawnEnemy(obj.x,obj.y)
    end
    for i,obj in pairs(gameMap.layers["Flag"].objects) do 
        flagX=obj.x
        flagY=obj.y
    end
end