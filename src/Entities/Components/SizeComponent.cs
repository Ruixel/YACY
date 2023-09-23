using System;
using System.Diagnostics;
using Godot;
using MessagePack;
using YACY.Build;
using YACY.Build.Commands;
using YACY.UI;

namespace YACY.Entities.Components;

[MessagePackObject]
public partial class SizeComponent : Component
{
	public SizeComponent(int componentId, int minSize, int maxSize)
	{
		Console.WriteLine($"min: {minSize}, max: {maxSize}");
		Debug.Assert(maxSize > minSize);

		_minSize = minSize;
		_maxSize = maxSize;
	}

	public SizeComponent()
	{
	}
	
	[Key(1)] public int Size { get; set; } = 1;

	//[IgnoreMember]
	[Key(2)] private int _minSize;
	//[IgnoreMember]
	[Key(3)] private int _maxSize;

	public void ChangeSize(int newSize)
	{
		Size = Mathf.Clamp(newSize, _minSize, _maxSize);
	}

	public override void RenderUI(Control itemEditor)
	{
		var propertyList = itemEditor.GetNode<Control>("MarginContainer/VBoxContainer");

		propertyList?.AddChild(new SpinboxUI("Size", _minSize, _maxSize,
			(entityId, newValue) => new ChangeSizeCommand(entityId, newValue)));
	}
}