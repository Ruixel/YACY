using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using YACY.Build;
using YACY.Entities.Components;
using YACY.Legacy.Objects;

namespace YACY.Legacy;

public partial class CYLevelCoreFactory
{
	static int ExtractInt(string property) => ExtractValue.ExtractInt(property);
	static Vector2 ExtractVec2(string x, string y) => ExtractValue.ExtractVec2(x, y);
	static object ExtractTexColor(string property) => ExtractValue.ExtractTexColor(property);
	static string ExtractStr(string property) => property;

	private static readonly List<int> MaxHeightList = new() {4, 3, 2, 1, 2, 3, 4, 4, 4, 3};
	private static readonly List<int> MinHeightList = new() {0, 0, 0, 0, 1, 2, 3, 2, 1, 1};

	public static void CreateObjectsInWorld(LegacyLevelData level)
	{
		foreach (var objectsData in level.RawObjectData)
		{
			CreateObjects(objectsData.Key, objectsData.Value);
		}
	}

	private static void CreateObjects(string objType, ICollection<IList<string>> objects)
	{
		if (objType == "walls") wall_createObject(objects);
		if (objType == "plat") plat_createObject(objects);
	}

	// Platform
	// [position_x, position_y, size, material, height, level
	private static void plat_createObject(ICollection<IList<string>> objs)
	{
		if (objs.Count <= 0) return;
		var objectSize = objs.First().Count;

		foreach (var obj in objs)
		{
			if (objectSize == 6)
				CreatePlat(ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
					ExtractTexColor(obj[3]), ExtractInt(obj[4]), 0, ExtractInt(obj[5]));

			else if (objectSize == 5)
				CreatePlat(ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
					ExtractTexColor(obj[3]), 1, 0, ExtractInt(obj[4]));

			else if (objectSize == 4)
				CreatePlat(ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), 5, 1, 0,
					ExtractInt(obj[3]));
		}
	}

	// Wall
	// [displacement_x, displacement_y, start_x, start_y, front_material, back_material, height, level]
	private static void wall_createObject(ICollection<IList<string>> objs)
	{
		if (objs.Count <= 0) return;
		var objectSize = objs.First().Count;

		foreach (var obj in objs)
		{
			if (objectSize == 8)
				CreateWall(ExtractVec2(obj[0], obj[1]), ExtractVec2(obj[2], obj[3]),
					ExtractTexColor(obj[5]), ExtractTexColor(obj[4]), ExtractInt(obj[6]), ExtractInt(obj[7]));
			else if (objectSize == 7)
				CreateWall(ExtractVec2(obj[0], obj[1]), ExtractVec2(obj[2], obj[3]),
					ExtractTexColor(obj[5]), ExtractTexColor(obj[4]), 1, ExtractInt(obj[6]));
		}
	}

	private static void CreatePlat(Vector2 pos, int size, object texColour, int height, object shape, int level)
	{
		pos /= 5.0f;

		LegacyPlatform newPlat = new LegacyPlatform();
		newPlat.Position = pos;
		newPlat.Level = level;

		var heightComponent = newPlat.GetComponent<HeightComponent>();
		heightComponent.BottomHeight = height switch
		{
			1 => 0.00f, 2 => 0.25f, 3 => 0.50f, 4 => 0.75f, _ => 0.00f
		};

		var sizeComponent = newPlat.GetComponent<SizeComponent>();
		sizeComponent.Size = size;

		var textureComponent = newPlat.GetComponent<TextureComponent>();

		if (texColour is int textureId)
		{
			textureComponent.ChangeTexture(Core.GetManager<TextureManager>().GetLegacyPlatformTextureName(textureId));
		}
		else if (texColour is Color colour)
		{
			textureComponent.ChangeTexture("Color");
			textureComponent.ChangeColor(colour);
		}

		Core.GetManager<LevelManager>().AddEntity(newPlat);
	}

	private static void CreateWall(Vector2 displacement, Vector2 start, object texColour, object backTexColour,
		int height, int level)
	{
		start /= 5.0f;
		displacement /= 5.0f;

		LegacyWall newWall = new LegacyWall();
		newWall.Position = start;
		newWall.Level = level;

		// Displacement
		var displacementComponent = newWall.GetComponent<DisplacementComponent>();
		displacementComponent.ChangeDisplacement(start + displacement);

		// Height
		var heightComponent = newWall.GetComponent<HeightComponent>();
		heightComponent.BottomHeight = MinHeightList[height - 1] / 4.0f;
		heightComponent.TopHeight = MaxHeightList[height - 1] / 4.0f;

		// Wall Materials
		var textureComponent = newWall.GetComponent<TextureComponent>();

		if (texColour is int textureId)
		{
			textureComponent.ChangeTexture(Core.GetManager<TextureManager>().GetLegacyWallTextureName(textureId));
		}
		else if (texColour is Color colour)
		{
			textureComponent.ChangeTexture("Color");
			textureComponent.ChangeColor(colour);
		}

		//if (backTexColour is int)
		//{
		//    newWall.BackTexture = WorldTextures.GetWallTexture((int)backTexColour);
		//}
		//else
		//{
		//    newWall.BackTexture = WorldTextures.TextureID.COLOR;
		//    newWall.BackColour = (Color)backTexColour;
		//}

		Core.GetManager<LevelManager>().AddEntity(newWall);
	}
}