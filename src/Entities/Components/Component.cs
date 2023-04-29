using System;
using System.Reflection;
using Godot;
using MessagePack;
using YACY.Build;

namespace YACY.Entities.Components;

[Union(0, typeof(TextureComponent))]
[Union(1, typeof(DisplacementComponent))]
[Union(2, typeof(HeightComponent))]
[Union(3, typeof(SizeComponent))]
[MessagePackObject]
public abstract class Component
{
	[Key(0)] 
	public int ComponentId { get; }
	
	protected BuildEntity _entity;

	public Component(BuildEntity entity)
	{
		_entity = entity;
		ComponentId = Core.GetCore().GetNextId();
	}

	public Component()
	{
		ComponentId = Core.GetCore().GetNextId();
	}

	public virtual void ExecuteCommand(ICommand command)
	{
		GD.PushWarning($"No ExecuteCommand() given for ${MethodBase.GetCurrentMethod().Name}");
	}

	public virtual void RenderUI(Control itemEditor)
	{
		throw new NotImplementedException();
	}
}