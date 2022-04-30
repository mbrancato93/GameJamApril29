extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _set_button_availability( enabled ):
	$Button.disabled = !enabled

func _set_image( item_name ):
	$Button/Sprite.texture = load( Globals.resources[ "Items" ][ item_name ][ "image" ] )

func _set_label( txt ):
	$Button/Caption.text = txt
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	print( "Button pressed" )
	pass # Replace with function body.
