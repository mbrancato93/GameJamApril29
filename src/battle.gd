extends Node2D

var debug = load( "res://src/debug.gd" ).new()
var control = load( "res://src/controls.gd" ).new()

var menu_selection = 0

var id = "battle"
var challenger = "Chad" #TODO: fix this

var current_script = null
var curr_script_ind = 0
var curr_script_type = "opening"

var player_turn = true

var player_health = 0 
var customer_health = 100

enum state { MONOLOGUE_SUBSTATE_INIT, MONOLOGUE_SUBSTATE_SCROLLING, \
				MONOLOGUE_SUBSTATE_AWAITING, \
				MONOLOGUE_SUBSTATE_COMPLETE, OPTION_MENU, FIGHT_MENU, ITEM_MENU }
var curr_state = state.MONOLOGUE_SUBSTATE_INIT

# Called when the node enters the scene tree for the first time.
func _ready():
	debug.setVerb( Globals.debug_levels[ "main_menu" ].verbosity )
	debug.setPeriod( Globals.debug_levels[ "main_menu" ].period )
	
	challenger = Globals.mission.CurrChallenger
	
	$Background/Customer.texture = load( Globals.resources[ challenger ][ "battle" ] )
	
	# update challenger's name
	# get random name from list of available names
	var avail_names = Globals.resources[ challenger ].names
	var rnd = rand_range( 0, len( avail_names )-1 )
	$Background/Customer_Info/Name.text = avail_names[ rnd ]

	player_health = Globals.mission.Player.health
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ( player_health <= 0 or customer_health <= 0 ) and curr_script_type != "closing":
		# play the closing remarks
		curr_script_type = "closing"
		curr_state = state.MONOLOGUE_SUBSTATE_INIT
		curr_script_ind = 0
		pass
	
	update_health_bar()
	var ctrls = control.get_input_vector_released()
	handle_state_machine( ctrls )
	pass
	
func update_health_bar():
	# start with the player
	var close_frame = 60 - player_health * ( 60.0 / 100.0 )
	if close_frame > 60:
		close_frame = 60
	$Background/Player_Info/StaminaBar.frame = close_frame
	
	close_frame = 60 - customer_health * ( 60.0 / 100.0 )
	if close_frame > 60:
		close_frame = 60
	$Background/Customer_Info/StaminaBar.frame = close_frame
	pass
	
func handle_state_machine( ctrls ):
	if curr_state < state.MONOLOGUE_SUBSTATE_COMPLETE:
		if monologue_substate_machine( ctrls, curr_script_type ):
			if player_turn:
				curr_state = state_transition( curr_state, state.OPTION_MENU )
			else:
				enemy_turn()
	
func enemy_turn():
	# identify a move for the enemy to use by random selection
	var move_list = Globals.resources[ challenger ][ "moves" ]
	var rng = rand_range( 0, len( move_list ) )
	var sel_move = move_list[ rng ]
	
	var otpt_txt = ""
	if "flavor" in Globals.resources[ "Moves" ][ sel_move ]:
		otpt_txt = "%s %s" % [ $Background/Customer_Info/Name.text, Globals.resources[ "Moves" ][ sel_move ][ "flavor" ] ]
	else:
		otpt_txt = "%s uses %s!" % [ $Background/Customer_Info/Name.text, Globals.resources[ "Moves" ][ sel_move ][ "name" ] ]
	
	init_new_main_text_scroll( otpt_txt )
	player_health -= Globals.resources[ "Moves" ][ sel_move ][ "damage" ]
	curr_state = state.MONOLOGUE_SUBSTATE_SCROLLING
	player_turn = true
	
func state_transition( prev_state, new_state ):
	if( prev_state == state.MONOLOGUE_SUBSTATE_COMPLETE and new_state == state.OPTION_MENU ):
		# open up the battle popup screen
		$Background/OptionsMenu.popup()
		return new_state
	elif( prev_state == state.OPTION_MENU and new_state == state.FIGHT_MENU ):
		# hide the options menu
#		$Background/OptionsMenu.hide()
		# show the fight menu
		$Background/FightMenu.popup()
		return new_state
	elif( prev_state == state.OPTION_MENU and new_state == state.ITEM_MENU ):
#		$Background/OptionsMenu.hide()
		$Background/ItemMenu.popup()
		return new_state
	elif( prev_state == state.FIGHT_MENU and new_state == state.OPTION_MENU ):
#		$Background/FightMenu.hide()
#		$Background/OptionsMenu.popup()
		return new_state
	elif( prev_state == state.ITEM_MENU and new_state == state.OPTION_MENU ):
