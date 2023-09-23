using System.Collections.Generic;
using System.Diagnostics;
using Godot;
using YACY.Legacy;
using YACY.MeshGen;

namespace YACY;

public partial class TextureManager : ITextureManager
{
	public List<TextureInfo> TextureInfo { get; private set; }
	public Dictionary<string, GameTexture> Textures { get; private set; }
	private Texture2DArray _texture2DArray;

	private const Image.Format TextureFormat = Image.Format.Rgba8;
		
	public void Ready()
	{
		LoadTextures();
	}

	public void LoadTextures()
	{
		LoadTextureInfo();

		_texture2DArray = new Texture2DArray();
		//_texture2DArray.Create(256, 256, (uint) TextureInfo.Count, TextureFormat, 7);

		Textures = new Dictionary<string, GameTexture>();

		var layer = 0;
		foreach (var textureInfo in TextureInfo)
		{
			// Load into TextureArray
			var streamTexture = GD.Load<CompressedTexture2D>(textureInfo.ResLocation);
			var imgData = streamTexture.GetImage();
			
			//imgData.Decompress();
			
			if (imgData.GetFormat() != TextureFormat)
				imgData.Convert(TextureFormat);

			imgData.GenerateMipmaps();
			
			//_texture2DArray.SetLayerData(imgData, layer);
			_texture2DArray.UpdateLayer(imgData, layer);
			
			// Add into texture list
			var texture = new ImageTexture();
			texture.SetImage(imgData);
			Textures.Add(textureInfo.Name, new GameTexture(texture, textureInfo));

			layer++;
		}
		
		WallHelper.ArrayTextureMaterial.SetShaderParameter("texture_array", _texture2DArray);
	}

	// TODO: Load from ini file or something
	private void LoadTextureInfo()
	{
		TextureInfo = new List<TextureInfo>
		{
			// Regular Textures
			new TextureInfo(0, "Color", "res://res/txrs/color256.jpg", new Vector2(5, 5)),
			new TextureInfo(1, "Grass", "res://res/txrs/grass256.jpg", new Vector2(1, 1)),
			new TextureInfo(2, "Stucco", "res://res/txrs/stucco256.jpg", new Vector2(1, 1)),
			new TextureInfo(3, "Brick", "res://res/txrs/brick256.jpg", new Vector2(2.5f, 2.667f)),
			new TextureInfo(4, "Stone", "res://res/txrs/stone256.jpg", new Vector2(1, 1)),
			new TextureInfo(5, "Wood", "res://res/txrs/wood256.jpg", new Vector2(1, 1)),
			new TextureInfo(6, "Happy", "res://res/txrs/happy256.jpg", new Vector2(4, 4)),
			new TextureInfo(7, "Egypt", "res://res/txrs/egypt256.jpg", new Vector2(1, 1)),
			new TextureInfo(8, "Bark", "res://res/txrs/bark256.jpg", new Vector2(1, 1)),
			new TextureInfo(9, "Sci-fi", "res://res/txrs/scifi256.jpg", new Vector2(1, 1)),
			new TextureInfo(10, "Tiles", "res://res/txrs/tile256.jpg", new Vector2(4, 4)),
			new TextureInfo(11, "Rock", "res://res/txrs/rock256.jpg", new Vector2(1, 1)),
			new TextureInfo(12, "Parquet", "res://res/txrs/parquet256.jpg", new Vector2(1, 1)),
			new TextureInfo(13, "Bookshelf", "res://res/txrs/bookshelf256.png", new Vector2(1, 1.333f)),
			
			// Transparent Textures
			new TextureInfo(14, "Bars", "res://res/txrs/bars256.png", new Vector2(3.5f, 1), true),
			new TextureInfo(15, "Glass", "res://res/txrs/glass256.png", new Vector2(1, 1), true)
		};
	}

	public string GetLegacyWallTextureName(int cyTexId)
	{
		return cyTexId switch
		{
			1 => "Brick",
			2 => "Bars",
			3 => "Stone",
			4 => "Grass",
			5 => "Wood",
			6 => "Happy",
			7 => "Egypt",
			8 => "Glass",
			9 => "Stucco",
			10 => "Bark",
			11 => "Sci-fi",
			12 => "Tiles",
			13 => "Rock",
			14 => "Bookshelf",
			16 => "Parquet",
			_ => "Color"
		};
	}
	
	public string GetLegacyPlatformTextureName(int cyTexId)
	{
		return cyTexId switch
		{
			1 => "Grass",
			2 => "Stucco",
			3 => "Brick",
			4 => "Stone",
			5 => "Wood",
			6 => "Happy",
			7 => "Egypt",
			8 => "Glass",
			9 => "Bark",
			10 => "Sci-fi",
			11 => "Tiles",
			13 => "Rock",
			15 => "Parquet",
			_ => "Color"
		};
	}
}