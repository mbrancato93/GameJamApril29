extends Node

signal text_update
signal text_update_finished

var current_text = ""
var desired_text = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	var scroll_speed_timer = Timer.new()
	scroll_speed_timer.connect( "timeout", self, "curr_text" )
	scroll_speed_timer.name = "Timer"
	self.add_child( scroll_speed_timer )
	pass # Replace with function body.

func scroll_text( txt, interval ):
	desired_text = txt
	
	$Timer.wait_time = interval
	$Timer.start()
	pass
	
func interrupter():
	$Timer.stop()
	emit_signal( "text_update", desired_text )
	emit_signal( "text_update_finished", desired_text )
	return desired_text
	
func curr_text():
	if current_text.length() == desired_text.length():
		interrupter()
		return
		
	current_text += desired_text[ len( current_text) ]
	emit_signal( "text_update", current_text )
