extends HBoxContainer

signal s_changeWallShape

func _on_FullWall_pressed():
	emit_signal("s_changeWallShape", WorldConstants.WallShape.FULLWALL)

func _on_HalfWallBottom_pressed():
	emit_signal("s_changeWallShape", WorldConstants.WallShape.HALFWALLBOTTOM)

func _on_HalfWallTop_pressed():
	emit_signal("s_changeWallShape", WorldConstants.WallShape.HALFWALLTOP)

func _on_QuarterCircleWall_pressed():
	emit_signal("s_changeWallShape", WorldConstants.WallShape.QCIRCLEWALL)

func _on_ArcWall_pressed():
	emit_signal("s_changeWallShape", WorldConstants.WallShape.ARCHWALL)

func set_wallShape(shape):
	pass
