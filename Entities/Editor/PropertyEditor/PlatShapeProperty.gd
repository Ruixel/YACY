extends VBoxContainer

signal s_changePlatShape

func _on_FullPlat_pressed():
	emit_signal("s_changePlatShape", WorldConstants.PlatShape.QUAD)

func _on_DiaPlat_pressed():
	emit_signal("s_changePlatShape", WorldConstants.PlatShape.DIAMOND)

func _on_TriPlatBR_pressed():
	emit_signal("s_changePlatShape", WorldConstants.PlatShape.TRI_BR)

func _on_TriPlatTR_pressed():
	emit_signal("s_changePlatShape", WorldConstants.PlatShape.TRI_TR)

func _on_TriPlatTL_pressed():
	emit_signal("s_changePlatShape", WorldConstants.PlatShape.TRI_TL)

func _on_TriPlatBL_pressed():
	emit_signal("s_changePlatShape", WorldConstants.PlatShape.TRI_BL)
