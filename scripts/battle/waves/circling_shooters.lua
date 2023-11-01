local Circling_Shooters, super = Class(Wave)

function Circling_Shooters:init()
    super.init(self)

    -- Set initial properties
    self.attacker = self:getAttackers()[1]
    self.target_x = 0
    self.target_y = 0
    self.time = 10 -- Length of attack in seconds
    self.reverse = false -- Keeps track of whether the circle should be spinning in reverse
    self.difficulty = 1 -- Set difficulty level of attack here (0 or 1)
end

function Circling_Shooters:onStart()
    -- Circle Instantiation
    self.circle = self:spawnBullet("circledbullets", Game.battle.arena.x, Game.battle.arena.y, 0, 0)
    
    -- Initialize the circle with radius and a table of bullets to be in the circle (shooterpellets in this case)
    self.circle:initiate(90, {"shooterpellet", "shooterpellet", "shooterpellet", "shooterpellet", "shooterpellet"})

    -- Set rotation speed in radians (0 for no spinning)
    self.circle.rot_speed_rads = math.rad(5)

    -- If true, shooters' rotation angles towards the center of the circle
    self.circle.angledInwards = false

    -- Increase the size of the circle over time
    self.timer:every(0.1, function()
        self.circle:adjust(self.circle.radius + 1)
    end)

    -- Spawn bullets in a pattern
    self.timer:everyInstant(#self.circle.bullets * 1, function()
        for i, bullet in ipairs(self.circle.bullets) do
            self.timer:after(i * 1, function() 
                if not self.reverse then
                    bullet:burstBullets(Game.battle.arena.x, Game.battle.arena.y, "smallbullet", 5, 0.1, 1.2)
                else
                    bullet:burstBullets(Game.battle.arena.x, Game.battle.arena.y, "smallbullet", 5, 0.1, 1.2)
                end
            end)
        end
    end, (#self.circle.bullets * 1) - 1)

    -- Reverse circle partway through the attack based on difficulty
    if self.difficulty >= 0 then
        self.timer:after((self.time/3) * 1, function()
            self.circle.rot_speed_rads = -math.rad(5)
            self.reverse = true
        end)
    end

    if self.difficulty >= 1 then
        self.timer:after((self.time/3) * 2, function()
            self.circle.rot_speed_rads = math.rad(5)
            self.reverse = false
        end)
    end
end

function Circling_Shooters:update()
    -- Spin shooters counterclockwise
    for _, bullet in ipairs(self.circle.bullets) do
        bullet.rotation = bullet.rotation - self.circle.rot_speed_rads * 2
    end

    super.update(self)
end

return Circling_Shooters
