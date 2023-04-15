using System.Reflection;
using Godot;
using YACY.Build;

namespace YACY.Entities.Components;

public abstract class Component
{
	protected BuildEntity _entity;

	public Component(BuildEntity entity)
	{
		_entity = entity;
	}

	public virtual void ExecuteCommand(ICommand command)
	{
		GD.PushWarning($"No ExecuteCommand() given for ${MethodBase.GetCurrentMethod().Name}");
	}
}