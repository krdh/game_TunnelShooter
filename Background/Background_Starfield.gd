extends Node2D
#
# Movement arround axis (0,0),  so parent node needs to move us to center of screen
#
# Needs:
#		Global.gd	var node_starfield
#		Global.gd	var center
#------------------------------------------------------------------------------
func _ready():
	# test if the Global.gd variables/methods exist are valid
	if not get_node_or_null("/root/Global") != null : print("Global node missing")
	if not Global.has_method("instance_node")       : print("Global method instance_node() missing")
	if not "node_starfield" in Global               : print("Global.node_starfield missing")
	if not "node_starfield_config" in Global        : print("Global.node_starfield_config missing")
	if not "center"  in Global                      : print("Global.center missing")
	
	Global.node_starfield = self
	position = Global.center
	
	$Particles2D.emitting = Global.node_asteroidfield_config.enabled

#------------------------------------------------------------------------------
func stop():
	$Particles2D.emitting = false

func start():
	$Particles2D.emitting = true

func _exit_tree():
	Global.node_starfield = null
#==============================================================================