#		$Background/ItemMenu.hide()
#		$Background/OptionsMenu.popup()
		return new_state
	else:
		return prev_state
	
func monologue_substate_machine( ctrls, type ):
	if curr_state == state.MONOLOGUE_SUBSTATE_INIT:
		# check if there is an available script
		if type in Globals.resources[ challenger ][ "scripts" ]:
			var rnd = floor( rand_range( 0, len( Globals.resources[ challenger ][ "scripts" ][ "opening" ] )-1 ) )
			# load the selected variable into the script variable
			var tmp = Globals.resources[ challenger ][ "scripts" ][ type ]
			current_script = tmp[ rnd as String ]
			
			# start the script and change state
			init_new_main_text_scroll( current_script[curr_script_ind as String] )
			curr_script_ind += 1
			curr_state = state.MONOLOGUE_SUBSTATE_SCROLLING
			
	elif curr_state == state.MONOLOGUE_SUBSTATE_SCROLLING:
		# just waiting for scolling object interrupt
		if ctrls[4]:
			$TextScroll.interrupter()
	elif curr_state == state.MONOLOGUE_SUBSTATE_AWAITING:
		# check the controls to see if we should move on
		if ctrls[4]:
			var blink_timer = get_node( "Blinky" )
			if blink_timer:
				blink_timer.stop()
				self.remove_child( blink_timer )
				$Background/InfoBar/Blinker.visible = false
				
			if current_script and ( curr_script_ind < len( current_script ) ):
				init_new_main_text_scroll( current_script[curr_script_ind as String] )
				curr_state = state.MONOLOGUE_SUBSTATE_SCROLLING
				curr_script_ind += 1
			else:
				current_script = null
				curr_state = state.MONOLOGUE_SUBSTATE_COMPLETE
				main_text_updater( "" )
				if( not Globals.mission.isBattle ):
					# time to leave!
					next_scene()
				if( curr_script_type == "closing" ):
					next_scene()
				return true
	return false
	
func init_new_main_text_scroll( text ):
	var txt = load( "res://src/scroll_text.gd" ).new()
	txt.connect( "text_update", self, "main_text_updater" )
	txt.connect( "text_update_finished", self, "main_text_updater_finished" )
	txt.name = "TextScroll"
	self.add_child( txt )
	
	$TextScroll.scroll_text( text, Globals.resources[ "Battle" ].text_scroll_timeout )
			

func next_scene():
	var tmp = Globals.resources[ "Scenes" ][ id ].next
	get_tree().change_scene( Globals.resources[ "Scenes" ][ tmp ].scene )
	
func main_text_updater( curr_text ):
	$Background/InfoBar/MainText.text = curr_text
	pass
	
func toggle_blinky():
	$Background/InfoBar/Blinker.visible = !$Background/InfoBar/Blinker.visible
	pass
	
func main_text_updater_finished( final_text ):
	main_text_updater( final_text )
	self.remove_child( $TextScroll )
	
	# TODO: check if there is another bit of text to preview
	# start the blinking selector button
	var blinky = Timer.new()
	blinky.connect( "timeout", self, "toggle_blinky" )
	blinky.name = "Blinky"
	blinky.wait_time = Globals.resources[ "Battle" ].selector_timeout
	self.add_child( blinky )
	$Blinky.start()
	curr_state = state.MONOLOGUE_SUBSTATE_AWAITING
	pass

func _on_Button_pressed( source, ind ):
	# attempt to get the name of the button
	if source == "options":
		var opts = Globals.resources[ "Battle" ].options
		if opts[ ind ] == "Run": 
			next_scene()
		elif( opts[ ind ] == "Skills" ):
			curr_state = state_transition( curr_state, state.FIGHT_MENU )
		elif( opts[ ind ] == "Item" ):
			curr_state = state_transition( curr_state, state.ITEM_MENU )
		elif( opts[ ind ] == "Other" ):
			pass
	elif source == "fight":
		var action_list = Globals.resources[ "Player" ].moves
		var selected_action = action_list[ ind ]
		$Background/FightMenu.hide()
		init_new_main_text_scroll( "Player used %s!" % Globals.resources[ "Moves" ][ selected_action ].name )
		curr_state = state.MONOLOGUE_SUBSTATE_SCROLLING
		player_turn = false
		customer_health -= Globals.resources[ "Moves" ][ selected_action ].damage

