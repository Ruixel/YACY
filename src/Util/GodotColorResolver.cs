using Godot;
using MessagePack;
using MessagePack.Formatters;

namespace YACY.Util;

public partial class GodotColorResolver : IFormatterResolver
{
    public static readonly IFormatterResolver Instance = new GodotColorResolver();

    private GodotColorResolver() { }

    public IMessagePackFormatter<T> GetFormatter<T>()
    {
        return typeof(T) == typeof(Color) ? (IMessagePackFormatter<T>)new GodotColorFormatter() : null;
    }
}
