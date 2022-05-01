extends Control

enum tile_loc { TOP_LEFT, TOP, TOP_RIGHT, RIGHT, BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT }

var clipping_exists = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# assume default scene
	_set_font_path( Globals.resources[ "Scenes" ][ "default" ].button_font.font_path )
#	_set_font_size( Globals.resources[ "Scenes" ][ "default" ].button_font.font_size )
		
	var bd = add_border()
	if clipping_exists:
		var ts = $PanelContainer/TileMap.cell_size
		$PanelContainer.rect_size = Vector2( bd[0] * ts[0], bd[1] * ts[1] )

func _set_font_path( fp ):
	assert( fp )
	$PanelContainer/Button/Label.set( "custom_fonts/font", load( fp ) )
	
func _set_font_size( fs ):
	assert( fs )
	$PanelContainer/Button/Label.set( "custom_fonts/settings_size", fs )
	
func set_text( txt ):
	$PanelContainer/Button/Label.text = txt
	
func set_enable( en ):
	$PanelContainer/Button.disabled = !en

func add_border():
	# get the size of the button and draw appropriate tilemap
	var sz = $PanelContainer.rect_size
	var tm_size = $PanelContainer/TileMap.cell_size
	
	var tile_breakdown_raw = Vector2( sz[0] / tm_size[0], sz[1] / tm_size[1] )
	var tile_breakdown = Vector2( ceil( tile_breakdown_raw[0] ), ceil( tile_breakdown_raw[1] ) )
	if( tile_breakdown != tile_breakdown_raw ):
		clipping_exists = true

	# add corners and connecting pieces
	$PanelContainer/TileMap.set_cell( 0, 0, tile_loc.TOP_LEFT )
	$PanelContainer/TileMap.set_cell( tile_breakdown[0]-1, 0, tile_loc.TOP_RIGHT )
	$PanelContainer/TileMap.set_cell( tile_breakdown[0]-1, tile_breakdown[1]-1, tile_loc.BOTTOM_RIGHT )
	$PanelContainer/TileMap.set_cell( 0, tile_breakdown[1]-1, tile_loc.BOTTOM_LEFT )
	
	# fill in the spaces
	for x in range( 1, tile_breakdown[0]-1 ):
		$PanelContainer/TileMap.set_cell( x, 0, tile_loc.TOP )
		$PanelContainer/TileMap.set_cell( x, tile_breakdown[1]-1, tile_loc.BOTTOM )
		
	for y in range( 1, tile_breakdown[1]-1 ):
		$PanelContainer/TileMap.set_cell( 0, y, tile_loc.LEFT )
		$PanelContainer/TileMap.set_cell( tile_breakdown[0]-1, y, tile_loc.RIGHT )

	return tile_breakdown
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
#	$PanelContainer/TileMap.clear()
	pass # Replace with function body.
