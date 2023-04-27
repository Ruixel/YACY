using Godot;
using MessagePack;

namespace YACY.Entities.Components;

[MessagePackObject]
public class HeightComponent : Component
{
	public HeightComponent(BuildEntity entity) : base(entity)
	{
	}

	public HeightComponent()
	{
	}

	[Key(1)] public float BottomHeight { get; set; } = 0.0f;
	[Key(2)] public float TopHeight { get; set; } = 1.0f;

	public void ChangeHeight(float bottom, float top)
	{
		BottomHeight = bottom;
		TopHeight = top;
	}

	public override void RenderUI(Control itemEditor)
	{
		return;
	}
}