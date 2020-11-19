extends Area2D

var aggressive = true                # define if enemy ship fires at player


var node_bullet  = preload("res://Bullet/enemybullet.tscn")
var tmr_GunLoad:Timer

#------------------------------------------------------------------------------
func _ready():
	if aggressive :
		tmr_GunLoad = Timer.new()
		self.add_child(tmr_GunLoad,true)
		tmr_GunLoad.wait_time = rand_range(1,7)
		tmr_GunLoad.one_shot = true
		tmr_GunLoad.connect("timeout", self, "_on_Timer_GunLoad_timeout" )
		tmr_GunLoad.start()
#------------------------------------------------------------------------------

func _on_Timer_GunLoad_timeout():
	if ( Global.node_creation_parent != null ):
		var distance2player = global_position.distance_to(Global.node_ship.global_position)
		#print("Distance to player: "+ str(distance2player) )
		if (distance2player < 400 ):
			Global.instance_node(node_bullet, self.global_position, Global.node_creation_parent )
			Global.node_sound_guy.get_node("shoot").play()
			tmr_GunLoad.wait_time = rand_range(1,7)
			tmr_GunLoad.start()

#------------------------------------------------------------------------------
func _on_Enemy_BattleCruiser_area_entered(area):
	if area.is_in_group("Enemy_damager"):
		area._destroy_node()                                # request bullet node to destroy itself
		$CollisionShape2D.set_deferred("disabled", true)    # prevent successive bullets hitting the explosion animation
		$BattleCruiser.frame   = 3                          # start explosion animation
		$BattleCruiser.playing = true                       # https://opengameart.org/content/explosion-4
		Global.node_sound_guy.get_node("explosion").play()
		Global.scoreboard.enemieskilled += 1
		Global.add_satoshi(100) #Global.scoreboard.satoshi += 100

	if area.is_in_group("player_shield"):
		$CollisionShape2D.set_deferred("disabled", true)    # prevent successive bullets hitting the explosion animation
		$BattleCruiser.frame   = 3                          # start explosion animation
		$BattleCruiser.playing = true                       # https://opengameart.org/content/explosion-4
		Global.node_sound_guy.get_node("explosion").play()
		Global.scoreboard.enemieskilled += 1
		Global.add_satoshi(100) #Global.scoreboard.satoshi += 100
		
#------------------------------------------------------------------------------

func _on_BattleCruiser_animation_finished():
	self.queue_free()                         # destoy enemy ship


#==============================================================================
