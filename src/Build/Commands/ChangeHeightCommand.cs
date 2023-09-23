using YACY.Entities.Components;

namespace YACY.Build;

public partial class ChangeHeightCommand : ICommand
{
	private int _entityId;
	private float _bottomHeight;
	private float _topHeight;

	public ChangeHeightCommand(int entityId, float bottomHeight, float topHeight)
	{
		_entityId = entityId;
		_bottomHeight = bottomHeight;
		_topHeight = topHeight;
	}

	public void Execute()
	{
		var entity = Core.GetManager<LevelManager>().GetEntity(_entityId);

		HeightComponent heightComponent = entity.GetComponent<HeightComponent>();
		heightComponent?.ChangeHeight(_bottomHeight, _topHeight);
	}

	public string GetInfo()
	{
		return $"Entity #{_entityId}: Change bottom height to {_bottomHeight} and top height to {_topHeight}";
	}
}