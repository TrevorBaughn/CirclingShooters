local CircledBullets, super = Class(Bullet)

function CircledBullets:init(x, y, dir, speed)
    -- Initialize CircledBullets object with x, y position and direction
    super.init(self, x, y, "")
    self:setScale(1, 1)
    
    -- Initialize bullet properties so it doesn't deal damage or give tp
    self.damage = 0
    self.tp = 0
    self.collideable = false
    self.destroy_on_hit = false
    
    -- Speed and direction of bullet object
    self.physics.direction = dir
    self.physics.speed = speed
    
    -- Bullets active in the circle
    self.bullets = {}
    
    -- Radius of the circle, set with adjust(radius)
    self.radius = nil
    
    -- Defines whether bullet angles will face inwards on update
    self.angledInwards = false
    
    -- Rotation speed in radians (use math.rad(degrees) for conversion)
    self.rot_speed_rads = 0
end

function CircledBullets:update()
    super.update(self)
    
    -- Update bullet angles to face inwards if angledInwards is true
    if self.angledInwards then
        for i in pairs(self.bullets) do
            self.bullets[i].rotation = Utils.angle(self.bullets[i].x, self.bullets[i].y, 0, 0)
        end
    end
    
    -- Update the rotation of the entire CircledBullets object
    self.rotation = self.rotation + self.rot_speed_rads
end

-- Adjust circle bullet positions based on radius
function CircledBullets:adjust(radius)
    self.radius = radius
    
    for i = 1, #self.bullets, 1 do
        -- Calculate radians for bullet's position around the circle
        local radians = math.rad(360 / #self.bullets * i)
        
        -- Calculate bullet's position using trigonometry
        local vertical = math.sin(radians)
        local horizontal = math.cos(radians)
        
        -- Set bullet's position to move it around the circle
        local bulletX = 0 + horizontal * radius
        local bulletY = 0 + vertical * radius
        
        self.bullets[i].x = bulletX
        self.bullets[i].y = bulletY
    end
end

-- Initialize the CircledBullets object with specified radius and bullet types
function CircledBullets:initiate(radius, bullets)
    self.bullets = {}
    
    
    for i = 1, #bullets, 1 do
        -- Spawn bullet and add it to self.bullets
        local bullet = self.wave:spawnBullet(bullets[i], -1, -1, 0, 0)
        table.insert(self.bullets, bullet)
        
        -- Set the bullet's parent to self and prevent it from despawning offscreen
        bullet:setParent(self)
        bullet.remove_offscreen = false
    end
    
    -- Adjust bullet positions to form a circle
    self:adjust(radius)
end

return CircledBullets
