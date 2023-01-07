using System;
using System.Xml;
using Godot.Collections;
using YACY.Geometry;
using YACY.Legacy.Objects;

namespace YACY.Build;

public class ItemList
{
	public static readonly Dictionary<Type, (string, string)> Previews = new()
	{
		{typeof(Wall), ("res://Scenes/UI/Previews/ItemPanel/ThickWall.tscn", "res://Scenes/UI/Previews/Selected/ThickWall.tscn")},
		//{typeof(LegacyWall), ("res://Scenes/UI/Previews/ItemPanel/Wall.tscn", "res://Scenes/UI/Previews/Selected/Wall.tscn")}
	};
	
	//public record Preview(string itemPanelPreview, string selectionPreview);
	
	//public static readonly Dictionary<Type, Preview> Previews = new Dictionary<Type, Preview>
	//{
	//	{typeof(Wall), new Preview("hi", "yo")}
	//};

	//public record Preview(string itemPanelPreview, string selectionPreview);
}