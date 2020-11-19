extends Node2D
# Animation to Spawn the player ship
# two shrinking circles of fireballs,  one turning left, orther tunring right
# send signal when done

const r2d = ( 360.0/(2*PI) )
const DEFAULT_RADIUS_MIN =  5
const DEFAULT_RADIUS_MAX = 400
const DEFAULT_CENTER     = Vector2(500,500)
const DEFAULT_SCALE      = Vector2(0.1, 0.1)
const DEFAULT_NR_SHARDS   = 16
const DEFAULT_ANI_SPEED  = 2

onready var res_fireball = preload("res://img/Fireball_00.png")

var shards_left          = []
var shards_right         = []
var rotation_speed:float = 1
var radius_left          = DEFAULT_RADIUS_MAX
var radius_right         = DEFAULT_RADIUS_MAX - 40
var spritescale          = Vector2(0.1, 0.1)
var sumdelta             = 0

signal sig_spawnplayer()

#------------------------------------------------------------------------------
func _ready():
	
	shards_left.clear()
	shards_right.clear()
	
	for nr in range( DEFAULT_NR_SHARDS ):
		shards_left.append( Sprite.new() )
		shards_right.append( Sprite.new() )
		self.add_child(shards_left[nr] ,true)
		self.add_child(shards_right[nr],true)
		shards_left[nr].texture  = res_fireball
		shards_right[nr].texture = res_fireball
		shards_left[nr].scale    = spritescale
		shards_right[nr].scale   = spritescale

	for nr in range( DEFAULT_NR_SHARDS ) :
			var phi = ( 2*PI ) / shards_left.size()
			shards_left[nr].position  = radius_left * Vector2(1,0).rotated( nr * phi )
			phi = ( 2*PI ) / shards_right.size()
			shards_right[nr].position = radius_right * Vector2(1,0).rotated( nr * phi )

	$Tween.interpolate_property(self,"radius_left" , DEFAULT_RADIUS_MAX, DEFAULT_RADIUS_MIN, 2.0, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self,"radius_right", DEFAULT_RADIUS_MAX, DEFAULT_RADIUS_MIN, 1.5, Tween.TRANS_SINE,Tween.EASE_IN_OUT)	
	$Tween.interpolate_property(self,"spritescale" , DEFAULT_SCALE     , Vector2(0,0)      , 2.0, Tween.TRANS_SINE,Tween.EASE_IN_OUT)		
	$Tween.start()
	emit_signal("sig_spawnplayer","start")
#------------------------------------------------------------------------------
func _process(delta):

	for nr in range( DEFAULT_NR_SHARDS ) :
		var phi = DEFAULT_ANI_SPEED * delta
		shards_left[nr].position   = shards_left[nr].position.rotated(-phi)
		shards_right[nr].position  = shards_right[nr].position.rotated(phi)
		shards_left[nr].position   = radius_left  * shards_left[nr].position.normalized()
		shards_right[nr].position  = radius_right * shards_right[nr].position.normalized()
		shards_left[nr].scale      = spritescale
		shards_right[nr].scale     = spritescale

	sumdelta += delta
	if sumdelta > 5 :
		emit_signal("sig_spawnplayer","end")
		self.queue_free() ;

#==============================================================================

