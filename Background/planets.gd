extends Node2D

const DEFAULT_ROTATIONSPEED = 30         #  one rotation / 30 seconds
const DEFAULT_SCALE_BEGIN   = Vector2(0.2, 0.2)
const DEFAULT_SCALE_END     = Vector2(0.6, 0.6)
var   animatescale:float    = 1.0

# frame nr images in AnimatedSprite 
# enum  { sun, mercury, venus, earth, mars, jupiter, saturn, neptune }

#------------------------------------------------------------------------------
func _ready():
	# test if the Global.gd variables/methods exist are valid
	if not get_node_or_null("/root/Global") != null : print("Global.gd missing")
	if not Global.has_method("instance_node")       : print("Global.instance_node() missing")
	if not "center"  in Global                      : print("Global.center missing")
	
	Global.node_planets = self
	position = Global.center

	if Global.node_planets_config.planet > 7 :
		Global.node_planets_config.planet = 7
	if Global.node_planets_config.planet < 0 :
		Global.node_planets_config.planet = 0
	$AnimatedSprite.frame = Global.node_planets_config.planet
	
	$Tween.interpolate_property( $AnimatedSprite, "scale", DEFAULT_SCALE_BEGIN, DEFAULT_SCALE_END, 60, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _exit_tree():
	Global.node_planets = null

#------------------------------------------------------------------------------
func _process(delta):
	# rotate the planet
	var rotationspeed = delta * ( (2*PI) / DEFAULT_ROTATIONSPEED )
	self.rotate( rotationspeed )

#==============================================================================
