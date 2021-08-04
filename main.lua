function love.load()
    animate = require 'libraries/anim8/anim8'
    sti=require 'libraries/Simple-Tiled-Implementation/sti'
    
    love.window.setMode(1000,768)
    
    sprites={}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

    local grid = animate.newGrid(614,564,sprites.playerSheet:getWidth(),sprites.playerSheet:getHeight())

    animation={}
    animation.idle=animate.newAnimation(grid('1-15',1),0.05)
    animation.jump=animate.newAnimation(grid('1-7',2),0.05)
    animation.run=animate.newAnimation(grid('1-15',3),0.05)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0,800,false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    require('player')

    
   --[[ dangerZone = world:newRectangleCollider(0,550,800,50,{collision_class="Danger"})
    dangerZone:setType('static')]]

    platforms={}

    loadMap()

end

function love.update(dt)
    playerUpdate(dt)
    world:update(dt)
    gameMap:update(dt)

end

function love.draw()
   
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    --world:draw()
    drawPlayer()
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
end