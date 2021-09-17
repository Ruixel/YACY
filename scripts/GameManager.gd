extends Node

var level_info: Dictionary

signal reset
signal pause

func load_level_info(level_info):
	self.level_info = level_info

func reset():
	emit_signal("reset")
