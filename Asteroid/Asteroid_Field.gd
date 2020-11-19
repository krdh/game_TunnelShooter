extends Node2D

const DEFAULT_ASTEROIDSPAWNRATE = 2          # time between asteroids

var tmr_AsteroidSpawn:Timer
var localasteroidfield_config
var spawnrate = DEFAULT_ASTEROIDSPAWNRATE

onready var res_Asteroid     = preload("res://Asteroid/Asteroid.tscn") 

#------------------------------------------------------------------------------
func _ready():
	if not "node_asteroidfield" in Global               : print("Global.node_asteroidfield missing")
	if not "node_asteroidfield_config" in Global        : print("Global.node_asteroidfield_config missing");

	Global.node_asteroidfield = self

	# copy Asteroidfield configuration from Global.gd
	localasteroidfield_config = Global.node_asteroidfield_config.duplicate(true)
	# TODO verify validity of values

	# Asteroid Spawn - instance timer,connect timeout signal to function
	tmr_AsteroidSpawn = Timer.new()
	self.add_child(tmr_AsteroidSpawn,true)
	tmr_AsteroidSpawn.wait_time = DEFAULT_ASTEROIDSPAWNRATE
	tmr_AsteroidSpawn.one_shot = true
	tmr_AsteroidSpawn.connect("timeout", self, "_on_Timer_AsteroidSpawn_timeout" )
	tmr_AsteroidSpawn.start() 
#------------------------------------------------------------------------------
func _exit_tree():
	Global.node_asteroidfield = null

func stop():
	tmr_AsteroidSpawn.stop()

func start():
	tmr_AsteroidSpawn.start()

#------------------------------------------------------------------------------
func _on_Timer_AsteroidSpawn_timeout():

	var newnode_instance = res_Asteroid.instance()
	# configure asteroid behaviour:
	newnode_instance.asteroidconfig.health     = localasteroidfield_config.health
	newnode_instance.asteroidconfig.speed      = localasteroidfield_config.speed
	newnode_instance.asteroidconfig.satoshi    = localasteroidfield_config.satoshi
	newnode_instance.position                  = Vector2(0,0)
	
	Global.node_creation_parent.add_child(newnode_instance)

	tmr_AsteroidSpawn.wait_time = localasteroidfield_config.spawnrate #+ rand_range(1, 3)
	tmr_AsteroidSpawn.start()

#==============================================================================
#func _on_Timer_AsteroidSpawn_timeout():
#	var newnode = Global.instance_node(res_Asteroid, position, Global.node_creation_parent )
#	tmr_AsteroidSpawn.wait_time = rand_range(2, 7)
#	tmr_AsteroidSpawn.start()
