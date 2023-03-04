using Godot;

namespace YACY.UI;

public class TexturePropertyUI : IPropertyUI
{
	private ItemList _itemList;
	
	public void Render(Control root)
	{
		if (_itemList != null)
		{
			_itemList.QueueFree();
		}

		_itemList = new ItemList();
		_itemList.FixedColumnWidth = 182;
		_itemList.FixedIconSize = new Vector2(32, 32);
		_itemList.RectMinSize = new Vector2(200, 120);
		root.AddChild(_itemList);

		foreach (var texture in Core.GetManager<TextureManager>().Textures)
		{
			_itemList.AddItem(texture.TextureInfo.Name, texture.ImageTexture);
		}
	}
}