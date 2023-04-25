using Godot;
using MessagePack;
using MessagePack.Formatters;

namespace YACY.Util;

public class GodotVectorResolver : IFormatterResolver
{
    public static readonly IFormatterResolver Instance = new GodotVectorResolver();

    private GodotVectorResolver() { }

    public IMessagePackFormatter<T> GetFormatter<T>()
    {
        return typeof(T) == typeof(Vector2) ? (IMessagePackFormatter<T>)new GodotVectorFormatter() : null;
    }
}
