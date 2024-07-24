Collectable = {}
Collectable.init = function
    self.sprite = new Sprite()
    self.sprite.x = 60
    self.sprite.y = 590
    self.collected = false
    self.sfx = null
    self.startX = 0
    self.startY = 0
end function

Collectable.setPos = function(x, y)
    self.startX = x
    self.startY = y
    self.sprite.x = x * tileSize + tileSize/2
    self.sprite.y = y * tileSize + tileSize/2
end function

Collectable.checkCollision = function(x, y)
    if self.collected then return false
    return abs(self.sprite.x/tileSize - x - 0.5) < 0.5 and abs(self.sprite.y/tileSize - y - 0.5) < 0.5
end function


Collectable.collect = function
    self.sprite.scale = [0, 0]
    self.collected = true
    self.sfx.play()
end function

Collectable.reset = function
    self.sprite.scale = [1, 1]
    self.collected = false
end function

Collectable.animate = function
    self.sprite.y = self.startY * tileSize + tileSize/2 + cos(3 + 2 * time) * 3 * tileSize / 64
end function