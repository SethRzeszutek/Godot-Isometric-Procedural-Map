extends Node2D

## Instantiate
var noise = OpenSimplexNoise.new();

### Configure ###
##NOTE: For rotate to work this must be a pefect square.
#var width = 50
#var height = width
var SIZE = 10

var Octaves = 6 #originally 4
var Period = 30.0 #originally 20
var Persistence = 0.3 #originally 8

#SET TILES Y by -48#
var rotateGrid = []
var N = SIZE #size of map can be either height or width when a perfect square

###BUTTON SET UP###
var buttons = []
onready var run_button = preload("res://Other_Scenes/Button.tscn")
onready var circle_button = preload("res://Other_Scenes/CircleButton.tscn")
onready var rotate_button = preload("res://Other_Scenes/RotateButton.tscn")
onready var zoom_in_button = preload("res://Other_Scenes/ZoomIn.tscn")
onready var zoom_out_button = preload("res://Other_Scenes/ZoomOut.tscn")
onready var data_button = preload("res://Other_Scenes/StartData.tscn")

func _ready():
	create_buttons()
	set_process_input(true)
	var rec = Rect2(300,150,400,200)
	get_node("UI/AcceptDialog").popup(rec)

func _input(event):
	if event.is_action_pressed("ui_accept"):  squareMap()
	if event.is_action_pressed("ui_cancel"):  deleteMap()
	if event.is_action_pressed("rotate"):  rotateMap()	
	
func _process(delta):
	var rotate_fail = Input.is_action_pressed("rotate_fail")
	if(rotate_fail):
		rotateMapFail()

func squareMap():
	deleteMap()
	var size = int($UI/Base/SizeGroup/Size.get_text())
	var octave = float($UI/Base/OctaveGroup/Octave.get_text())
	var period = float($UI/Base/PeriodGroup/Period.get_text())
	var persistence = float($UI/Base/PersistGroup/Persistence.get_text())
	
	if(size > 500):
		var node = get_node("UI/Base/SizeGroup/Size")
		node.set_text("500")
		size = 500
	
	SIZE = size
	Octaves = octave
	Period = period
	Persistence = persistence
	
	var temp = simplexNoise()
	createMap(temp);

func rotateMap():
	var tempgrid = rotateGrid
	deleteMap()
	N = SIZE
	rotateGrid = rotate(tempgrid)
	createMap(rotateGrid)
	
func rotateMapFail():
	var tempgrid = rotateGrid
	deleteMap()
	N = SIZE
	rotateGrid = rotateFail(tempgrid)
	createMap(rotateGrid)

func circleMap():
	var tempgrid
	deleteMap()
	var size = int($UI/Base/SizeGroup/Size.get_text())
	var octave = float($UI/Base/OctaveGroup/Octave.get_text())
	var period = float($UI/Base/PeriodGroup/Period.get_text())
	var persistence = float($UI/Base/PersistGroup/Persistence.get_text())
	
	if(size > 500):
		var node = get_node("UI/Base/SizeGroup/Size")
		node.set_text("500")
		size = 500
	
	SIZE = size	
	Octaves = octave
	Period = period
	Persistence = persistence
	tempgrid = circle()
	createMap(tempgrid)

func deleteMap():
	for i in SIZE:
		for j in SIZE:
			get_node("TileMap").set_cell(i,j,-1)
	pass

func createMap(grid):
	###Assigns tiles based on the values of the grid/matrix/2dArray
	rotateGrid = grid
	#self.set_position(Vector2(500,64))
	#self.set_position(Vector2(1,1))
	for i in SIZE:
		for j in SIZE:
			var x = grid[i][j]
			if x > -0.80 and x<-0.38: # was set to -0.60 maybe ad a deep DEEP water?
				get_node("TileMap").set_cell(i,j,5)
			elif x > -0.38 and x<-0.26:
				get_node("TileMap").set_cell(i,j,6)
			elif x > -0.26 and x<-0.14:
				get_node("TileMap").set_cell(i,j,10)
			elif x > -0.14 and x<-0.02:
				get_node("TileMap").set_cell(i,j,14) 
			elif x > -0.02 and x< 0.10:
				get_node("TileMap").set_cell(i,j,15) 
			elif x > 0.10 and x<0.22:
				get_node("TileMap").set_cell(i,j,16) 
			elif x > 0.22 and x<0.46:
				get_node("TileMap").set_cell(i,j,17)
			elif x > 0.46 and x<0.60:
				get_node("TileMap").set_cell(i,j,9) 
			elif x > 0.60 and x < 20:
				get_node("TileMap").set_cell(i,j,8)
			elif x == 9999:
				pass
	pass


