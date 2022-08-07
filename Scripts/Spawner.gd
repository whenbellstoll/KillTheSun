extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var platform = preload("res://PlatformCollider.tscn");
var enemy = preload("res://RayEnemy.tscn");


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize();
	pass # Replace with function body.

var time = 0;
var base = 2;
var spawnPlatRange = 0;
var spawnEnemRange = 0;
var spawnNumber = 0;
var rng = RandomNumberGenerator.new();
var spawnedPlat = false;
var spawnedEnem = false;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta;
	
	if spawnNumber > 48:
		spawnNumber = 48;
	
	if spawnPlatRange == 0:
		spawnPlatRange = rng.randf_range(0, 5.0 - (spawnNumber / 10.0) );
	
	if spawnEnemRange == 0:
		spawnEnemRange = rng.randf_range(0, 7.0 - (spawnNumber / 10.0) );
	
	if time > base + spawnPlatRange && !spawnedPlat:
		spawnPlatRange = 0;
		spawnNumber += 1;
		# spawn our guys
		spawnPlatforms();
	
	if time > base + spawnEnemRange && !spawnedEnem:
		spawnEnemRange = 0;
		spawnEnemies();
	
	# if our time is greater than both, reset time
	if time > base + spawnEnemRange && time > base +  spawnPlatRange:
		time = 0;
		spawnedPlat = false;
		spawnedEnem = false;

func spawnPlatforms():
	spawnedPlat = true;
	var startPos = self.position;
	startPos.y -= 300;
	print("spawnPlat: " + str(startPos.x) + " " + str(startPos.y) );
	for n in 8:
		var yOffset = rng.randf_range(-1500, 0);
		var xOffset = rng.randf_range(-300, 300);
		var pI = platform.instance();
		pI.position = Vector2( startPos.x + xOffset, startPos.y + yOffset);
		get_tree().get_root().get_node("Node2D").add_child(pI);
	pass

func spawnEnemies():
	spawnedEnem = true;
	var startPos = self.position;
	startPos.y += 300;
	for n in 8:
		var yOffset = rng.randf_range(0, 1500);
		var xOffset = rng.randf_range(-300, 300);
		var pI = enemy.instance();
		pI.position = Vector2( startPos.x + xOffset, startPos.y + yOffset);
		add_child(pI);
	pass
