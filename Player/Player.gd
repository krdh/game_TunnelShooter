extends Area2D

#
# Movement arround axis (0,0),  so parent node needs to move us to center of screen
#
# Needs:
#		Global.gd	var nodeship  
#		Global.gd	var radius
#		res://Bullet.tscn		bullet scene
#
#------------------------------------------------------------------------------
#- - - - - - - - - - - - - - - - - - - - -  Debugging var's
var db:int = 0
var dbPrint = true
#- - - - - - - - - - - - - - - - - - - - -  Constants
const r2d:float = ( 180.0 / PI )
const DEFAULT_RADIUS     = 480               # fallback value
const DEFAULT_SPEED      = 0.05
const DEFAULT_RELOADTIME = 0.20

export var playerconfig = {
		TakeHittime      = 0.3   ,
		gunreloadtime    = DEFAULT_RELOADTIME  ,
		keyboard_enable  = false ,
		sidegun_enable   = false ,
		plasmagun_enable = false ,
		aim_laser_enable = false ,
		shields_enable   = false
		}

#- - - - - - - - - - - - - - - - - - - - -  Global accesible  var's
var speed  = DEFAULT_SPEED  #setget set_speed, get_speed
#var gunreloadtime = 0.08 setget set_gunreloadtime, get_gunreloadtime
#var TakeHittime = 0.3
var angle  = 0
var center = Vector2(0, 0)                # this node's local center
var localradius = DEFAULT_RADIUS
#- - - - - - - - - - - - - - - - - - - - - 

var loc:Vector2 = Vector2( 0, Global.radius)
var node_bullet  = preload("res://Bullet/Bullet.tscn")
var node_plasma  = preload("res://Bullet/Plasmabolt.tscn")
var node_sidegun = preload("res://Bullet/Sidegunbullet.tscn")
var res_floatingtext = preload("res://ScoreBoard/FloatingText.tscn")
var node_spawnplayer = preload("res://Player/SpawnPlayer.tscn")

var gun_loaded:bool = true
#- - - - - - - - - - - - - - - - - - - - - 
var tmr_GunLoad:Timer
var tmr_TakeHit:Timer
var selfdestruct = false

#------------------------------------------------------------------------------
func _ready():
	# test if the Global.gd variables/methods exist are valid
	if not get_node_or_null("/root/Global") != null : print("Global node missing")
	if not Global.has_method("instance_node")       : print("Global method instance_node() missing")
	if not "node_ship" in Global                    : print("Global.node_ship missing")
	
	if not "radius"    in Global                    : print("Global.radius missing");
	if ( Global.radius <= 0 ) or ( Global.radius > 4000 ):
		print("Global.radius out of range 0..4000 ");
		Global.radius = DEFAULT_RADIUS
	else:
		localradius = Global.radius
		
	if not "center"    in Global                    : print("Global.center missing");
	center = Global.center
	self.position = center
	
	Global.node_ship = self
	position += loc
	angle     = loc.angle()
	rotation  = angle + (-0.5*PI)
	
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

	# instance a timer and connect timeout signal to a function
	tmr_GunLoad = Timer.new()
	self.add_child(tmr_GunLoad,true)
	tmr_GunLoad.wait_time = playerconfig.gunreloadtime
	tmr_GunLoad.one_shot = true
	tmr_GunLoad.connect("timeout", self, "_on_Timer_GunLoad_timeout" )
	tmr_GunLoad.start()
	#- - - - - - - - - - - - - - - - - - - - - 
	# instance a timer and connect timeout signal to a function
	tmr_TakeHit = Timer.new()
	self.add_child(tmr_TakeHit,true)
	tmr_TakeHit.wait_time = playerconfig.TakeHittime
	tmr_TakeHit.one_shot = true
	tmr_TakeHit.connect("timeout", self, "_on_Timer_TakeHit_timeout" )
	
	$Line2D.visible      = playerconfig.aim_laser_enable
	$shields.visible     = playerconfig.shields_enable
	$shields.monitorable = playerconfig.shields_enable
	
	# receive score(satoshi) key value updates, 2000,5000,10k, etc...
	Global.connect("sig_satoshi", self, "on_sig_satoshi")
	
	Global.node_level.connect("sig_level", self, "_fly_in_sunset" )
