extends Node2D
# This is a template for a level

const LEVELNR         = 99
const LEVEL           = ("level_99" + str(LEVELNR) )
#- - - - - - - - - - - - - - - - - - - - -  Resources
onready var res_Starfield     = preload("res://Background/Background_Starfield.tscn")
onready var res_AsteroidField = preload("res://Asteroid/Asteroid_Field.tscn")
onready var res_planets       = preload("res://Background/planets.tscn")
onready var res_Scoreboard    = preload("res://ScoreBoard/ScoreBoard.tscn")
onready var res_floatingtext  = preload("res://ScoreBoard/FloatingText.tscn")
onready var res_RayShip       = preload("res://Enemies/forceray/Enemy_forceray.tscn")
onready var res_EnemyWave     = preload("res://Enemies/EnemyWave.tscn")
onready var res_Player        = preload("res://Player/Player.tscn")


# enum {"start", "end" }
signal sig_level()

#------------------------------------------------------------------------------
func _ready():
	if not get_node_or_null("/root/Global") != null : print("Global node missing")
	if not Global.has_method("instance_node")       : print("Global method instance_node() missing")
	if not "center" in Global                       : print("Global.center missing")
	
	Global.node_level = self

	var balloon = res_floatingtext.instance()
	balloon.position = Global.center
	balloon.position.y -= 170
	balloon.amount = "Level " + str(LEVELNR)
	balloon.delay = 4
	Global.node_creation_parent.add_child(balloon)
	
	if (node_starfield == null) :
		Global.instance_node(res_Starfield    , Global.center, Global.node_creation_parent)
	if (node_planets == null):
		Global.instance_node(res_planets      , Global.center, Global.node_creation_parent)
	if (node_scoreboard == null):
		Global.instance_node(res_Scoreboard   , Global.center, Global.node_creation_parent)
	if (node_asteroidfield == null):
		Global.instance_node(res_AsteroidField, Global.center, Global.node_creation_parent)
	Global.instance_node(res_Player       , position     , Global.node_creation_parent)
	Global.instance_node(res_EnemyWave    , Global.center, Global.node_creation_parent)
	
	if Global.node_enemywave != null:
		Global.node_enemywave.connect("sigEnemyWave_ended",self, "_on_sigEnemyWave_ended")
	
	emit_signal("sig_level","start")

#------------------------------------------------------------------------------
func _on_sigEnemyWave_ended():
	Global.node_enemywave.disconnect("sigEnemyWave_ended",self, "_on_sigEnemyWave_ended")
	Global.node_asteroidfield.stop()
	print("end of level one signal received")
	emit_signal("sig_level","end")

#------------------------------------------------------------------------------
func _exit_tree():
	Global.node_level = null

func self_destruct():
	self.queue_free()

#==============================================================================

