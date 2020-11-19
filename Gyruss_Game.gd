extends Node2D

enum {	SPLASHSCREEN, 
		INTROSCREEN,
		MAINSCREEN_PREP,
		MAINSCREEN,
		LEVEL_PREP, 
		LEVEL_01,
		LEVEL_02,
		LEVEL_03,
		LEVEL_04,
		LEVEL_05,
		GAMEOVER,
		QUITGAME,
		}
var fsm: int = 0

var do_once = true

#------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	# define this node (self) as the 'root' node, 
	# so other nodes instance in this scene using 'Global.instance_node()'
	Global.node_creation_parent = self
	randomize()
	
	_print_system()
	
	# load soundeffect and music node
	var sound_guy_tscn = load("res://audio/sound_guy.tscn")
	var sound_guy = sound_guy_tscn.instance()
	add_child(sound_guy)
	#Global.node_sound_guy.get_node("BackgroundMusic").play()


#------------------------------------------------------------------------------
func _exit_tree():
	Global.node_creation_parent = null

#------------------------------------------------------------------------------
func _process(_delta):

	match fsm:
		SPLASHSCREEN:
			if do_once:
				do_once = false
				var currentlevel_tscn = load("res://Levels/Level_00.tscn")
				Global.instance_node(currentlevel_tscn, Global.center, Global.node_creation_parent )
			if ( Global.node_level == null ):
				fsm = LEVEL_01
				do_once = true
			
		INTROSCREEN:
			pass
		MAINSCREEN_PREP:
			pass
		MAINSCREEN:
			pass
		LEVEL_PREP:
			pass
		LEVEL_01:
			if do_once:
				do_once = false
				var currentlevel_tscn = load("res://Levels/Level_01.tscn")
				var currentlevel      = currentlevel_tscn.instance()
				add_child(currentlevel)

		LEVEL_02:
			pass
		GAMEOVER:
			pass
		QUITGAME:
			pass
		_       :
			print("error fsm")
	#- - - - - - 
	
#	if ( Input.is_action_pressed("ui_cancel") ):          # 'esc' key
#		fsm = QUITGAME
#		get_tree().quit()

#------------------------------------------------------------------------------
func _print_system():
	var myscreen = Vector2(1024,1024)
	myscreen.x = ProjectSettings.get_setting("display/window/size/width")
	myscreen.y = ProjectSettings.get_setting("display/window/size/height")
	print("Project Setting Display size: "+str(myscreen))
	
#==============================================================================