#------------------------------------------------------------------------------
func _exit_tree():
	Global.node_ship = null

#------------------------------------------------------------------------------
func _fly_in_sunset(value):
	if ( value == "end" ):
		$CPUParticles2D.lifetime = 5
		$CPUParticles2D.amount *= 2
		$shields.visible     = false
		$shields.monitorable = false                      # disable shields
		$Line2D.visible      = false                      # switchoff laser
		$Tween.interpolate_property(self,"localradius",localradius , 5           , 5, Tween.TRANS_LINEAR,Tween.EASE_IN, 2)
		$Tween.interpolate_property(self,"scale"      ,Vector2(1,1), Vector2(0,0), 5, Tween.TRANS_LINEAR,Tween.EASE_IN, 2)
		$Tween.start()
		selfdestruct = true
	elif ( value == "start" ):
		# start animation
		$Tween.interpolate_property($ship,"modulate",Color(0,0,0,0),Color(1,1,1,1),2,Tween.TRANS_LINEAR,Tween.EASE_IN,0.5)
		$Tween.start()
		var spawnplayer = node_spawnplayer.instance()
		add_child(spawnplayer, true)

func _on_Tween_tween_completed(object, key):
	if (key == "scale") and selfdestruct :
		print("player is selfdestructing")
		tmr_GunLoad.disconnect("timeout", self, "_on_Timer_GunLoad_timeout" )
		tmr_TakeHit.disconnect("timeout", self, "_on_Timer_TakeHit_timeout" )
		Global.node_level.disconnect("sig_level", self, "_fly_in_sunset" )
		Global.disconnect("sig_satoshi", self, "on_sig_satoshi")
		self.queue_free()

#------------------------------------------------------------------------------
func _process(delta):
	#- - - - - - - - - - - - - - - - - - - - -  Readout Keyboard
	var dir = Vector2(0,0)
	if playerconfig.keyboard_enable:
		dir.x = int( Input.is_action_pressed("ui_right") ) - int( Input.is_action_pressed("ui_left") )
		dir.y = int( Input.is_action_pressed("ui_up") )    - int( Input.is_action_pressed("ui_down") )
		if dir : 
			dir.normalized();		# dir.  ->  '1'=Right/Up , '-1'=Left/Down , '0'=none/both

		if ( dir ):
			var vec:Vector2 = loc.normalized()
			if  (vec.x >= 0) and (vec.y >= 0):      # quadrant 1
				angle += dir.x * -speed             # left -> increase angle
				angle += dir.y * -speed
				if db:print("Quadrant 1")
			elif (vec.x < 0) and (vec.y > 0):       # quadrant 2 (left/down)
				angle += dir.x * -speed
				angle += dir.y * speed
				if db:print("Quadrant 2")
			elif (vec.x < 0) and (vec.y <= 0):      # quadrant 3
				angle += dir.x * speed
				angle += dir.y * speed
				if db:print("Quadrant 3")
			elif (vec.x > 0) and (vec.y < 0):       # quadrant 4 (right/upper)
				angle += dir.x * speed
				angle += dir.y * -speed
				if db:print("Quadrant 4")
			else:
				print("Quadrant ?")
	#- - - - - - - - - - - - - - - - - - - - -  Readout Joystick
	var joyvec   = Vector2(0,0)
	joyvec.x =  Input.get_joy_axis(0, 0)
	joyvec.y =  Input.get_joy_axis(0, 1) 
	if abs(joyvec.x) < 0.1 : joyvec.x = 0 ;
	if abs(joyvec.y) < 0.1 : joyvec.y = 0 ;

	if ( joyvec ) :
		var phi = joyvec.angle_to(loc)    # angle between joystick and ship
		if   phi <  -0.03 : angle += ( speed * joyvec.length() );
		elif phi >=  0.03 : angle -= ( speed * joyvec.length() );
	#- - - - - - - - - - - - - - - - - - - - -  
	
	#loc.x =  Global.radius * cos(angle)
	#loc.y =  Global.radius * sin(angle)
	loc.x =  localradius   * cos(angle)
	loc.y =  localradius   * sin(angle)
	
	position = ( center + loc )
	angle    = loc.angle()
	rotation = angle + (-0.5*PI)
	
	if Input.is_action_pressed("ui_accept") and ( Global.node_creation_parent != null ):
		if gun_loaded :
			for child in $gunposition.get_children() :
				Global.instance_node(node_bullet, child.global_position, Global.node_creation_parent )
				Global.node_sound_guy.get_node("shoot").play()
				gun_loaded = false
				tmr_GunLoad.start()

	if playerconfig.plasmagun_enable:
		if Input.is_action_just_pressed("bullet_plasma") and ( Global.node_creation_parent != null ):
			Global.instance_node(node_plasma, $plasmaposition/center.global_position ,Global.node_creation_parent)
			Global.node_sound_guy.get_node("shoot").play()

	if playerconfig.sidegun_enable :
		if Input.is_action_just_pressed("bullet_side") and ( Global.node_creation_parent != null ):
			Global.instance_node(node_sidegun,Global.center ,Global.node_creation_parent)
			Global.node_sound_guy.get_node("sidegun").play()

