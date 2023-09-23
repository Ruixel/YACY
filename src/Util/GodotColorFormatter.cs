using Godot;
using MessagePack;
using MessagePack.Formatters;

namespace YACY.Util;

public partial class GodotColorFormatter : IMessagePackFormatter<Color>
{
	public void Serialize(ref MessagePackWriter writer, Color value, MessagePackSerializerOptions options)
	{
		writer.Write(value.R);
		writer.Write(value.G);
		writer.Write(value.B);
		writer.Write(value.A);
	}

	public Color Deserialize(ref MessagePackReader reader, MessagePackSerializerOptions options)
	{
		var r = reader.ReadSingle();
		var g = reader.ReadSingle();
		var b = reader.ReadSingle();
		var a = reader.ReadSingle();

		return new Color(r, g, b, a);
	}
}