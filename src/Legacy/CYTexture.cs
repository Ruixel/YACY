using Godot;

namespace YACY.Legacy
{
    public partial class CYTexture
    {
        public int Texture2D { get; }
        public Color Color { get; }

        public CYTexture(int texture)
        {
            Texture2D = texture;
            Color = Colors.White;
        }

        public CYTexture(Color color)
        {
            Texture2D = -1;
            Color = color;
        }

        public Godot.Variant ToVariant()
        {
            if (this.Texture2D == -1)
            {
                return Color;
            }
            else
            {
                return Texture2D;
            }
        }
    }
}