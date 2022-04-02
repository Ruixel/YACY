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

        public static void CreateObjectsInWorld(LegacyLevelData level, Node worldApi)
        {
            // Get ObjectLoader node 
            var objectLoader = worldApi.GetNode<Node>("ObjectLoader");

            foreach (var objectsData in level.RawObjectData)
            {
                CreateObjects(objectLoader, objectsData.Key, objectsData.Value);
            }
        }

        private static void CreateObjects(Node objectLoader, string objType, ICollection<IList<string>> objects)
        {
            if (objType == "walls") wall_createObject(objectLoader, objects);
            else if (objType == "plat") plat_createObject(objectLoader, objects);
        }

        // Wall: [displacement_x, displacement_y, start_x, start_y, front_material, back_material, height, level]
        /*public static CYWall CreateWall(IList<string> properties)
        {
            var wall = new CYWall();
            if (properties.Count == 8)
            {
                wall.Displacement = ExtractValue.ExtractVec2(properties[0], properties[1]);
                wall.StartPosition = ExtractValue.ExtractVec2(properties[2], properties[3]);
                wall.FrontTexture = ExtractValue.ExtractTexColor(properties[5]);
                wall.BackTexture = ExtractValue.ExtractTexColor(properties[4]);
                wall.Height = new CYHeight(ExtractValue.ExtractInt(properties[6]));
                wall.LegacyHeight = ExtractValue.ExtractInt(properties[6]);
                wall.Level = ExtractValue.ExtractInt(properties[7]);
            } else {}
            return wall;
        }*/

        // Wall: [displacement_x, displacement_y, start_x, start_y, front_material, back_material, height, level]
        public static void wall_createObject(Node objectLoader, ICollection<IList<string>> objs)
        {
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

        // Platform: [position_x, position_y, size, material, height, level
        public static void plat_createObject(Node objectLoader, ICollection<IList<string>> objs)
        {
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
    }
}