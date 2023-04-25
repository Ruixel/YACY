using MessagePack;
using MessagePack.Resolvers;

namespace YACY.Util;

public static class LevelSerializerResolver
{
	private static readonly IFormatterResolver Resolver = CompositeResolver.Create(
		GodotColorResolver.Instance,
		GodotVectorResolver.Instance,
		StandardResolver.Instance
	);

	public static readonly MessagePackSerializerOptions Options = MessagePackSerializerOptions.Standard.WithResolver(Resolver);
}