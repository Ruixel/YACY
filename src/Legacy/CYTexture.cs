using System;
using Godot;

namespace YACY.Legacy
{
    public struct CYTexture
    {
        public int _texture { get; }
        public Color _color { get; }

        public CYTexture(int texture)
        {
            _texture = texture;
            _color = Colors.White;
        }

        public CYTexture(Color color)
        {
            _texture = 0;
            _color = color;
        }
    }
}