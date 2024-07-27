import "importUtil"
ensureImport "collectable"

Bubble = new collectable.Collectable
Bubble.init = function
    super.init
    self.sprite.image = file.loadImage("/usr/images/bubble.png")
    self.sprite.scale = [2.7, 2.7]
    self.sfx = file.loadSound("/usr/sounds/bubble_pop.wav")
end function

Bubble.reset = function
    super.reset
    self.sprite.scale = [2.7, 2.7]
end function