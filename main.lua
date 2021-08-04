function love.load()
    animate = require 'libraries/anim8/anim8'

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

    platform = world:newRectangleCollider(250,400,300,100,{collision_class="Platform"})
    platform:setType('static')
    dangerZone = world:newRectangleCollider(0,550,800,50,{collision_class="Danger"})
    dangerZone:setType('static')

end

function love.update(dt)
    playerUpdate(dt)
    world:update(dt)

end

function love.draw()
    world:draw()
    drawPlayer()
end

function love.keypressed(key)
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0,-4000)
        end
    end
end

--[[function love.mousepressed(x,y,button)
    if button==1 then
        local colliders = world:queryCircleArea(x,y,200)
    end
end]]