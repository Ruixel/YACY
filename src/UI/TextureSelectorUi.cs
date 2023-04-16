using System;
using System.Linq;
using Godot;
using YACY.Build;
using YACY.Entities.Components;
using ItemList = Godot.ItemList;

namespace YACY.UI;

public class TextureSelectorUi : ItemList
{
	public TextureSelectorUi()
	{
		FixedColumnWidth = 182;
		FixedIconSize = new Vector2(32, 32);
		RectMinSize = new Vector2(200, 120);
		Connect("item_selected", this, nameof(OnItemSelected));

		foreach (var texture in Core.GetManager<TextureManager>().Textures.Values)
		{
			AddItem(texture.TextureInfo.Name, texture.ImageTexture);
		}
	}

	private void OnItemSelected(int index)
	{
		GD.Print($"Item selected: {index}");

		var entity = Core.GetManager<SelectionManager>().GetItemsSelected()[0];
		if (entity != null)
		{
			var textureManager = Core.GetManager<TextureManager>();
			//var textureName= textureManager.GetLegacyWallTextureName(index);
			//var textureId = textureManager.Textures[textureName].TextureInfo.Id;
			
			var command = new ChangeTextureCommand(entity.Id, Colors.White, GetItemText(index));
			Core.GetManager<LevelManager>().BroadcastCommandToEntity(entity.Id, command);
		}
	}
}