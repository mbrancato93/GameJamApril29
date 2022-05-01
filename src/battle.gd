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
	$Background/Customer_Info/Name.text = challenger

	player_health = Globals.mission.Player.health
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ctrls = control.get_input_vector_released()
	handle_state_machine( ctrls )
	pass
	
func update_health_bar():
	# start with the player
	var close_frame = 60 - player_health * ( 60.0 / 100.0 )
	$Background/Player_Info/StaminaBar.frame = close_frame
	
	close_frame = 60 - customer_health * ( 60.0 / 100.0 )
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
		otpt_txt = "%s %s" % [ challenger, Globals.resources[ "Moves" ][ sel_move ][ "flavor" ] ]
	else:
		otpt_txt = "%s uses %s!" % [ challenger, Globals.resources[ "Moves" ][ sel_move ][ "name" ] ]
	
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
		$Background/OptionsMenu.hide()
		# show the fight menu
		$Background/FightMenu.popup()
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
				curr_script_ind += 1
			else:
				current_script = null
				curr_state = state.MONOLOGUE_SUBSTATE_COMPLETE
				main_text_updater( "" )
				update_health_bar()
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
			pass
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
		var btn = btn_parent.get_child( 0 )
		if count < len( opts ):
			btn.disabled = false
			btn.text = opts[ count ]
			count += 1	
		else:
			btn.disabled = true

func _on_FightMenu_about_to_show():
	var opts = Globals.resources[ "Player" ].moves
	var count = 0
	for btn_parent in $Background/FightMenu/ColorRect/CenterContainer/GridContainer.get_children():
		var btn = btn_parent.get_child( 0 )
		if count < len( opts ):
			btn.disabled = false
			btn.text = Globals.resources[ "Moves" ][ opts[ count ] ].name
			count += 1	
		else:
			btn.disabled = true
