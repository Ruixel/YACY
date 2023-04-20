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

		_itemList = new TextureSelectorUi();
		root.GetNode<Control>("MarginContainer/VBoxContainer").AddChild(_itemList);
	}
}