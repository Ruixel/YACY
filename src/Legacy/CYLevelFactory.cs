using System.Collections.Generic;
using System.Linq;
using Godot;
using YACY.Legacy.Objects;

namespace YACY.Legacy
{
	public static class CYLevelFactory
	{
		static int ExtractInt(string property) => ExtractValue.ExtractInt(property);
		static Vector2 ExtractVec2(string x, string y) => ExtractValue.ExtractVec2(x, y);
		static object ExtractTexColor(string property) => ExtractValue.ExtractTexColor(property);
		static string ExtractStr(string property) => property;

		public static void CreateObjectsInWorld(LegacyLevelData level, Node worldApi)
		{
			// Get ObjectLoader node 
			var objectLoader = worldApi.GetNode<Node>("ObjectLoader");

			foreach (var objectsData in level.RawObjectData)
			{
				CreateObjects(objectLoader, objectsData.Key, objectsData.Value);
			}
			
			objectLoader.CallDeferred("finalise");
		}

		private static void CreateObjects(Node objectLoader, string objType, ICollection<IList<string>> objects)
		{
			if (objType == "walls") wall_createObject(objectLoader, objects);
			else if (objType == "plat") plat_createObject(objectLoader, objects);
			else if (objType == "triplat") triplat_createObject(objectLoader, objects);
			else if (objType == "diaplat") diaplat_createObject(objectLoader, objects);
			else if (objType == "triwall") triwall_createObject(objectLoader, objects);
			else if (objType == "pillar") pillar_createObject(objectLoader, objects);
			else if (objType == "ramp") ramp_createObject(objectLoader, objects);

			else if (objType == "floor") ground_createObject(objectLoader, objects);
			else if (objType == "hole") hole_createObject(objectLoader, objects);

			// Entities
			else if (objType == "begin") start_createEntity(objectLoader, objects);
			else if (objType == "finish") finish_createEntity(objectLoader, objects);
			else if (objType == "board") message_createEntity(objectLoader, objects);
			else if (objType == "portal") portal_createEntity(objectLoader, objects);
			else if (objType == "teleport") teleport_createEntity(objectLoader, objects);
			else if (objType == "theme") theme_createEntity(objectLoader, objects);
			else if (objType == "weather") weather_createEntity(objectLoader, objects);
			else if (objType == "backmusic") music_createEntity(objectLoader, objects);
			else if (objType == "jetpack") jetpack_createEntity(objectLoader, objects);
			else if (objType == "fuel") fuel_createEntity(objectLoader, objects);
			else if (objType == "door") door_createEntity(objectLoader, objects);
			else if (objType == "key2") key_createEntity(objectLoader, objects);
			else if (objType == "ladder") ladder_createEntity(objectLoader, objects);
			else if (objType == "diamond") diamond_createEntity(objectLoader, objects);
			else if (objType == "monster") iceman_createEntity(objectLoader, objects);
			else if (objType == "chaser") chaser_createEntity(objectLoader, objects);
			else if (objType == "slingshot") slingshot_createEntity(objectLoader, objects);
			else if (objType == "crumbs") crumbs_createEntity(objectLoader, objects);
		}

