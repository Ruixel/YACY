using System.Collections.Generic;
using System.Linq;
using Godot;
using YACY.Build;
using YACY.Entities.Components;
using YACY.Legacy.Objects;

namespace YACY.Legacy;

public class CYLevelCoreFactory
{
	static int ExtractInt(string property) => ExtractValue.ExtractInt(property);
	static Vector2 ExtractVec2(string x, string y) => ExtractValue.ExtractVec2(x, y);
	static object ExtractTexColor(string property) => ExtractValue.ExtractTexColor(property);
	static string ExtractStr(string property) => property;

	public static void CreateObjectsInWorld(LegacyLevelData level)
	{
		foreach (var objectsData in level.RawObjectData)
		{
			CreateObjects(objectsData.Key, objectsData.Value);
		}
	}

	private static void CreateObjects(string objType, ICollection<IList<string>> objects)
	{
		//if (objType == "walls") wall_createObject(objectLoader, objects);
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

	private static void CreatePlat(Vector2 pos, int size, object texColour, int height, object shape, int level)
	{
		pos /= 5.0f;

		LegacyPlatform newPlat = new LegacyPlatform();
		newPlat.Position = pos;
		newPlat.Level = level;
		
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

		Core.GetManager<LevelManager>().AddEntity<LegacyPlatform>(newPlat);
	}
}