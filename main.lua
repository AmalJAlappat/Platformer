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

    player = world:newRectangleCollider(360,100,40,100,{collision_class="Player"})
    player.speed=240
    player:setFixedRotation(true)
    player.animation = animation.idle
    player.isMoving = false
    player.direction=1


    platform = world:newRectangleCollider(250,400,300,100,{collision_class="Platform"})
    platform:setType('static')
    dangerZone = world:newRectangleCollider(0,550,800,50,{collision_class="Danger"})
    dangerZone:setType('static')

end

function love.update(dt)

    world:update(dt)
    if player.body then
        player.isMoving=false
        local px,py = player:getPosition()
        if love.keyboard.isDown('right') then
            player:setX(px+player.speed*dt)
            player.isMoving = true
            player.direction=1
        end
        if love.keyboard.isDown('left') then
            player:setX(px-player.speed*dt)
            player.isMoving = true
            player.direction=-1
        end
    end

    if player:enter('Danger') then
        player:destroy()
    end

    if player.isMoving==true then
        player.animation=animation.run
    end
    if player.isMoving==false then
        player.animation=animation.idle
    end

    player.animation:update(dt)
end

function love.draw()
    world:draw()
    local px,py = player:getPosition()
    player.animation:draw(sprites.playerSheet,px,py,nil,0.25*player.direction,0.25,130,300)
end

function love.keypressed(key)
    if key == 'up' then
        local colliders = world:queryRectangleArea(player:getX()-20,player:getY()+50,80,2,{'Platform'})
        if #colliders > 0 then
            player:applyLinearImpulse(0,-4000)
        end
    end
end

function love.mousepressed(x,y,button)
    if button==1 then
        local colliders = world:queryCircleArea(x,y,200)
    end
end