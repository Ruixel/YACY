using Godot;
using MessagePack;
using MessagePack.Formatters;

namespace YACY.Util;

public class GodotVectorFormatter : IMessagePackFormatter<Vector2>
{
	public void Serialize(ref MessagePackWriter writer, Vector2 value, MessagePackSerializerOptions options)
	{
		writer.Write(value.x);
		writer.Write(value.y);
	}

	public Vector2 Deserialize(ref MessagePackReader reader, MessagePackSerializerOptions options)
	{
		var x = reader.ReadSingle();
		var y = reader.ReadSingle();

		return new Vector2(x, y);
	}
}