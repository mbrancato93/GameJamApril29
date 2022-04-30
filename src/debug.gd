extends Node
class_name debug

enum level { NONE, LOW, MED, HIGH }

var verbosity = level.NONE
var period := 0
var last_call := 0
var call_count := 0

func setVerb( param: int ):
	assert( param >= level.NONE && param <= level.HIGH )
	verbosity = param
	
func setPeriod( param ):
	assert( param >= 0 && param <= 1e6 ) # arbitrary high limit but I think this is fine
	period = param
	
func DEBUG( str_in: String ):
	var curr_call = OS.get_ticks_msec()
	
	if( ( curr_call - last_call ) > period ):
		if( verbosity == level.LOW ):
			print( "[%f]{%d}%s" % [ curr_call, call_count, str_in ] )
		if( verbosity == level.MED ):
			print_debug( "[%f]{%d}%s" % [ curr_call, call_count, str_in ] )
		if( verbosity == level.HIGH ):
			print_debug( "[%f]{%d}%s" % [ curr_call, call_count, str_in ] )
			print_stack()
		last_call = curr_call
		call_count = 0
	else:
		call_count += 1


