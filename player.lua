player = world:newRectangleCollider(360,100,40,100,{collision_class="Player"})
player.speed=240
player:setFixedRotation(true)
player.animation = animation.idle
player.isMoving = false
player.direction=1
player.grounded=true

function playerUpdate(dt)
    
    local colliders = world:queryRectangleArea(player:getX()-20,player:getY()+50,80,2,{'Platform'})
        if #colliders > 0 then
            player.grounded=true
        else
            player.grounded=false
        end
        
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
    if player.grounded then
        if player.isMoving==true then
            player.animation=animation.run
        end
        if player.isMoving==false then
            player.animation=animation.idle
        end
    else
        player.animation=animation.jump
    end

    player.animation:update(dt)
end

function drawPlayer()
    local px,py = player:getPosition()
    player.animation:draw(sprites.playerSheet,px,py,nil,0.25*player.direction,0.25,130,300)
end