func _on_OptionMenu_about_to_show():
	var opts = Globals.resources[ "Battle" ].options
	var count = 0
	for btn_parent in $Background/OptionsMenu/ColorRect/CenterContainer/GridContainer.get_children():
#		var btn = btn_parent.get_child( 0 )
		if count < len( opts ):
			btn_parent.set_enable( true )
			btn_parent.set_text( opts[ count ] )
			count += 1	
		else:
#			btn.disabled = true
			btn_parent.set_enable( false )
			pass
		
		# ensure correct font
		btn_parent.set( "custom_fonts/normal_font", \
				load( Globals.resources[ "Scenes" ][ "battle" ][ "button_font" ].font_path ) )

func _on_FightMenu_about_to_show():
	var opts = Globals.resources[ "Player" ].moves
	var count = 0
	for btn_parent in $Background/FightMenu/ColorRect/CenterContainer/GridContainer.get_children():
#		var btn = btn_parent.get_child( 0 )
		if count < len( opts ):
#			btn.disabled = false
			btn_parent.set_text( Globals.resources[ "Moves" ][ opts[ count ] ].name )
			count += 1	
		else:
#			btn.disabled = true
			pass
		
		# ensure correct font
		btn_parent.set( "custom_fonts/normal_font", \
				load( Globals.resources[ "Scenes" ][ "battle" ][ "button_font" ].font_path ) )

func update_move_descbox( ind ):
	var action_dict = Globals.resources[ "Player" ].moves
	var txt = ""
	txt += "NAME:\t%s\n" % Globals.resources[ "Moves" ][ action_dict[ ind ] ].name
	txt += "DAMAGE:\t%3.1f\n" % Globals.resources[ "Moves" ][ action_dict[ ind ] ].damage
	txt += "TYPE:\t%s\n" % Globals.resources[ "Moves" ][ action_dict[ ind ] ].type
	txt += "CHANCE:\t%01.2f\n\n" % Globals.resources[ "Moves" ][ action_dict[ ind ] ].hit_chance
	txt += Globals.resources[ "Moves" ][ action_dict[ ind ] ].description
	
	$Background/FightMenu/ColorRect/MoveDescLabel.text = txt
	
	# ensure the font is correct
	$Background/FightMenu/ColorRect/MoveDescLabel.set( "custom_fonts/normal_font", \
				load( Globals.resources[ "Scenes" ][ "battle" ][ "main_font" ].font_path ) )
	pass

func _on_Button_focus_entered( ind ):
	update_move_descbox( ind )
	pass # Replace with function body.


func _on_Button_mouse_entered( ind ):
	update_move_descbox( ind )
	pass # Replace with function body.

func _on_ItemMenu_about_to_show():
	draw_item_menu()
		
func _on_FightMenu_popup_hide():
	curr_state = state_transition( curr_state, state.OPTION_MENU )
	pass # Replace with function body.

func item_selected( ind ):
	print_debug( "item_selected %d" % ind )
	
	# remove item from inventory, call handler and redraw item menu
	Globals.mission.Inventory.remove( ind )
	
	clear_item_menu()
	draw_item_menu()
	
	# get out of the item menu
	
	
func handle_item( item_type ):
	pass

func _on_ItemMenu_popup_hide():
	curr_state = state_transition( curr_state, state.OPTION_MENU )
	clear_item_menu()


func clear_item_menu():
	for c in $Background/ItemMenu/CenterContainer/GridContainer.get_children():
		c.queue_free()
		
func draw_item_menu():
	# grab the items in the inventory and display in the rich text window
	for i in range( len( Globals.mission.Inventory ) ):
		var inventory_btn = load( Globals.resources[ "Inventory" ].button_scn ).instance()
		
#		inventory_btn._set_label( Globals.mission.Inventory[i] )
		# load the corresponding image
		inventory_btn._set_image( Globals.mission.Inventory[i] )
		
		# further scale item
		var itm_desc = Globals.resources[ "Items" ][ Globals.mission.Inventory[i] ]
		inventory_btn._scale_image( itm_desc.x_scale * Globals.resources[ "Battle" ].additional_inventory_scaling[0], \
								  itm_desc.y_scale * Globals.resources[ "Battle" ].additional_inventory_scaling[1] )

		inventory_btn.set_enable( true )
		inventory_btn.get_node( "Button" ).connect( "pressed", self, "item_selected", [ i ] )
		$Background/ItemMenu/CenterContainer/GridContainer.add_child( inventory_btn )
		$Background/ItemMenu/CenterContainer/GridContainer.get_child(i).set_enable( true )
