using Godot;

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
	}
}