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
const DEFAULT_NOZZLESPEED = 100                     # speed when just fired
#- - - - - - - - - - - - - - - - - - - - -  
export var nozzlespeed = DEFAULT_NOZZLESPEED * 0.01
export var nozzlescale = 2.5                        # size  when just fired
export var direction_left = true                     # false == "right"

var speed
var do_once = true                          # used to rotate once at nodecreation
var selfdestruct = false
#var phi:float
var phicum:float
var loc  = Vector2(1,0)
var phistart:float = 0
var radius_start:float
var radius_end:float
#------------------------------------------------------------------------------
func _ready():
	# test if the Global.gd variables/methods exist are valid
	if not get_node_or_null("/root/Global") != null : print("Global node missing")
	if not "center" in Global                       : print("Global.center missing")
	
	if not "radius" in Global                       : print("Global.radius missing");
	if ( Global.radius <= 0 ) or ( Global.radius > 4000 ):
		print("Global.radius out of range 0..4000 ");
		
	radius_start = Global.radius
	radius_end   = radius_start * 0.5
	
	if "bullet_nozzlespeed" in Global:
		if ( Global.bullet_nozzlespeed <= 0 ) or ( Global.bullet_nozzlespeed > 4000 ):
			nozzlespeed = Global.bullet_nozzlespeed
			
	
	if( Global.node_ship != null ):
		#print(" req ship angle: " + str(Global.node_ship.angle ) )
		#print(" req ship pos  : " + str(Global.node_ship.position) )
		phistart = Global.node_ship.angle   # location (angle ) of playership

#------------------------------------------------------------------------------
func _exit_tree():
	pass
	
func _destroy_node():
	selfdestruct = true

#------------------------------------------------------------------------------
func _process(delta):
	if do_once:
		speed = nozzlespeed
		phicum = 0.0
		do_once = false
		loc = loc.rotated(phistart)
	
	var phi = delta * speed
	phicum += phi
	
	if (direction_left):
		loc = loc.rotated(phi)
		set_rotation( phicum + PI + (phistart) )
	else:
		loc = loc.rotated(-phi)
		set_rotation( -phicum + 2*PI + (phistart) )
	
	var radiusnow = radius_start - ((radius_start-radius_end)*phicum / PI ) 
	#position = ( Global.center + ( radiusnow * loc ) )
	position = (  radiusnow * loc  )
	
	# var i will go down from '1' to '0' while traveling
	var i : float = global_position.distance_to(Global.center) / Global.radius
	scale.x = i * nozzlescale
	scale.y = i * nozzlescale
	speed   = i * nozzlespeed
		
	if ( phicum > (PI) )  or selfdestruct:   #if bullet reaches 'horizon' then destroy
		queue_free()

#------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_screen_exited():
	selfdestruct = true

#==============================================================================

func _on_Timer_timeout():
	dbPrint = true
	pass # Replace with function body.
