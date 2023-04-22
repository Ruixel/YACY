using Godot;
using YACY.Build;
using YACY.UI;

namespace YACY.Entities.Components;

public class TextureComponent : Component
{
	public TextureComponent(BuildEntity entity) : base(entity)
	{
	}

	public string TextureName { get; private set; } = "Color";
	public Color Color { get; private set; } = Colors.White;

	public void ChangeColor(Color newColor)
	{
		Color = newColor;
	}

	public void ChangeTexture(string texture)
	{
		TextureName = texture;
	}

	public override void ExecuteCommand(ICommand command)
	{
		GD.Print("Shouldn't be here :P");
	}

	public override void RenderUI(Control itemEditor)
	{
		var propertyList = itemEditor.GetNode<Control>("MarginContainer/VBoxContainer");

		propertyList?.AddChild(new TexturePropertyUI());
		//textureProperties.Render(itemEditor);
	}
}