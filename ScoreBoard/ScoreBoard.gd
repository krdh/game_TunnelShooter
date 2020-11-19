extends Control

export var global_position:Vector2    # dummy var for compatibility


func _ready():
	Global.node_scoreboard = self
	#print("Scoreboard Position " + str( self.position ) )
	
func _exit_tree():
	Global.node_scoreboard = null

func _process(delta):
	$Score.text   = "Satoshi: " + str(Global.scoreboard.satoshi)
	$Shield.text  = "Shield : " + str(Global.scoreboard.shield) + " %"
	$Killed.text  = "Killed : " + str(Global.scoreboard.enemieskilled)

#==============================================================================
