using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Runtime.InteropServices;
using System.Xml;
using Godot;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;
using YACY.MeshGen;

namespace YACY.Build.Tools
{
	public class PencilCursor<T> : ICursorMode where T : PencilBuildEntity, new()
	{
		private BuildManager _buildManager;

		private bool _mouseDown;
		private Vector2 _position;

		private PackedScene _cursorMesh =
			ResourceLoader.Load<PackedScene>("res://Entities/Editor/Cursor/WallCursorMesh.tscn");

		private Spatial _mesh;

		private Vector2 _pencilStart;
		private Vector2 _pencilEnd;

		private static readonly List<int> MaxHeightList = new List<int> {4, 3, 2, 1, 2, 3, 4, 4, 4, 3};
		private static readonly List<int> MinHeightList = new List<int> {0, 0, 0, 0, 1, 2, 3, 2, 1, 1};

		private T _previewEntity; 

		public PencilCursor(Node parent)
		{
			_mouseDown = false;
			_position = new Vector2();
			
			_mesh = _cursorMesh.Instance<Spatial>();
			_mesh.Visible = false;
			parent.AddChild(_mesh);
		}

		public void Enable()
		{
			_buildManager = Core.GetManager<BuildManager>();
			_mesh.Visible = true;
		}

		public void Process(float delta, Vector2 mouseMotion)
		{
			var previousPosition = _position;
			
			// Has mouse moved?
			if (mouseMotion != Vector2.Zero)
			{
				var ray = _buildManager.GetMouseRay();
				var grid = _buildManager.GetGrid();

				var gridIntersection = grid.GridPlane.IntersectRay(ray.Origin - new Vector3(0, grid.Height, 0), ray.Direction);
				if (gridIntersection.HasValue)
				{
					_position.x = Mathf.Clamp(Mathf.RoundToInt(gridIntersection.Value.x / grid.Spacing), 0, grid.Size.x);
					_position.y = Mathf.Clamp(Mathf.RoundToInt(gridIntersection.Value.z / grid.Spacing), 0, grid.Size.y);

					var newPosition = new Vector3(_position.x * grid.Spacing, grid.Height, _position.y * grid.Spacing);
					_mesh.Transform = new Transform(_mesh.Transform.basis, newPosition);
				}
			}

			// Pencil is down, and the position on the grid has changed
			if (_mouseDown && !_position.IsEqualApprox(previousPosition))
			{
				_pencilEnd = _position;
				
				if (_previewEntity == null)
				{
					_previewEntity = new T();
					_previewEntity.StartPosition = _pencilStart;
					_previewEntity.EndPosition = _pencilEnd;
					
					Core.GetManager<SelectionManager>().Deselect();
					
					_buildManager.AddPreviewMesh(_previewEntity);
				}

				if (!_pencilStart.IsEqualApprox(_pencilEnd))
				{
					GD.Print($"start: {_pencilStart}, end {_pencilEnd}");
					
					_previewEntity.EndPosition = _pencilEnd;
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
		}

		public void onMouseRelease()
		{
			_mouseDown = false;
			_buildManager.RemovePreviewMesh();
			
			// Don't add empty wall
			if (!_pencilStart.IsEqualApprox(_pencilEnd))
			{
				var newEntity = new T();
				newEntity.StartPosition = _pencilStart;
				newEntity.EndPosition = _pencilEnd;
				
				Core.GetManager<LevelManager>().AddEntity<T>(newEntity, _buildManager.Level);
				newEntity.GenerateMesh();
			}
			
			Core.GetManager<BuildManager>().RemovePreviewMesh();
			_previewEntity = null;
		}

		public void onKeyPressed(string scancode)
		{
			GD.Print($"Scancode pressed: {scancode}");
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