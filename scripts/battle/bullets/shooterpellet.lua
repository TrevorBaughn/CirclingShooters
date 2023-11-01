local ShooterPellet, super = Class(Bullet)

function ShooterPellet:init(x, y, dir, speed)
    -- Initialize ShooterPellet object with x, y position, direction, and sprite path
    super.init(self, x, y, "bullets/smallbullet")

    -- Initialize properties
    self.scale = 0
    self:setScale(0, 0)
    self.destroy_on_hit = false

    -- Speed and direction of bullet object
    self.physics.direction = dir
    self.physics.speed = speed

    -- Active shot bullets
    self.bullets = {}
    self.maxBullets = 15
end

function ShooterPellet:update()
    super.update(self)

    -- TODO: Make less jank
    -- Scale up the bullet to size after initialization
    if self.scale < 2 then 
        self.scale = self.scale + 0.05
        self:setScale(self.scale, self.scale)
    elseif self.scale > 2 then -- If overshoot, set it to the maximum scale
        self.scale = 2
        self:setScale(self.scale, self.scale)
    end

    -- Limit the number of active bullets
    if #self.bullets > self.maxBullets then
        local indexToRemove = math.random(1, #self.bullets)
        local bulletToStop = table.remove(self.bullets, indexToRemove)
        -- Fade out the bullet and remove it
        self.wave.timer:tween(0.3, bulletToStop, { alpha = 0 }, nil, function()
            bulletToStop:remove()
        end)
    end
end

function ShooterPellet:burstBullets(target_x, target_y, bullet_type, speed, interval, lifetime)
    -- Spawn bullets in bursts at specified intervals
    self.wave.timer:everyInstant(interval, function()
        local screenX, screenY = self:getScreenPos()
        local angle = Utils.angle(screenX, screenY, target_x, target_y)
        local bulletY = screenY
        local bulletX = screenX

        -- Spawn bullet and add it to the bullets table
        local bullet = self.wave:spawnBullet(bullet_type, bulletX, bulletY, angle, speed)
        table.insert(self.bullets, bullet)
    end, (lifetime / interval) - 1)
end

function ShooterPellet:sineBullets(target_x, target_y, bullet_type, speed, frequency, amplitude, interval, burst_duration, lifetime)
    -- Spawn bullets in a sine wave pattern
    self.wave.timer:everyInstant(interval, function()
        self.wave.timer:script(function(wait)
            local time = 0

            while time < burst_duration do
                local screenX, screenY = self:getScreenPos()
                local angle = Utils.angle(screenX, screenY, target_x, target_y)

                -- Calculate vertical offset based on sine wave formula
                local yOffset = amplitude * math.sin(frequency * time)
                local bulletY = screenY + yOffset
                local bulletX = screenX

                -- Spawn bullet and add it to the bullets table
                local bullet = self.wave:spawnBullet(bullet_type, bulletX, bulletY, angle, speed)
                table.insert(self.bullets, bullet)

                time = time + DT  -- Adjust this value for the desired wave frequency
                wait(DT)  -- Match the time increment to the frame rate
            end
        end)
    end, (lifetime / interval) - 1)
end

return ShooterPellet
