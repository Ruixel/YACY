using System;
using Godot.Collections;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;

namespace YACY.Build;

public static class ItemList
{
	public enum BuildEntityType
	{
		Unknown,
		Wall,
		LegacyWall,
		LegacyPlatform
	}

	public static Dictionary<BuildEntityType, Type> BuildEntityTypeMap = new Dictionary<BuildEntityType, Type>
	{
		{BuildEntityType.Unknown, typeof(BuildEntity)},
		{BuildEntityType.Wall, typeof(Wall)},
		{BuildEntityType.LegacyWall, typeof(LegacyWall)},
		{BuildEntityType.LegacyPlatform, typeof(LegacyPlatform)}
	};
}