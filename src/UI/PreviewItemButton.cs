using System;
using Godot;

namespace YACY.UI;

public partial class PreviewItemButton : Button
{
	private Node3D _rotatingNode;
	private Transform3D _originalNodeTransform;
	private bool _mouseEntered;
	
	private static float RotationSpeed = 3;
	
	public event EventHandler onPressed;

	private PreviewItemButton()
	{
		SetProcess(false);
	}
	
	public void AddMesh(string meshLocation)
	{
		_rotatingNode = ResourceLoader.Load<PackedScene>(meshLocation).Instantiate<Node3D>();
		_originalNodeTransform = _rotatingNode.Transform;

		_rotatingNode.Name = "Mesh";
		GetNode<SubViewport>("SubViewportContainer/SubViewport").AddChild(_rotatingNode);
		
		SetProcess(true);
	}

	public new void SetName(string name)
	{
		GetNode<Label>("Label").Text = name;
	}
	
	private void OnPress()
	{
		GetNode<AudioStreamPlayer>("SelectSFX").Play();
		
		onPressed?.Invoke(this, EventArgs.Empty);
	}

	public void _Process(float delta)
	{
		if (_mouseEntered)
		{
			_rotatingNode.RotateY(RotationSpeed * delta);
		}
		else
		{
			_rotatingNode.Transform = _rotatingNode.Transform.InterpolateWith(_originalNodeTransform, 10 * delta);
		}
	}

	private void OnMouseEnter()
	{
		_mouseEntered = true;
		GetNode<AudioStreamPlayer>("ButtonSFX").Play();
	}

	private void OnMouseExit()
	{
		_mouseEntered = false;
	}
}
