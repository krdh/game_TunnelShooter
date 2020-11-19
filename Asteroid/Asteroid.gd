extends Area2D

#------------------------------------------------------------------------------

const DEFAULT_ASTEROIDSPEED = 300.0         # speed when just spawned
const DEFAULT_ASTEROIDSCALE =   1.0         # scale when reaching player 'radius'
const DEFAULT_HEALTH        =   5           # nr of hits required to kill asteroid
const DEFAULT_SATOSHI       = 500           # reward for killing asteroid
#- - - - - - - - - - - - - - - - - - - - -  var's
var asteroidconfig = {
	selfdestruct   = false,
	speed          = DEFAULT_ASTEROIDSPEED,
	scalemod       = DEFAULT_ASTEROIDSCALE,
	health         = DEFAULT_HEALTH,
	satoshi        = DEFAULT_SATOSHI
	}
#- - - - - - - - - - - - - - - - - - - - -
var look_once      = true
var velocity       = Vector2(1,1)                           # direction of asteroid 
var speedmod       = DEFAULT_ASTEROIDSPEED

#- - - - - - - - - - - - - - - - - - - - -  
onready var res_floatingtext = preload("res://ScoreBoard/FloatingText.tscn")

#------------------------------------------------------------------------------
func _ready():
	# test if the Global.gd variables/methods exist are valid
	if not get_node_or_null("/root/Global") != null : print("Global node missing")
	#if not Global.has_method("instance_node")       : print("Global method instance_node() missing")
	if not "center" in Global                       : print("Global.center missing")

#------------------------------------------------------------------------------
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if look_once:
		spawn_asteroid()
		look_once = false
	
	global_position += velocity.rotated(rotation) * speedmod * delta
	
	# var i will go down from '0' to '1' while traveling
	var i : float = global_position.distance_to(Global.center) / Global.radius
	scale.x   = i * asteroidconfig.scalemod
	scale.y   = i * asteroidconfig.scalemod
	speedmod  = i * asteroidconfig.speed

	if ( asteroidconfig.health <= 0 ) or asteroidconfig.selfdestruct :
		$CollisionShape2D.set_deferred("disabled", true)    # prevent successive bullets hitting the explosion animation
		Global.node_sound_guy.get_node("explosion").play()
		
		var balloon = res_floatingtext.instance()
		balloon.position = position
		balloon.amount = asteroidconfig.satoshi
		Global.node_creation_parent.add_child(balloon)  # ! add to 'root' scene ivm coordinates
		Global.add_satoshi(asteroidconfig.satoshi)      #scoreboard.satoshi += reward
		self.queue_free()

#------------------------------------------------------------------------------
func spawn_asteroid():
	position = Global.center
	look_at( Global.center )            # look away from center
	var randani = ["brown","gold","white"]
	$AnimatedSprite.animation = randani[ randi()%3 ]
	velocity                  = velocity.rotated( rand_range(0, 2*PI) )
	speedmod                  = asteroidconfig.speed + rand_range(0, 200)
	asteroidconfig.scalemod  *= rand_range(0.5, 2)
	#asteroidconfig.health    = DEFAULT_HEALTH

#------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_screen_exited():
	if asteroidconfig.selfdestruct == false:
		self.queue_free()
#------------------------------------------------------------------------------
func _on_Asteroid_area_entered(area):
	if area.is_in_group("Enemy_damager"):
		if "Bullet" in area.get_name() :
			asteroidconfig.health -= 1
			asteroidconfig.scalemod *= 0.8                              # make asteroid smaller when hit		
		elif "Plasmabolt" in area.get_name() :
			asteroidconfig.health = 0
		elif "idegunbullet" in area.get_name() :
			asteroidconfig.health = 0

		area._destroy_node()                             # request bullet node to destroy itself

	if area.is_in_group("player_shield"):
		asteroidconfig.health = 0

		if asteroidconfig.health <= 0 :
			asteroidconfig.selfdestruct = true

#------------------------------------------------------------------------------
