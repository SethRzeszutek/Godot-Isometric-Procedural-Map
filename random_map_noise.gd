
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

onready var up = preload("res://Other_Scenes/Up.tscn")
onready var down = preload("res://Other_Scenes/Down.tscn")
onready var left = preload("res://Other_Scenes/Left.tscn")
onready var right = preload("res://Other_Scenes/Right.tscn")


func _ready():
	create_buttons()
	set_process_input(true)
	var but = run_button.instance()
	but.connect_me(self)
	var but1 = run_button.instance()
	but1.connect_me(self)
	var but2 = rotate_button.instance()
	but2.connect_me(self)
	var but5 = up.instance()
	but5.connect_me(self)
	var but6 = down.instance()
	but6.connect_me(self)
	var but7 = left.instance()
	but7.connect_me(self)
	var but8 = right.instance()
	but8.connect_me(self)

func _input(event):
	if event.is_action_pressed("ui_accept"):  squareMap()
	if event.is_action_pressed("ui_cancel"):  deleteMap()
	if event.is_action_pressed("rotate"):  rotateMap()
	

func squareMap():
	deleteMap()
	var size = int($UI/Base/SizeGroup/Size.get_text())
	var octave = float($UI/Base/OctaveGroup/Octave.get_text())
	var period = float($UI/Base/PeriodGroup/Period.get_text())
	var persistence = float($UI/Base/PersistGroup/Persistence.get_text())
	
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

func circleMap():
	var tempgrid
	deleteMap()
	var size = int($UI/Base/SizeGroup/Size.get_text())
	var octave = float($UI/Base/OctaveGroup/Octave.get_text())
	var period = float($UI/Base/PeriodGroup/Period.get_text())
	var persistence = float($UI/Base/PersistGroup/Persistence.get_text())
	
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
				get_node("TileMap").set_cell(i,j,14) #To high
			elif x > -0.02 and x< 0.10:
				get_node("TileMap").set_cell(i,j,15) #Same height as 14
			elif x > 0.10 and x<0.22:
				get_node("TileMap").set_cell(i,j,16) #Way too short and texture looks spread out?
			elif x > 0.22 and x<0.46:
				get_node("TileMap").set_cell(i,j,17)
			elif x > 0.46 and x<0.60:
				get_node("TileMap").set_cell(i,j,9) #Too high
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
#	var centerX = width+width/2
#	var centerY = height+height/2
	var radius
	if SIZE%2 == 0:
		radius = int(SIZE/2)
	else:
		radius = int(SIZE/2)+1
	
	var cx = SIZE/2
	var cy = cx
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
				tiles[x][y] = 9999
#			else:
#				tiles[x][y] = 0
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
	
	var up_but = up.instance()
	var down_but = down.instance()
	var left_but = left.instance()
	var right_but = right.instance()
	
	var in_but = zoom_in_button.instance()
	var out_but = zoom_out_button.instance()
	but.rect_position = Vector2(buttons.size() * 64 + 32  , -60)
	circle_but.rect_position = Vector2(buttons.size() * 64 + 32 + 64  , -60)
	
	#up_but.rect_position = Vector2(buttons.size() * 64 + 32 + 128 + 317 , -110)
	#down_but.rect_position = Vector2(buttons.size() * 64 + 32 + 128 + 317 , -60)
	#left_but.rect_position = Vector2(buttons.size() * 64 + 32 + 74 + 317 , -60)
	#right_but.rect_position = Vector2(buttons.size() * 64 + 32 + 182 + 317 , -60)
	
	rotate_but.rect_position = Vector2(buttons.size() * 64 + 32 + 64 + 720 , -60)
	in_but.rect_position = Vector2(buttons.size() * 64 + 32 + 128 + 720 , -60)
	out_but.rect_position = Vector2(buttons.size() * 64 + 32 + 192 + 720, -60)
	$'UI/Base'.add_child(but)
	$'UI/Base'.add_child(rotate_but)
	$'UI/Base'.add_child(circle_but)
	#$'UI/Base'.add_child(up_but)
	#$'UI/Base'.add_child(down_but)
	#$'UI/Base'.add_child(left_but)
	#$'UI/Base'.add_child(right_but)
	$'UI/Base'.add_child(in_but)
	$'UI/Base'.add_child(out_but)






#############NOT USED################

#func randomNoise(width,height):
#	var grid = []
#	for i in range(width):
#		grid.append([randi()%6])
#		for j in range(height):
#			grid[i].append(randi()%6)
#	#print(grid)
#
#
#

#func NoiseFromPython(width,height):
#	noise.seed = randi();
#	noise.octaves = 4;
#	noise.period = 20.0;
#	noise.persistence = 0.8;
#
#	var gen = noise.get_noise_2d(0,1)
#
#
#	var fullvalue = []
#	for y in range(height):
#		#print("Went through y:", y)
#		var value = []
#		for x in range(width):
#			#print("Went through x", x)
#			var nx = x/width - 0.5
#			var ny = y/height - 0.5
#			#e= random.uniform(0.3, 1.9)
#			var e = 1 #* noise(1 * nx, 1 * ny,gen) +  0.5 * noise(2 * nx, 2 * ny,gen) + 0.25 * noise(4 * nx, 4 * ny,gen)
#			e = pow(e, 2.75)
#			#value.append(round(e,2))
#		fullvalue.append(value)
#	return fullvalue
