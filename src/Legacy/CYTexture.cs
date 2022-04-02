using System;
using Godot;
using Object = Godot.Object;

namespace YACY.Legacy
{
    public class CYTexture : Object
    {
        public int Texture { get; }
        public Color Color { get; }

        public CYTexture(int texture)
        {
            Texture = texture;
            Color = Colors.White;
        }

        public CYTexture(Color color)
        {
            Texture = -1;
            Color = color;
        }

        public object ToVariant()
        {
            if (this.Texture == -1)
            {
                return Color;
            }
            else
            {
                return Texture;
            }
        }
    }
}