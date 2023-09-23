using System;
using Godot.Collections;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;

namespace YACY.Build;

public static class BuildEntityList
{
	public enum Type
	{
		Unknown,
		Wall,
		LegacyWall,
		LegacyPlatform
	}

	// public static Dictionary<Type, System.Type> TypeMap = new Dictionary<Type, System.Type>
	// {
	// 	{Type.Unknown, typeof(BuildEntity)},
	// 	{Type.Wall, typeof(Wall)},
	// 	{Type.LegacyWall, typeof(LegacyWall)},
	// 	{Type.LegacyPlatform, typeof(LegacyPlatform)}
	// };
}