import "importUtil"
ensureImport "collectable"

Heart = new collectable.Collectable
Heart.init = function
    super.init
    self.sprite.image = file.loadImage("/usr/images/heartCollectible.png")
    self.defaultScale = 3
    self.sfx = file.loadSound("/usr/sounds/heart.wav")
end function

Heart.reset = function
    super.reset
    scale = self.defaultScale * globals.tileSize / 64
    self.sprite.scale = [scale, scale]
end function