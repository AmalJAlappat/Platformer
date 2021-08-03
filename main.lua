function love.load()
    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0,800,false)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    player = world:newRectangleCollider(360,100,80,80,{collisin_class="Player"})
    player.speed=240
    player:setFixedRotation(true)


    platform = world:newRectangleCollider(250,400,300,100,{collisin_class="Platform"})
    platform:setType('static')
    platform = world:newRectangleCollider(0,550,800,50,{collisin_class="Danger"})
    platform:setType('static')

end

function love.update(dt)
    world:update(dt)

    local px,py = player:getPosition()
    if love.keyboard.isDown('right') then
        player:setX(px+player.speed*dt)
    end
    if love.keyboard.isDown('left') then
        player:setX(px-player.speed*dt)
    end

end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == 'up' then
        player:applyLinearImpulse(0,-7000)
    end
end