using YACY.Entities.Components;

namespace YACY.Build.Commands;

public class ChangeSizeCommand : ICommand
{
	private int _entityId;
	private int _size;

	public ChangeSizeCommand(int entityId, int size)
	{
		_entityId = entityId;
		_size = size;
	}

	public void Execute()
	{
		var entity = Core.GetManager<LevelManager>().GetEntity(_entityId);

		SizeComponent sizeComponent = entity.GetComponent<SizeComponent>();
		sizeComponent?.ChangeSize(_size);
	}

	public string GetInfo()
	{
		return $"Entity #{_entityId}: Change size to {_size}";
	}
}