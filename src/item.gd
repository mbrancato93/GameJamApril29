extends Node2D

var type = null

func init( name ):
	if name in Globals.resources[ "Items" ]:
		type = name
		$Sprite.texture = load( Globals.resources[ "Items" ][ name ][ "image" ] )
			

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.item_contact( self.type ):
		queue_free()
	
	pass # Replace with function body.
