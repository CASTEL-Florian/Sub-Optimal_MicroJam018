sharkFramePaths = ["/usr/images/sharkIdle1.png", "/usr/images/sharkIdle2.png", "/usr/images/sharkIdle3.png", "/usr/images/sharkIdle4.png", "/usr/images/sharkIdle5.png", "/usr/images/sharkIdle6.png", "/usr/images/sharkIdle7.png", "/usr/images/sharkIdle8.png"]

sharkFrames = []

for p in sharkFramePaths
    sharkFrames.push (file.loadImage(p))
end for

Shark = {}
Shark.init = function
    self.sprite = new Sprite()
    self.sprite.image = file.loadImage("/usr/images/sharkIdle1.png")
    self.sprite.x = 60
    self.sprite.scale = [1.7, 1.7]
    self.sprite.y = 590
    self.sfx = null
    self.isAttacking = false
    self.startX = 0
    self.startY = 0
    self.currentAttackTime = 0
    self.attackDuration = 0.5
    self.frameRate = 7
    self.frameTimer = 0
    self.currentFrame = 0
    self.hasMoved = false
end function

Shark.reset = function
    self.sprite.x = self.startX * tileSize + tileSize/2
    self.sprite.y = self.startY * tileSize + tileSize/2
    self.sprite.scale = [1.7, 1.7]
    self.hasMoved = false
end function

Shark.setPos = function(x, y)
    self.startX = x
    self.startY = y
    self.sprite.x = x * tileSize + tileSize/2
    self.sprite.y = y * tileSize + tileSize/2
end function


Shark.canSeePlayer = function(playerX, playerY, tiles)
    if self.startX == playerX or self.startY == playerY then
        // Check for obstacles
        endX = playerX
        endY = playerY
        
        for x in range(self.startX, endX)
            for y in range(self.startY, endY)
                if tiles.cell(x, y) != null then
                    return false // Obstacle found
                end if
            end for
        end for
        return true // No obstacles found
    end if
    return false // Not in same row or column
end function

Shark.attackPlayer = function(playerX, playerY)
    self.isAttacking = true
    
    self.destX = playerX
    self.destY = playerY
    
    self.currentAttackTime = 0
    self.hasMoved = true
end function

Shark.updateAttack = function(deltaTime)
    if (self.destX - self.startX) * self.sprite.scale[0] < 0 then self.sprite.scale = [-self.sprite.scale[0], self.sprite.scale[1]]
    if self.isAttacking then
        self.currentAttackTime += deltaTime
        t = self.currentAttackTime / self.attackDuration
        t = -(cos(pi * t) - 1) / 2  // Ease in-out function
        
        self.sprite.x = (self.startX + (self.destX - self.startX) * t) * tileSize + tileSize/2
        self.sprite.y = (self.startY + (self.destY - self.startY) * t) * tileSize + tileSize/2
        
        if self.currentAttackTime >= self.attackDuration then
            self.isAttacking = false
        end if
    end if
end function


Shark.animate = function(deltaTime)
    if not self.hasMoved then self.sprite.y = self.startY * tileSize + tileSize/2 + cos(2.5 * time) * 3 * tileSize / 64

    self.frameTimer += deltaTime
    if self.frameTimer >= 1 / self.frameRate then
        self.currentFrame = (self.currentFrame + 1) % sharkFrames.len
        self.sprite.image = sharkFrames[self.currentFrame]
        self.frameTimer = 0
    end if
end function
