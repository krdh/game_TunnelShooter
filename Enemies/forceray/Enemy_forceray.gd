extends Node2D

#------------------------------------------------------------------------------

const DEFAULT_RAYSHIPSPEED = 80               # speed when just spawned
const DEFAULT_RAYSHIPSCALE = 1.0               # scale when reaching player 'radius'
const DEFAULT_HEALTH       = 4                 # nr of hits required to kill 
#- - - - - - - - - - - - - - - - - - - - -  var's
var look_once            = true
var velocity_left        = Vector2(1,0)        
var velocity_right       = Vector2(1,0)  
var raymodulate          = 0.5
var ray_scale            = DEFAULT_RAYSHIPSCALE
var speed:float          = DEFAULT_RAYSHIPSPEED
var health_left :float   = DEFAULT_HEALTH
var health_right:float   = DEFAULT_HEALTH
var shipskilled:int      = 0
var shipkilled_left      = false
var shipkilled_right     = false
#- - - - - - - - - - - - - - - - - - - - -  
onready var res_floatingtext = preload("res://ScoreBoard/FloatingText.tscn")

#------------------------------------------------------------------------------
func _ready():
	randomize()
	# modulate raycolors
	$Tween.interpolate_property(self,"raymodulate", 1 ,-1 ,1 ,Tween.TRANS_LINEAR,Tween.EASE_IN )
	$Tween.repeat = true
	$Tween.start()

#------------------------------------------------------------------------------
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if look_once:
		spawn_rayships()
		look_once = false
	
	$Rayship_left.global_position   += velocity_left.rotated(rotation)  * speed * delta
	$Rayship_right.global_position  += velocity_right.rotated(rotation) * speed * delta
		
	# var i will go from '0' to '1' while traveling
	var i : float = $Rayship_left.global_position.distance_to(Global.center) / Global.radius
	$Rayship_left.scale.x  = i 
	$Rayship_left.scale.y  = i 
	$Rayship_right.scale.x = i 
	$Rayship_right.scale.y = i 
	ray_scale              = 0.1 + i
	speed                  = DEFAULT_RAYSHIPSPEED  *  ( 0.5 + i )

	if ( i > 1.2 ):
		self.queue_free()
	
	if ( i > 0.02 ):
		$Rayship_left.look_at( Global.center )
		$Rayship_right.look_at( Global.center )
		$Rayship_left.rotate(-0.5*PI)
		$Rayship_right.rotate(-0.5*PI)

	if not ( shipkilled_left and shipkilled_right ):
		updateLine2D()
	elif   ( shipkilled_left and shipkilled_right ):
		self.queue_free()

#------------------------------------------------------------------------------
func updateLine2D():
	var inbetweenpoint = $Rayship_left.position.linear_interpolate($Rayship_right.position, abs(raymodulate) )
	$ray/Line2D.width = 15 * ray_scale
	$ray/Line2D.set_point_position(0,$Rayship_left.position)
	$ray/Line2D.set_point_position(1,inbetweenpoint)
	$ray/Line2D.set_point_position(2,$Rayship_right.position)
	$ray/CollisionShape2D.shape.set_a($Rayship_left.position)
	$ray/CollisionShape2D.shape.set_b($Rayship_right.position)

#------------------------------------------------------------------------------
func spawn_rayships():
	position = Global.center            # move whole!! node to Global Center
	look_at( Global.center )            # look away from center
	$Rayship_left.rotate(-0.5*PI)
	$Rayship_right.rotate(-0.5*PI)
	
	var velocity   = Vector2(1,0)
	velocity       = velocity.rotated( rand_range(0, 2*PI) )
	velocity_left  = velocity.rotated( -0.1*PI )
	velocity_right = velocity.rotated(  0.1*PI )
	
	speed        = DEFAULT_RAYSHIPSPEED
	health_left  = DEFAULT_HEALTH
	health_right = DEFAULT_HEALTH

#------------------------------------------------------------------------------
func popupballoon(s:String):
	var balloon = res_floatingtext.instance()
	if   ( s == "left"  ):
		balloon.position = $Rayship_left.global_position
		balloon.amount = 601
	elif ( s == "right" ):
		balloon.position = $Rayship_right.global_position
		balloon.amount = 602
	else :
		return
	Global.node_creation_parent.add_child(balloon)  # !!! add to 'root' scene ivm coordinates
	Global.add_satoshi(601)   #scoreboard.satoshi += 601
	
#------------------------------------------------------------------------------
func _on_Rayship_right_area_entered(area):
	if not shipkilled_right:
		if area.is_in_group("Enemy_damager"):
			area._destroy_node()
			if   "Bullet"       in area.get_name() : health_right -= 1
			elif "Plasmabolt"   in area.get_name() : health_right  = 0
			elif "idegunbullet" in area.get_name() : health_right  = 0;	

		if area.is_in_group("player_shield"):
			health_right  = 0;	

		if (health_right <= 0):
			shipkilled_right = true
			Global.node_sound_guy.get_node("explosion").play()
			popupballoon("right")
			$Rayship_right.visible = false
			$Rayship_right/CollisionShape2D.set_deferred("disabled", true )
			$ray/CollisionShape2D.set_deferred("disabled", true)
			$ray/Line2D.visible = false

#------------------------------------------------------------------------------
func _on_Rayship_left_area_entered(area):
	if not shipkilled_left:
		if area.is_in_group("Enemy_damager"):
			area._destroy_node()
			if   "Bullet"       in area.get_name() : health_left -= 1
			elif "Plasmabolt"   in area.get_name() : health_left  = 0
			elif "idegunbullet" in area.get_name() : health_left  = 0;	

		if area.is_in_group("player_shield"):
			health_left  = 0;	
			
		if ( health_left <= 0 ):
			shipkilled_left = true
			Global.node_sound_guy.get_node("explosion").play()
			popupballoon("left")
			$Rayship_left.visible = false
			$Rayship_left/CollisionShape2D.set_deferred("disabled", true )
			$ray/CollisionShape2D.set_deferred("disabled", true)
			$ray/Line2D.visible = false
#------------------------------------------------------------------------------

func _on_ray_area_entered(area):
	if not ( shipkilled_left and shipkilled_right ):
		if area.is_in_group("Enemy_damager"):   # TODO if 'ship' then damage shield
			pass  #print("ray has been shot")    

#==============================================================================
