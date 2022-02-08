using System;
using Godot;

namespace YACY.Legacy
{
    public struct CYTexture
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
    }
}