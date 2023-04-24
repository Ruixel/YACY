using Godot;
using MessagePack;
using MessagePack.Formatters;

namespace YACY.Util;

public class GodotColorFormatter : IMessagePackFormatter<Color>
{
	public void Serialize(ref MessagePackWriter writer, Color value, MessagePackSerializerOptions options)
	{
		writer.Write(value.r);
		writer.Write(value.g);
		writer.Write(value.b);
		writer.Write(value.a);
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