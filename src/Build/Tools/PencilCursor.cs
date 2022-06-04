using System;
using Godot;
using YACY.Geometry;
using YACY.MeshGen;

namespace YACY.Build.Tools
{
	public class PencilCursor : ICursorMode
	{
		private readonly IBuildManager _buildManager;

		private bool _mouseDown;
		private Vector2 _position;

		private PackedScene _cursorMesh =
			ResourceLoader.Load<PackedScene>("res://Entities/Editor/Cursor/WallCursorMesh.tscn");

		private Spatial _mesh;
		private MeshInstance _buffer;

		private Vector2 _pencilStart;
		private Vector2 _pencilEnd;

		public PencilCursor(IBuildManager buildManager, Node parent)
		{
			_buildManager = buildManager;

			_mouseDown = false;
			_position = new Vector2();
			
			_mesh = _cursorMesh.Instance<Spatial>();
			_mesh.Visible = false;
			parent.AddChild(_mesh);

			_buffer = new MeshInstance();
			parent.AddChild(_buffer);
		}

		public void Enable()
		{
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

				var gridIntersection = grid.GridPlane.IntersectRay(ray.Origin, ray.Direction);
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

				if (!_pencilStart.IsEqualApprox(_pencilEnd))
				{
					GD.Print($"start: {_pencilStart}, end {_pencilEnd}");
					_buffer.Mesh = WallGenerator.GenerateWall(_pencilStart, _pencilEnd, 1, 0, 1, 0.1f);
					
					_buffer.Visible = true;
				}
				else
				{
					_buffer.Visible = false; // Hide 0x0 walls
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
			_buffer.Visible = false;
			
			// Don't add empty wall
			if (!_pencilStart.IsEqualApprox(_pencilEnd))
			{
				var wall = new Wall(_pencilStart, _pencilEnd);
				Core.GetService<IWallManager>().AddWall(wall);
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