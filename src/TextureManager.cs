using System.Collections.Generic;
using Godot;
using YACY.Legacy;

namespace YACY;

public class TextureManager : ITextureManager
{
	public List<TextureInfo> TextureInfo { get; private set; }
	public Dictionary<string, GameTexture> Textures { get; private set; }
	private TextureArray TextureArray;

	private const Image.Format TextureFormat = Image.Format.Rgba8;
		
	public void Ready()
	{
		LoadTextures();
	}

	public void LoadTextures()
	{
		LoadTextureInfo();

		TextureArray = new TextureArray();
		TextureArray.Create(256, 256, (uint) TextureInfo.Count, TextureFormat, 7);

		Textures = new Dictionary<string, GameTexture>();

		var layer = 0;
		foreach (var textureInfo in TextureInfo)
		{
			// Load into TextureArray
			var streamTexture = GD.Load<StreamTexture>(textureInfo.ResLocation);
			var imgData = streamTexture.GetData();
			imgData.Decompress();
			
			if (imgData.GetFormat() != TextureFormat)
				imgData.Convert(TextureFormat);

			imgData.GenerateMipmaps();
			
			TextureArray.SetLayerData(imgData, layer);
			
			// Add into texture list
			var texture = new ImageTexture();
			texture.CreateFromImage(imgData);
			Textures.Add(textureInfo.Name, new GameTexture(texture, textureInfo));

			layer++;
		}
	}

	// TODO: Load from ini file or something
	private void LoadTextureInfo()
	{
		TextureInfo = new List<TextureInfo>();
		
		// Regular Textures
		TextureInfo.Add(new TextureInfo("Color", "res://res/txrs/color256.jpg", new Vector2(5, 5)));
		TextureInfo.Add(new TextureInfo("Grass", "res://res/txrs/grass256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Stucco", "res://res/txrs/stucco256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Brick", "res://res/txrs/brick256.jpg", new Vector2(2.5f, 2.667f)));
		TextureInfo.Add(new TextureInfo("Stone", "res://res/txrs/stone256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Wood", "res://res/txrs/wood256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Happy", "res://res/txrs/happy256.jpg", new Vector2(4, 4)));
		TextureInfo.Add(new TextureInfo("Egypt", "res://res/txrs/egypt256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Bark", "res://res/txrs/bark256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Sci-Fi", "res://res/txrs/scifi256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Tiles", "res://res/txrs/tile256.jpg", new Vector2(4, 4)));
		TextureInfo.Add(new TextureInfo("Rock", "res://res/txrs/rock256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Parquet", "res://res/txrs/parquet256.jpg", new Vector2(1, 1)));
		TextureInfo.Add(new TextureInfo("Bookshelf", "res://res/txrs/bookshelf256.png", new Vector2(1, 1.333f)));
		
		// Transparent Textures
		TextureInfo.Add(new TextureInfo("Bars", "res://res/txrs/bars256.png", new Vector2(3.5f, 1), true));
		TextureInfo.Add(new TextureInfo("Glass", "res://res/txrs/glass256.png", new Vector2(1, 1), true));
	}
}