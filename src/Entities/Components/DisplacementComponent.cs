using Godot;
using MessagePack;

namespace YACY.Entities.Components;

[MessagePackObject]
public class DisplacementComponent : Component
{
	public DisplacementComponent()
	{
	}
	
	[Key(1)]
	public Vector2 Displacement { get; set; } = Vector2.Zero;

	public void ChangeDisplacement(Vector2 newPosition)
	{
		Displacement = newPosition;
	}

	public override void RenderUI(Control itemEditor)
	{
		return;
	}
}