#------------------------------------------------------------------------------

func on_sig_satoshi(value):
	if value > 1000 :
		var popuptext:String = ""
		match value :
			2000:
				playerconfig.aim_laser_enable = true
				$Line2D.visible = playerconfig.aim_laser_enable
				popuptext = "Ship Upgrade - Aiming Laser"
			5000:
				playerconfig.plasmagun_enable = true
				popuptext = "Ship Upgrade - Plasmagun (R1)"
			10000:
				playerconfig.gunreloadtime = 0.12
				popuptext = "Ship Upgrade - New Coffee Machine"
			20000:
				playerconfig.gunreloadtime = 0.08
				popuptext = "Ship Upgrade - Faster Reload"	
			50000:
				playerconfig.sidegun_enable   = true
				popuptext = "Ship Upgrade - Side Plasmagun (L1)"
			100000:
				popuptext = "Ship Upgrade - Shields"
				
		if popuptext != "" :
			var balloon = res_floatingtext.instance()
			balloon.position = Vector2(500, 300 )
			balloon.amount = popuptext
			balloon.color = Color.green
			balloon.delay = 2
			Global.node_creation_parent.add_child(balloon) 

#------------------------------------------------------------------------------
func _on_Player_Ship_area_entered(area):
	if area.is_in_group("player_damager"):
		Global.node_sound_guy.get_node("hit").play()
		Global.scoreboard.shield -= 1
		$ship.frame = 12
		tmr_TakeHit.start()

#------------------------------------------------------------------------------
func _on_Timer_GunLoad_timeout():
	gun_loaded = true

#------------------------------------------------------------------------------
func _on_Timer_TakeHit_timeout():
	$ship.frame = 8

#==============================================================================

#		for child in gunposition.get_children():
#			var bullet : = node_bullet.instance()
#			bullet.global_position = child.global_position
#			get_tree().current_scene.add_child(bullet)

	#if db>1:print("angle:" + str(angle) + "  dir:" + str(dir.x ) + "  loc:" + str(loc) + "  position:" + str(position) )
#	if Input.is_joy_button_pressed(0,1):
#		print("joy button pressed")

#	if db and dbPrint :
#		print(	"  joy :"     + str( joyvec) +
#				"  JoyAngle:" + str( r2d * joyvec.angle() ) + 
#				"  Angle2:"   + str( joyvec.angle_to(loc) ) + 
#				"  position:" + str( position ))
#		dbPrint = false

