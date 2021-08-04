function love.load()
    anim8 = require 'libraries/anim8/anim8'
    sti=require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile= require 'libraries/hump/camera'
    cam=cameraFile()
    
    love.window.setMode(1000,768)
    
    sprites={}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')

    local grid = anim8.newGrid(614,564,sprites.playerSheet:getWidth(),sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100,79,sprites.enemySheet:getWidth(),sprites.enemySheet:getHeight())

    animation={}
    animation.idle=anim8.newAnimation(grid('1-15',1),0.05)
    animation.jump=anim8.newAnimation(grid('1-7',2),0.05)
    animation.run=anim8.newAnimation(grid('1-15',3),0.05)
    animation.enemy=anim8.newAnimation(enemyGrid('1-2',1),0.03)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0,800,false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')

    
   --[[ dangerZone = world:newRectangleCollider(0,550,800,50,{collision_class="Danger"})
    dangerZone:setType('static')]]

    platforms={}

    loadMap()


end

function love.update(dt)
    playerUpdate(dt)
    updateEnemies(dt)
    world:update(dt)
    gameMap:update(dt)

    local px,py=player:getPosition()
    cam:lookAt(px,love.graphics.getHeight()/2)

end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        world:draw()
        drawPlayer()
        drawEnemies()
    cam:detach()
end

function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0,-4000)
        end
    end
end

function spawnPlatform(x,y,width,height)
    local platform = world:newRectangleCollider(x,y,width,height,{collision_class="Platform"})
    platform:setType('static')
    table.insert(platforms,platform)
end

function loadMap()
    gameMap = sti('maps/level1.lua')
    for i,obj in pairs(gameMap.layers["Platforms"].objects) do 
        spawnPlatform(obj.x,obj.y,obj.width,obj.height)
    end
    for i,obj in pairs(gameMap.layers["Enemies"].objects) do 
        spawnEnemy(obj.x,obj.y)
    end
end