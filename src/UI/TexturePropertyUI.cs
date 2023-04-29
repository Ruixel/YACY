using System.Collections.Generic;
using System.Drawing;
using Godot;
using YACY.Build;
using YACY.Entities;
using YACY.Entities.Components;
using ItemList = Godot.ItemList;

namespace YACY.UI;

public class TexturePropertyUI : Control, IPropertyUI
{
	private readonly ItemList _textureItemList;
	private Dictionary<string, int> _textureIndex;

	public TexturePropertyUI()
	{
		AnchorRight = 1.0f;
		RectMinSize = new Vector2(RectMinSize.x, 130);
		
		_textureItemList = CreateTextureItemList();
		AddChild(_textureItemList);

		Core.GetManager<SelectionManager>().OnSelection += OnSelectionEvent;
	}

	public void Disconnect()
	{
		GD.PushWarning("Disconnecting :(");
		_textureItemList.Disconnect("item_selected", _textureItemList, nameof(OnItemSelected));
		Core.GetManager<SelectionManager>().OnSelection -= OnSelectionEvent;
		
		QueueFree();
	}

	private void OnSelectionEvent(object sender, BuildEntity entity)
	{
		var textureComponent = entity.GetComponent<TextureComponent>();
		if (textureComponent != null)
		{
			_textureItemList.Select(_textureIndex[textureComponent.TextureName]);
		}
	}

	private ItemList CreateTextureItemList()
	{
		var textureItemList = new ItemList();
		textureItemList.FixedColumnWidth = 182;
		textureItemList.FixedIconSize = new Vector2(32, 32);
		
		textureItemList.RectMinSize = new Vector2(200, 120);
		textureItemList.AnchorRight = 1.0f;
		textureItemList.Connect("item_selected", this, nameof(OnItemSelected));

		var index = 0;
		_textureIndex = new Dictionary<string, int>();
		foreach (var texture in Core.GetManager<TextureManager>().Textures.Values)
		{
			textureItemList.AddItem(texture.TextureInfo.Name, texture.ImageTexture);
			_textureIndex.Add(texture.TextureInfo.Name, index++);
		}

		return textureItemList;
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
			
			var command = new ChangeTextureCommand(entity.Id, Colors.White, _textureItemList.GetItemText(index));
			Core.GetManager<LevelManager>().BroadcastCommandToEntity(entity.Id, command);
		}
	}

	public void Render(Control root)
	{
		throw new System.NotImplementedException();
	}
}