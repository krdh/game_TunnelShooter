extends Node
# singletons , every node can access this
# [project]-project settings-> autoload-> path set to 'Global.gd' -> Add

#- - - - - - - - - - - - - - - - - - - - -  Constants
const DEFAULT_RADIUS = 480                  # radius of circle in pixels the ship rides on
const DEFAULT_CENTER = Vector2(512, 512)    # Center of screen
#- - - - - - - - - - - - - - - - - - - - -  node references
var node_creation_parent = null
var node_sound_guy       = null
var node_scoreboard      = null
var node_starfield       = null
var node_planets         = null
var node_asteroidfield   = null
var node_ship            = null
var node_enemywave       = null
var node_level           = null             # the different levels reference here

#- - - - - - - - - - - - - - - - - - - - -  Ship/bullet variable
var radius = DEFAULT_RADIUS                 #setget set_radius, get_radius
var center = DEFAULT_CENTER
#- - - - - - - - - - - - - - - - - - - - -  Bullet variables
#var bullet_nozzlespeed
#var bullet_horizon
#var bullets_in_scene setget set_bullets_in_scene get_bullets_in_scene

#- - - - - - - - - - - - - - - - - - - - -  node_scoreboard
var scoreboard = {
	shield        = int(100)  ,
	health        = int(100),
	satoshi       = int(0) ,
	lives         = int(3) ,
	enemieskilled = int(0)
}

signal sig_satoshi(value)

func add_satoshi(sat:int):
	var oldsats = scoreboard.satoshi
	scoreboard.satoshi += sat
	if oldsats <   2000 and scoreboard.satoshi >=    2000 : emit_signal("sig_satoshi",   2000) ;
	if oldsats <   5000 and scoreboard.satoshi >=    5000 : emit_signal("sig_satoshi",   5000) ;
	if oldsats <  10000 and scoreboard.satoshi >=   10000 : emit_signal("sig_satoshi",  10000) ;
	if oldsats <  20000 and scoreboard.satoshi >=   20000 : emit_signal("sig_satoshi",  20000) ;
	if oldsats <  50000 and scoreboard.satoshi >=   50000 : emit_signal("sig_satoshi",  50000) ;
	if oldsats < 100000 and scoreboard.satoshi >=  100000 : emit_signal("sig_satoshi", 100000) ;
	if oldsats < 200000 and scoreboard.satoshi >=  200000 : emit_signal("sig_satoshi", 200000) ;
	if oldsats < 500000 and scoreboard.satoshi >=  500000 : emit_signal("sig_satoshi", 500000) ;

#- - - - - - - - - - - - - - - - - - - - - node_starfield
const DEFAULT_STARFIELD_NRSTARS    = 128          # nr of stars 
var node_starfield_config = {
	enable   = true,
	nr_stars = DEFAULT_STARFIELD_NRSTARS,
}

#- - - - - - - - - - - - - - - - - - - - - node_planets
enum  { sun, mercury, venus, earth, mars, jupiter, saturn, neptune }
var node_planets_config = {
	enabled        = true,
	planet = 7
}

#- - - - - - - - - - - - - - - - - - - - - node_asteroidfield
const DEFAULT_ASTEROIDSPEED     = 100.0        # speed when just spawned
const DEFAULT_ASTEROIDSCALE     = 1.0          # scale when reaching player 'radius'
const DEFAULT_ASTEROIDHEALTH    = 1            # nr of (bullet) hits required to kill asteroid
const DEFAULT_ASTEROIDSPAWNRATE = 2.0          # time (sec) between asteroids
const DEFAULT_SATOSHI           = 500          # reward for killing asteroid

var node_asteroidfield_config = {
	enabled        = true,
	spawnrate      = DEFAULT_ASTEROIDSPAWNRATE,
	speed          = DEFAULT_ASTEROIDSPEED,
	scalemod       = DEFAULT_ASTEROIDSCALE,
	health         = DEFAULT_ASTEROIDHEALTH,
	satoshi        = DEFAULT_SATOSHI
	}

#------------------------------------------------------------------------------
#func set_radius(f):
#	if ( f > 0 and f < 4000 ):
#		radius = f
#		return ( true )
#	else:
#		radius = DEFAULT_RADIUS
#		return ( false )
#	pass
#func get_radius():
#	return (radius)
#------------------------------------------------------------------------------
# https://www.youtube.com/watch?v=6e9I_e8aHD4
# usage example: var bullet = instance_node( bullet_instance, global_position, get_parent() )
func instance_node(node, location, parent ):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance
#------------------------------------------------------------------------------
#==============================================================================