		// Wall
		// [displacement_x, displacement_y, start_x, start_y, front_material, back_material, height, level]
		private static void wall_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 8)
					objectLoader.Call("create_wall", ExtractVec2(obj[0], obj[1]), ExtractVec2(obj[2], obj[3]),
						ExtractTexColor(obj[5]), ExtractTexColor(obj[4]), ExtractInt(obj[6]), ExtractInt(obj[7]));
				else if (objectSize == 7)
					objectLoader.Call("create_wall", ExtractVec2(obj[0], obj[1]), ExtractVec2(obj[2], obj[3]),
						ExtractTexColor(obj[5]), ExtractTexColor(obj[4]), 1, ExtractInt(obj[6]));
			}
		}

		// Platform
		// [position_x, position_y, size, material, height, level
		private static void plat_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 6)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractTexColor(obj[3]), ExtractInt(obj[4]), 0, ExtractInt(obj[5]));

				else if (objectSize == 5)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractTexColor(obj[3]), 1, 0, ExtractInt(obj[4]));

				else if (objectSize == 4)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), 5, 1, 0,
						ExtractInt(obj[3]));
			}
		}

		// Diamond Platform
		// [position_x, position_y, size, material, height, level]
		private static void diaplat_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 6)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractTexColor(obj[3]), ExtractInt(obj[4]), 1, ExtractInt(obj[5]));
				else if (objectSize == 5)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractTexColor(obj[3]), 1, 1, ExtractInt(obj[4]));
				else if (objectSize == 4)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), 5, 1, 1,
						ExtractInt(obj[3]));
			}
		}

		// Triangular Platform
		// [position_x, position_y, size, material, height, direction, level]
		private static void triplat_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 7)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractTexColor(obj[3]), ExtractInt(obj[5]), 1 + ExtractInt(obj[4]), ExtractInt(obj[6]));
				else if (objectSize == 6)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractTexColor(obj[3]), 1, 1 + ExtractInt(obj[4]), ExtractInt(obj[5]));
				else if (objectSize == 5)
					objectLoader.Call("create_plat", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), 5, 1,
						1 + ExtractInt(obj[3]), ExtractInt(obj[4]));
			}
		}

		// TriWalls 
		// [position_x, position_y, inverted, material, direction, level]
		private static void triwall_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_triwall", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
					ExtractTexColor(obj[3]), ExtractInt(obj[4]), ExtractInt(obj[5]));
			}
		}

		// Pillars
		// [position_x, position_y, isDiagonal, material, size, height, level]
		private static void pillar_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 7)
					objectLoader.Call("create_pillar", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractInt(obj[4]),
						ExtractTexColor(obj[3]), ExtractInt(obj[5]), ExtractInt(obj[6]));
				else if (objectSize == 4)
					objectLoader.Call("create_pillar", ExtractVec2(obj[0], obj[1]), 1, 1, ExtractTexColor(obj[2]), 1,
						ExtractInt(obj[3]));
			}
		}

		// Ramp
		// [position_x, position_y, direction, material, level]
		private static void ramp_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 5)
					objectLoader.Call("create_ramp", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractTexColor(obj[3]), ExtractInt(obj[4]));
				else if (objectSize == 4)
					objectLoader.Call("create_ramp", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), 5,
						ExtractInt(obj[3]));
			}
		}

		// Ground
		// [x1, y1, x2, y2, x3, y3, x4, y4, floor_material, isVisible, ceil_material]
		private static void ground_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			var level = 1;
			foreach (var obj in objs)
			{
				objectLoader.Call("create_floor", ExtractVec2(obj[0], obj[1]), ExtractVec2(obj[2], obj[3]),
					ExtractVec2(obj[4], obj[5]), ExtractVec2(obj[6], obj[7]), ExtractTexColor(obj[8]),
					ExtractInt(obj[9]), ExtractTexColor(obj[10]), level);

				level++;
			}
		}

		// Hole
		// [position_x, position_y, size, level]
		private static void hole_createObject(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_hole", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), ExtractInt(obj[3]));
			}
		}

		// Begin (Spawn location)
		// [position_x, position_y, direction, level]
		private static void start_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_spawn", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), ExtractInt(obj[3]));
			}
		}

		// Finish
		// [position_x, position_y, unknown, condition, level]
		private static void finish_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 5)
					objectLoader.Call("create_finish", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[3]),
						ExtractInt(obj[4]));
				else if (objectSize == 4)
					objectLoader.Call("create_finish", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractInt(obj[3]));
			}
		}

		// Message board
		// [position_x, position_y, message, direction, height, level]
		private static void message_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 6)
					objectLoader.Call("create_msgBoard", ExtractVec2(obj[0], obj[1]), ExtractStr(obj[2]),
						ExtractInt(obj[3]), ExtractInt(obj[4]), ExtractInt(obj[5]));
				else if (objectSize == 5)
					objectLoader.Call("create_msgBoard", ExtractVec2(obj[0], obj[1]), ExtractStr(obj[2]),
						ExtractInt(obj[3]), 1, ExtractInt(obj[4]));
			}
		}

		// Portal
		// [position_x, position_y, title, condition, gameNumber, level]
		private static void portal_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_portal", ExtractVec2(obj[0], obj[1]), ExtractStr(obj[2]), ExtractInt(obj[3]),
					ExtractStr(obj[4]), ExtractInt(obj[5]));
			}
		}

		// Teleport
		// [position_x, position_y, unused, number, level]
		private static void teleport_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_teleport", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[3]),
					ExtractInt(obj[4]));
			}
		}

		// Theme
		// [position_x, position_y, theme_id, level]
		private static void theme_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("set_theme", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), ExtractInt(obj[3]));
			}
		}

		// Weather
		// [position_x, position_y, weather_id, level]
		private static void weather_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("set_weather", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), ExtractInt(obj[3]));
			}
		}

		// Music
		// [position_x, position_y, music_id, level]
		private static void music_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 5)
					objectLoader.Call("set_music", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[3]), ExtractInt(obj[4]));
				if (objectSize == 4)
					objectLoader.Call("set_music", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), ExtractInt(obj[3]));
			}
		}

		// Jetpack
		// [position_x, position_y, needs_fuel, level]
		private static void jetpack_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_jetpack", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
					ExtractInt(obj[3]));
			}
		}

		// Fuel (for Jetpack)
		// [position_x, position_y, fuel_amount, level]
		// Fuel amount goes: 30, 60, 120, 240
		private static void fuel_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_fuel", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), ExtractInt(obj[3]));
			}
		}

		// Door
		// [position_x, position_y, direction, key, texture, level]
		private static void door_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 6)
					objectLoader.Call("create_door", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractInt(obj[3]),
						ExtractTexColor(obj[4]), ExtractInt(obj[5]));
				else if (objectSize == 5)
					objectLoader.Call("create_door", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractInt(obj[3]),
						1, ExtractInt(obj[4]));
			}
		}

		// Key
		// [position_x, position_y, unknown, key_number, level]
		private static void key_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_key", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[3]), ExtractInt(obj[4]));
			}
		}

		// Ladder
		// [position_x, position_y, direction, level]
		private static void ladder_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_ladder", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
					ExtractInt(obj[3]));
			}
		}

		// Diamond
		// [position_x, position_y, time_bonus, height, level]
		private static void diamond_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 5)
					objectLoader.Call("create_diamond", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractInt(obj[3]), ExtractInt(obj[4]));
				else if (objectSize == 4)
					objectLoader.Call("create_diamond", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), 1,
						ExtractInt(obj[3]));
			}
		}

		// Monster (Iceman)
		// [position_x, position_y, speed, hits, level]
		private static void iceman_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			if (objs.Count <= 0) return;
			var objectSize = objs.First().Count;

			foreach (var obj in objs)
			{
				if (objectSize == 5)
					objectLoader.Call("create_iceman", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
						ExtractInt(obj[3]),
						ExtractInt(obj[4]));
				else if (objectSize == 4)
					objectLoader.Call("create_iceman", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), 1,
						ExtractInt(obj[3]));
			}
		}

		// Chaser
		// [position_x, position_y, model, speed, level]
		private static void chaser_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_chaser", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]), ExtractInt(obj[3]),
					ExtractInt(obj[4]));
			}
		}

		// Slingshot
		// [position_x, position_y, unknown, level]
		private static void slingshot_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_slingshot", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[3]));
			}
		}

		// Crumbs
		// [position_x, position_y, crumb_amount, level]
		private static void crumbs_createEntity(Node objectLoader, ICollection<IList<string>> objs)
		{
			foreach (var obj in objs)
			{
				objectLoader.Call("create_crumbs", ExtractVec2(obj[0], obj[1]), ExtractInt(obj[2]),
					ExtractInt(obj[3]));
			}
		}
	}
}
