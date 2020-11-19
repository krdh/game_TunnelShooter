extends Node2D

const LEVELNR         = 1
const LEVEL           = ("level_0" + str(LEVELNR) )

onready var res_Starfield     = preload("res://Background/Background_Starfield.tscn")
onready var res_AsteroidField = preload("res://Asteroid/Asteroid_Field.tscn")
onready var res_planets       = preload("res://Background/planets.tscn")
onready var res_Scoreboard    = preload("res://ScoreBoard/ScoreBoard.tscn")
onready var res_floatingtext  = preload("res://ScoreBoard/FloatingText.tscn")
onready var res_RayShip       = preload("res://Enemies/forceray/Enemy_forceray.tscn")
onready var res_EnemyWave     = preload("res://Enemies/EnemyWave.tscn")
onready var res_Player        = preload("res://Player/Player.tscn")

var tmr_RayShipSpawn:Timer

# enum {"start", "end" }
signal sig_level()

#------------------------------------------------------------------------------
func _ready():
	
	Global.node_level = self

	var balloon = res_floatingtext.instance()
	balloon.position = Global.center
	balloon.position.y -= 170
	balloon.amount = LEVEL
	balloon.delay = 4
	Global.node_creation_parent.add_child(balloon)

	# Rayship Spawn - instance timer,connect timeout signal to function
	tmr_RayShipSpawn = Timer.new()
	self.add_child(tmr_RayShipSpawn,true)
	tmr_RayShipSpawn.wait_time = 4
	tmr_RayShipSpawn.one_shot  = true
	tmr_RayShipSpawn.connect("timeout", self, "_on_Timer_RayShipSpawn_timeout" )
	tmr_RayShipSpawn.start() 
	
	Global.instance_node(res_Starfield    , Global.center, Global.node_creation_parent)
	#- - - - - - - - - - - - - - - - - - - - -  
	Global.node_planets_config.planet = 2
	Global.instance_node(res_planets      , Global.center, Global.node_creation_parent)
	#- - - - - - - - - - - - - - - - - - - - -  
	Global.instance_node(res_Scoreboard   , Global.center, Global.node_creation_parent)
	#- - - - - - - - - - - - - - - - - - - - -  
	Global.node_asteroidfield_config.speed     = 100.0
	Global.node_asteroidfield_config.health    =   2
	Global.node_asteroidfield_config.spawnrate =   4
	Global.instance_node(res_AsteroidField, Global.center, Global.node_creation_parent)
	#- - - - - - - - - - - - - - - - - - - - -  
	Global.instance_node(res_Player       , position     , Global.node_creation_parent)
	#- - - - - - - - - - - - - - - - - - - - -  
	Global.instance_node(res_EnemyWave    , Global.center, Global.node_creation_parent)
	
	#if Global.node_enemywave != null:
	Global.node_enemywave.connect("sigEnemyWave",self, "_on_sigEnemyWave")
	
	emit_signal("sig_level","start")
	print("level01: sending sig_level start")

#------------------------------------------------------------------------------
func _on_sigEnemyWave(value):
	if value == "end" :
		Global.node_enemywave.disconnect("sigEnemyWave",self, "_on_sigEnemyWave")
		tmr_RayShipSpawn.stop() 
		Global.node_asteroidfield.stop()
		#Global.node_starfield.stop()
		print("level01, end signal received from enemywave")
		emit_signal("sig_level","end")
		print("level01: sending sig_level end")
	if value == "start" :
		print("level01, start signal received from enemywave")
#------------------------------------------------------------------------------
func _exit_tree():
	Global.node_level = null

func self_destruct():
	self.queue_free()

#------------------------------------------------------------------------------
func _on_Timer_RayShipSpawn_timeout():
	Global.instance_node(res_RayShip, position, Global.node_creation_parent)
	tmr_RayShipSpawn.wait_time = rand_range(6, 12)
	tmr_RayShipSpawn.start()

#==============================================================================

