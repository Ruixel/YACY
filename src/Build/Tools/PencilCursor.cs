using System;
using System.Collections.Generic;
using Godot;
using YACY.Entities;
using YACY.Entities.Components;
using YACY.Util;

namespace YACY.Build.Tools
{
	public partial class PencilCursor<T> : ICursorMode where T : BuildEntity, new()
	{
		private BuildManager _buildManager;

		private bool _mouseDown;
		private Vector2 _position;

		private PackedScene _cursorMesh =
			ResourceLoader.Load<PackedScene>("res://Entities/Editor/Cursor/WallCursorMesh.tscn");

		private Node3D _mesh;

		private Vector2 _pencilStart;
		private Vector2 _pencilEnd;

		private static readonly List<int> MaxHeightList = new() {3, 4, 3, 2, 1, 2, 3, 4, 4, 4};
		private static readonly List<int> MinHeightList = new() {1, 0, 0, 0, 0, 1, 2, 3, 2, 1};
		
		private T _previewEntity; 

		public PencilCursor(Node parent)
		{
			_mouseDown = false;
			_position = new Vector2();
			
			_mesh = _cursorMesh.Instantiate<Node3D>();
			_mesh.Visible = false;
			parent.AddChild(_mesh);
		}

		public void Enable()
		{
			_buildManager = Core.GetManager<BuildManager>();
			_mesh.Visible = true;
		}

		public void Delete()
		{
			_mesh.Visible = false;
			_mesh.QueueFree();
		}

		public void Process(float delta, Vector2 mouseMotion)
		{
			var previousPosition = _position;
			
			// Has mouse moved?
			if (mouseMotion != Vector2.Zero)
			{
				var ray = _buildManager.GetMouseRay();
				var grid = _buildManager.GetGrid();

				var gridIntersection = grid.GridPlane.IntersectsRay(ray.Origin - new Vector3(0, grid.Height, 0), ray.Direction);
				if (gridIntersection.HasValue)
				{
					_position.X = Mathf.Clamp(Mathf.RoundToInt(gridIntersection.Value.X / grid.Spacing), 0, grid.Size.X);
					_position.Y = Mathf.Clamp(Mathf.RoundToInt(gridIntersection.Value.Z / grid.Spacing), 0, grid.Size.Y);

					var newPosition = new Vector3(_position.X * grid.Spacing, grid.Height, _position.Y * grid.Spacing);
					_mesh.Transform = new Transform3D(_mesh.Transform.Basis, newPosition);
				}
			}

			// Pencil is down, and the position on the grid has changed
			if (_mouseDown && !_position.IsEqualApprox(previousPosition))
			{
				_pencilEnd = _position;
				
				if (_previewEntity == null)
				{
					_previewEntity = new T();
					_previewEntity.Position = _pencilStart;
					_previewEntity.GetComponent<DisplacementComponent>().ChangeDisplacement(_pencilEnd);
					
					Core.GetManager<SelectionManager>().Deselect();
					
					_buildManager.AddPreviewMesh(_previewEntity);
				}

				if (!_pencilStart.IsEqualApprox(_pencilEnd))
				{
					GD.Print($"start: {_pencilStart}, end {_pencilEnd}");
					
					_previewEntity.GetComponent<DisplacementComponent>().ChangeDisplacement(_pencilEnd);
					_previewEntity.Visible = true;
					_previewEntity.GenerateMesh();
				}
				else
				{
					_previewEntity.Visible = false;
				}
			}
		}

		public void onMousePress()
		{
			_mouseDown = true;
			_pencilStart = _position;
			_pencilEnd = _position;
		}

		public void onMouseRelease()
		{
			_mouseDown = false;
			_buildManager.RemovePreviewMesh();
			
			// Don't add empty wall
			if (!_pencilStart.IsEqualApprox(_pencilEnd))
			{
				var newEntity = new T();
				newEntity.Position = _pencilStart;
				newEntity.GetComponent<DisplacementComponent>().ChangeDisplacement(_pencilEnd);
				
				Core.GetManager<LevelManager>().AddEntity(newEntity, _buildManager.Level);
				
				Core.GetManager<SelectionManager>().SelectEntity(newEntity);
			}
			
			Core.GetManager<BuildManager>().RemovePreviewMesh();
			if (_previewEntity != null)
			{
				_previewEntity.QueueFree();
				_previewEntity = null;
			}
		}

		public void onKeyPressed(string scancode)
		{
			var ch = (int)scancode.ToAsciiBuffer()[0] - 48;
			if (ch is >= 0 and <= 9)
			{
				var bottomHeight = MinHeightList[ch] / 4.0f;
				var topHeight = MaxHeightList[ch] / 4.0f;
					
				var selection = Core.GetManager<SelectionManager>().GetItemsSelected();
				if (selection.Count > 0 && selection[0] != null)
				{
					var command = new ChangeHeightCommand(selection[0].Id, bottomHeight, topHeight);
					Core.GetManager<LevelManager>().BroadcastCommandToEntity(selection[0].Id, command);
				}
			}
		}

		public void onToolChange()
		{
			throw new System.NotImplementedException();
		}

		public void onModeChange()
		{
			throw new System.NotImplementedException();
		}

		public void onLevelChange()
		{
			throw new System.NotImplementedException();
		}
	}
}