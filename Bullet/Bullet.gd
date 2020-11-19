extends Area2D
#
# Needs:
#		Global.gd	var center  
#		Global.gd	var radius
#
#------------------------------------------------------------------------------
#- - - - - - - - - - - - - - - - - - - - -  Debugging var's
var db:int = 0
var dbPrint = true
#- - - - - - - - - - - - - - - - - - - - -  Constants
const DEFAULT_NOZZLESPEED = 800                     # speed when just fired
#- - - - - - - - - - - - - - - - - - - - -  
export var nozzlespeed = DEFAULT_NOZZLESPEED        
export var nozzlescale = 0.5                        # size  when just fired
export var horizon : float = 0.05                   # ship='1', inifinity='0'

var velocity = Vector2(0,-1)                # orientation of bullet .png
var speed
var look_once = true                        # used to rotate once at nodecreation
var selfdestruct = false

#------------------------------------------------------------------------------
func _ready():
	# test if the Global.gd variables/methods exist are valid
	if not get_node_or_null("/root/Global") != null : print("Global node missing")
	#if not Global.has_method("instance_node")       : print("Global method instance_node() missing")
	if not "center" in Global                       : print("Global.center missing")
	
	if not "radius" in Global                       : print("Global.radius missing");
	if ( Global.radius <= 0 ) or ( Global.radius > 4000 ):
		print("Global.radius out of range 0..4000 ");
	
	if "bullet_nozzlespeed" in Global:
		if ( Global.bullet_nozzlespeed <= 0 ) or ( Global.bullet_nozzlespeed > 4000 ):
			nozzlespeed = Global.bullet_nozzlespeed

	if "bullet_horizon" in Global:
		if ( Global.bullet_horizon <= 0 ) or ( Global.bullet_horizon > 4000 ):
			horizon = Global.bullet_horizon
#------------------------------------------------------------------------------
func _exit_tree():
	pass
	
func _destroy_node():
	selfdestruct = true
	
#------------------------------------------------------------------------------
func _process(delta):
	if look_once:
		look_at( Global.center )            # 
		rotate(0.5*PI)
		speed = nozzlespeed
		look_once = false
	
	global_position += velocity.rotated(rotation) * speed * delta
	
	# var i will go down from '1' to '0' while traveling
	var i : float = global_position.distance_to(Global.center) / Global.radius
	scale.x = i * nozzlescale
	scale.y = i * nozzlescale
	speed   = i * nozzlespeed
	
	if i < horizon or selfdestruct:   #if bullet reaches 'horizon' then destroy
		queue_free()

#------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_screen_exited():
	selfdestruct = true

#==============================================================================
