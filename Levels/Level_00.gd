extends Node2D


const DEFAULT_SCALE = Vector2(0.2, 0.2)
const DEFAULT_FADEOUT = 1.0                        # seconds

const LEVELNR         = 0
const LEVEL           = ("level_00" + str(LEVELNR) )

var tmr_splashscreen:Timer

signal sig_level()

#- - - - - - - - - - - - - - - - - - - - - 
func _ready():
	
	Global.node_level = self
	emit_signal("sig_level","start")
	
	$Sprite.scale     = DEFAULT_SCALE
	
	# instance timer,connect timeout signal to function	
	tmr_splashscreen = Timer.new()
	self.add_child(tmr_splashscreen,true)
	tmr_splashscreen.wait_time = 1
	tmr_splashscreen.one_shot = true
	tmr_splashscreen.connect("timeout", self, "_on_Timer_splashscreen_timeout" )
	tmr_splashscreen.start() 

#- - - - - - - - - - - - - - - - - - - - - 
func _exit_tree():
	Global.node_level = null

#- - - - - - - - - - - - - - - - - - - - -  
func _on_Timer_splashscreen_timeout():
	$Tween.interpolate_property($Sprite,"scale", DEFAULT_SCALE , Vector2(0,0) ,DEFAULT_FADEOUT ,Tween.TRANS_LINEAR,Tween.EASE_IN )
	$Tween.start()
	
#- - - - - - - - - - - - - - - - - - - - -  
func _on_Tween_tween_all_completed():
	emit_signal("sig_level","end")
	self.queue_free()
	
#==============================================================================
