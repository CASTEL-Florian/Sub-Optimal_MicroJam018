import "levelEditor"

//Level = {}
//Level.init = function
//    self.file = "/usr/levels/level.txt"
//    self.collectables = []
//    self.sharks = []
//    self.playerStartPos = [5, 5]
//    self.bgColor = color.rgb(53,74,178)
//    self.thanksText = false
//end function


levelList = [
	"/*EAH4A/AA4A/*EUA*A==",
	"/*EDH4YHAH48/*EUA*A==",
	"/*CP/4D/AH4D/A/4H/*BUwAAA==",
	"/*B4R/AP45/AP+h/9f/r/9/JAEnAA=",
	"/*B+w/2H+E/2A+A/*EMhJwAA=",
	"/v/9//v/4/+H/g/8D/gf+H///QQAAA==",
	"/*B8B/gn8AHwH+H/*EMgAjdiA",
	"///3/8D/gf8D/g/4B/AH/v/9/QQJDbiYGIA=",
	"///t/9v/gDwNfBjwgeGD+Af3/QBVyMjgmuCA",
	"/*B8B/AH4AHAA4A/gP/*BMQAAA==",
]

//
//// Level 1
//level1 = new Level
//level1.init
//level1.file = "/usr/levels/level1.txt"
//level1.playerStartPos = [5, 5]
//
//levelList.push level1
//
//
//// Level 2
//level2 = new Level
//level2.init
//level2.file = "/usr/levels/level2.txt"
//level2.playerStartPos = [5, 5]
//
//levelList.push level2
//
//// Level 3
//level3 = new Level
//level3.init
//level3.file = "/usr/levels/level3.txt"
//level3.playerStartPos = [7, 5]
//
//levelList.push level3
//
//// Level 4
//level4 = new Level
//level4.init
//level4.file = "/usr/levels/level4.txt"
//level4.playerStartPos = [6, 2]
//
//h_level4 = new heart.Heart
//h_level4.init
//h_level4.setPos(9,2)
//level4.collectables.push h_level4
//
//levelList.push level4
//
//// Level 5
//level5 = new Level
//level5.init
//level5.file = "/usr/levels/level5.txt"
//level5.playerStartPos = [5, 3]
//
//b_level5 = new bubble.Bubble
//b_level5.init
//b_level5.setPos(9,2)
//level5.collectables.push b_level5
//
//levelList.push level5
//
//
//// Level 6
//level6 = new Level
//level6.init
//level6.file = "/usr/levels/level6.txt"
//level6.playerStartPos = [5, 4]
//
//levelList.push level6
//
//
//// Level 7
//level7 = new Level
//level7.init
//level7.file = "/usr/levels/level7.txt"
//level7.playerStartPos = [5, 3]
//level7.bgColor = color.rgb(29,26,89)
//
//s_level7_1 = new shark.Shark
//s_level7_1.init
//s_level7_1.setPos(8,6)
//level7.sharks.push s_level7_1
//
//s_level7_2 = new shark.Shark
//s_level7_2.init
//s_level7_2.setPos(10,3)
//level7.sharks.push s_level7_2
//
//levelList.push level7
//
//
//// Level 8
//level8 = new Level
//level8.init
//level8.file = "/usr/levels/level8.txt"
//level8.playerStartPos = [5, 4]
//level8.bgColor = color.rgb(29,26,89)
//
//s_level8_1 = new shark.Shark
//s_level8_1.init
//s_level8_1.setPos(6,6)
//level8.sharks.push s_level8_1
//
//s_level8_2 = new shark.Shark
//s_level8_2.init
//s_level8_2.setPos(8,6)
//level8.sharks.push s_level8_2
//
//h_level8_1 = new heart.Heart
//h_level8_1.init
//h_level8_1.setPos(7,4)
//level8.collectables.push h_level8_1
//
//h_level8_2 = new heart.Heart
//h_level8_2.init
//h_level8_2.setPos(5,7)
//level8.collectables.push h_level8_2
//
//levelList.push level8
//
//
//// Level 9
//level9 = new Level
//level9.init
//level9.file = "/usr/levels/level9.txt"
//level9.playerStartPos = [4, 4]
//level9.bgColor = color.rgb(29,26,89)
//
//s_level9_1 = new shark.Shark
//s_level9_1.init
//s_level9_1.setPos(10,8)
//level9.sharks.push s_level9_1
//
//s_level9_2 = new shark.Shark
//s_level9_2.init
//s_level9_2.setPos(2,7)
//level9.sharks.push s_level9_2
//
//b_level9 = new bubble.Bubble
//b_level9.init
//b_level9.setPos(12,5)
//level9.collectables.push b_level9
//
//h_level9_1 = new heart.Heart
//h_level9_1.init
//h_level9_1.setPos(5,3)
//level9.collectables.push h_level9_1
//
//h_level9_2 = new heart.Heart
//h_level9_2.init
//h_level9_2.setPos(11,3)
//level9.collectables.push h_level9_2
//
//levelList.push level9
//
//
//// Level 10
//level10 = new Level
//level10.init
//level10.file = "/usr/levels/level10.txt"
//level10.playerStartPos = [4, 3]
//level10.thanksText = true
//level10.bgColor = color.rgb(29,26,89)
//
//levelList.push level10