extends Position2D

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var amount 
var delay = 0.3
var color = Color.white

func _ready():
	if amount == null:
		print("Warning: FloatingText amount==null")
		amount = "Bazinga"
	label.modulate = color
	label.set_text( str(amount) )
	tween.interpolate_property(self, "scale", scale,        Vector2(2,2)     , 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", Vector2(2,2), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, delay)
	tween.start()
	#print("popuptext: " + str(position) + "    Globalpos: " + str(self.get_global_position() ) )

func _on_Tween_tween_all_completed():
	self.queue_free()
#==============================================================================
