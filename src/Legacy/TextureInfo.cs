using Godot;

namespace YACY.Legacy;

public struct TextureInfo
{
	public int Id { get; }
	public string Name { get; }
	public string ResLocation { get; }
	public Vector2 Scale { get; }
	public bool Transparent { get; }

	public TextureInfo(int id, string name, string resLocation, Vector2 scale, bool transparent = false)
	{
		Id = id;
		Name = name;
		ResLocation = resLocation;
		Scale = scale;
		Transparent = transparent;
	}
}