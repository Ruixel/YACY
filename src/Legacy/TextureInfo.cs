using Godot;

namespace YACY.Legacy;

public struct TextureInfo
{
	public string Name { get; }
	public string ResLocation { get; }
	public Vector2 Scale { get; }
	public bool Transparent { get; }

	public TextureInfo(string name, string resLocation, Vector2 scale, bool transparent = false)
	{
		Name = name;
		ResLocation = resLocation;
		Scale = scale;
		Transparent = transparent;
	}
}