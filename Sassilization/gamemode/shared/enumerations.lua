--------------------
--    Sassilization
--    By Sassafrass / Spacetech / LuaPineapple
--------------------

GRID_SIZE = 16
GRID_CLOSE = GRID_SIZE * 0.5

SOLID = MASK_SOLID_BRUSHONLY

CHECK_MASK = bit.bor(CONTENTS_SOLID, CONTENTS_PLAYERCLIP)

SA.VIPBONUS = 1.25
SA.INTERMISSION = 10            --Time between each round or map
SA.ROUNDCHANGELIMIT = 1            --Number of rounds before the map changes
SA.PLAYEDROUNDS = 1                --The current round (DON'T CHANGE THIS)
SA.BONUSPOINTCOUNT = 20            --Number of points needed for a reward
SA.BONUSCASH = 37                --Number of money for each bonus reward
SA.STARTDELAY = 100                --The time before the game starts
SA.ALLOWALL = false                --No more store
SA.ALLIANCES = true                --No Alliances
SA.ALLIEDRESOURCES = false        --Should Allies share Resources
SA.ALLIEDTERRITORIES = false    --Should Allies share Territories
SA.MONUMENTS = {}                --Dunno what this is for
SA.UNITDATA = nil                --Used for passing the unit table to the respective effect entity
SA.DEFAULT_INCOME_IRON = 8
SA.DEFAULT_INCOME_FOOD = 8

SA.FOUNDATION_HEIGHT = 10

SA.CITY_DISTANCE = 120
SA.CITY_DISTANCE_MIN = SA.CITY_DISTANCE * 0.75
SA.MIN_HOUSE_DISTANCE = 18

SA.WallUp = 8
SA.WallSpacing = 9.9 -- 8.51 - 0.5 for padding, must be >= SA.WallWidth
SA.WallUpVec = Vector(0, 0, SA.WallUp)
SA.WallWidth = 9.9
SA.WallHeight = 15

assert(SA.WallWidth <= SA.WallSpacing);

SA.MIN_WALL_DISTANCE = 32
SA.MAX_WALL_DISTANCE = 15 * SA.WallSpacing

SA.WIN_LEAD = 200
SA.WIN_LIMIT = 1000
SA.WIN_GOAL_MIN = 800
SA.WIN_GOAL = 800

VECTOR_ADD_DOWN = Vector(0, 0, -100)
VECTOR_ADD_UP = Vector(0, 0, 10)

VECTOR_UP = Vector(0, 0, 1)
VECTOR_FORWARD = Vector(1, 0, 0)
VECTOR_RIGHT = Vector(0, 1, 0)
VECTOR_ZERO = Vector(0, 0, 0)

ANGLE_ZERO = Angle(0, 0, 0)

GATE_OFFSET = Vector(0, 0, 0) -- Kinda useless now // Chewgum

UNIT_ADD_UP = Vector(0, 0, 15)