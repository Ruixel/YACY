using System;
using System.Collections.Generic;
using Godot;

namespace YACY.Legacy.Objects
{
    public class CYWall : ICYObject
    {
        public Vector2 StartPosition;
        public Vector2 Displacement;

        public CYTexture FrontTexture;
        public CYTexture BackTexture;

        public CYHeight Height;
        private int LegacyHeight; // CY uses a set number of heights
        public int Level;

        // Wall Lingo: [displacement_x, displacement_y, start_x, start_y, front_material, back_material, height, level]
        private readonly Func<string, string, Vector2> _extractVec2 = ExtractValue.ExtractVec2;
        public CYWall(IList<string> properties)
        {
            if (properties.Count == 8)
            {
                Displacement = _extractVec2(properties[0], properties[1]);
                StartPosition = ExtractValue.ExtractVec2(properties[2], properties[3]);
                FrontTexture = ExtractValue.ExtractTexColor(properties[5]);
                BackTexture = ExtractValue.ExtractTexColor(properties[4]);
                Height = new CYHeight(ExtractValue.ExtractInt(properties[6]));
                LegacyHeight = ExtractValue.ExtractInt(properties[6]);
                Level = ExtractValue.ExtractInt(properties[7]);
            }
        }
        
        public void CreateObject(Node worldApi)
        {
            worldApi.Call("create_wall", Displacement, StartPosition, FrontTexture.Texture, FrontTexture.Color, BackTexture.Texture, BackTexture.Color, LegacyHeight, Level);
        }

        public string SerializeObject()
        {
            throw new System.NotImplementedException();
        }
    }
}