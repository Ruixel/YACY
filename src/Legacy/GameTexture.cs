using Godot;

namespace YACY.Legacy;

public record GameTexture()
{
	public readonly ImageTexture ImageTexture;
	public TextureInfo TextureInfo;

	public GameTexture(ImageTexture imageTexture, TextureInfo textureInfo) : this()
	{
		ImageTexture = imageTexture;
		TextureInfo = textureInfo;
	}
}