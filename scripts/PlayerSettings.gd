extends Node

const settings_file = "user://settings.cfg"

# Default settings
var music_volume: float = 75.0
var player_name: String = ""

#func _ready():
#	load_settings()
#
#func save_settings():
#	print("Saving settings...")
#	var f = File.new()
#	f.open(settings_file, File.WRITE)
#	f.store_var(music_volume)
#	f.store_var(player_name)
#	f.close()
#
#func load_settings():
#	print("Loading settings...")
#
#	var f = File.new()
#	if f.file_exists(settings_file):
#		f.open(settings_file, File.READ)
#		music_volume = f.get_var()
#		player_name = f.get_var()
#		print("Loaded: ", music_volume, ", ", player_name)
#		f.close()
#	else:
#		save_settings()
#
#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#		print("exiting")
#		save_settings()
