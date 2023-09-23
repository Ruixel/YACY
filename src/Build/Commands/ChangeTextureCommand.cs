using System.Collections.Generic;
using Godot;
using YACY.Entities;
using YACY.Entities.Components;

namespace YACY.Build;

public partial class ChangeTextureCommand : ICommand
{
	//private readonly IEnumerable<int> _entityIds;
	
	//public ChangeTextureCommand(IEnumerable<int> ids)
	//{
	//	_entityIds = ids;
	//}

	private int _entityId;
	private Color _color;
	private string _texture;

	public ChangeTextureCommand(int entityId, Color color, string texture)
	{
		_entityId = entityId;
		_color = color;
		_texture = texture;
	}
	
	public void Execute()
	{
		var entity = Core.GetManager<LevelManager>().GetEntity(_entityId);

		TextureComponent textureComponent = entity.GetComponent<TextureComponent>();
		textureComponent?.ChangeColor(_color);
		textureComponent?.ChangeTexture(_texture);
	}

	public string GetInfo()
	{
		return $"Entity #{_entityId}: Change colour to {_color}, and texture to {_texture}";
	}
}