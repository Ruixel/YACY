using System;
using System.Text;
using Godot;

namespace YACY.Legacy
{
    public static class ExtractValue
    {
        public static Vector2 ExtractVec2(string x, string y)
        {
            return new Vector2(x.ToFloat(), y.ToFloat());
        }

        public static Godot.Variant ExtractTexColor(string material)
        {
            if (material.IsValidInt())
            {
                return new CYTexture(material.ToInt()).ToVariant();
            }

            var cleanedString = new StringBuilder();
            foreach (var ch in material.ToCharArray())
            {
                if (Char.IsDigit(ch) || ch == ',')
                    cleanedString.Append(ch);
            }

            var split = cleanedString.ToString().Split(",");
            if (split.Length != 3)
            {
                GD.PushError($"Could not convert {material} into a Godot Colour");
                return new CYTexture(new Color(0, 0, 0)).ToVariant();
            }

            return new CYTexture(new Color(split[0].ToFloat()/255.0f, split[1].ToFloat()/255.0f, split[2].ToFloat()/255.0f)).ToVariant();
        }

        public static int ExtractInt(string property)
        {
            return property.ToInt();
        }
    }
}