func simplexNoise():
	###Generate Simplex noise, defaults as a square matrix
	var grid2 = []
	randomize()
	var x = randi()%500
	print("Seed:",x)
	noise.seed = x;
	noise.octaves = Octaves
	noise.period = Period
	noise.persistence = Persistence
	for i in range(0,SIZE):
		var tempGrid = []
		for j in range(0,SIZE):
			tempGrid.append(noise.get_noise_2d(i,j))
		grid2.append(tempGrid)
	print("Created noise - ",SIZE,"x",SIZE)
	return grid2
	
	
func circle():
	var radius
	#This has to be included for it to work correctly with odd numbers
	if SIZE%2 == 0:
		radius = int(SIZE/2)
	else:
		radius = int(SIZE/2)+1
	#center x and y
	var cx = SIZE/2
	var cy = cx
	print(cx,"x",cy)
	var r = radius
	var tiles = simplexNoise()
	tiles = make_circle(tiles, cx, cy, r)
	return(tiles)

func dist(x1, y1, x2, y2):
    return(sqrt(pow((x1 - x2),2) + pow((y1 - y2),2)))

func make_circle(tiles, cx, cy, r):
	for x in range(cx - r, cx + r):
		for y in range(cy - r, cy + r):
			if !(dist(cx, cy, x, y) <= r):
				tiles[x][y] = 9999 #could be any number, but I know I won't use 9999 tile types
	return(tiles)


# Function to rotate a matrix 
func rotate(mat):
	# Consider all squares one by one 
	for x in range(0, int(N/2)): 
		# Consider elements in group    
		# of 4 in current square 
		for y in range(x, N-x-1):   
			# store current cell in temp variable 
			var temp = mat[x][y] 
			# move values from right to top 
			mat[x][y] = mat[y][N-1-x] 
			# move values from bottom to right 
			mat[y][N-1-x] = mat[N-1-x][N-1-y] 
			# move values from left to bottom 
			mat[N-1-x][N-1-y] = mat[N-1-y][x] 
			# assign temp to left 
			mat[N-1-y][x] = temp 
	return mat

func create_buttons():
	var but = run_button.instance()
	var circle_but = circle_button.instance()
	var rotate_but = rotate_button.instance()

	var in_but = zoom_in_button.instance()
	var out_but = zoom_out_button.instance()
	var data_but = data_button.instance()
	but.rect_position = Vector2(buttons.size() * 64 + 32  , -60)
	circle_but.rect_position = Vector2(buttons.size() * 64 + 32 + 64  , -60)
	
	data_but.rect_position = Vector2(buttons.size() * 64 + 32 + 64 + 560 , -50)
	rotate_but.rect_position = Vector2(buttons.size() * 64 + 32 + 64 + 720 , -60)
	in_but.rect_position = Vector2(buttons.size() * 64 + 32 + 128 + 720 , -60)
	out_but.rect_position = Vector2(buttons.size() * 64 + 32 + 192 + 720, -60)
	$'UI/Base'.add_child(but)
	$'UI/Base'.add_child(circle_but)
	$'UI/Base'.add_child(rotate_but)
	$'UI/Base'.add_child(data_but)
	$'UI/Base'.add_child(in_but)
	$'UI/Base'.add_child(out_but)

func getSize():
	return SIZE

func rotateFail(mat):
	var top = 0
	var bottom = len(mat)-1
	var left = 0
	var right = len(mat[0])-1
  	

	while left < right and top < bottom: 
	# Store the first element of next row, 
	# this element will replace first element of 
	# current row 
		var prev = mat[top+1][left] 
		#Move elements of top row one step right 
		for i in range(left, right+1): 
			var curr = mat[top][i] 
			mat[top][i] = prev 
			prev = curr 
		top += 1
        # Move elements of rightmost column one step downwards 
		for i in range(top, bottom+1): 
			var curr = mat[i][right] 
			mat[i][right] = prev 
			prev = curr  
		right -= 1
        # Move elements of bottom row one step left 
		for i in range(right, left-1, -1): 
			var curr = mat[bottom][i] 
			mat[bottom][i] = prev 
			prev = curr 
		bottom -= 1
        # Move elements of leftmost column one step upwards 
		for i in range(bottom, top-1, -1): 
			var curr = mat[i][left] 
			mat[i][left] = prev 
			prev = curr 
		left += 1
	return mat 
