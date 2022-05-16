using System;
using Godot;

namespace YACY.Build.Tools
{
	public class PencilCursor : ICursorMode
	{
		private readonly IBuildManager _buildManager;

		private Vector2 _position;

		private PackedScene _cursorMesh =
			ResourceLoader.Load<PackedScene>("res://Entities/Editor/Cursor/WallCursorMesh.tscn");

		private Spatial _mesh;

		public PencilCursor(IBuildManager buildManager, Node parent)
		{
			_buildManager = buildManager;

			_position = new Vector2();
			
			_mesh = _cursorMesh.Instance<Spatial>();
			_mesh.Visible = false;
			parent.AddChild(_mesh);
		}

		public void Enable()
		{
			_mesh.Visible = true;
		}

		public void Process(float delta, Vector2 mouseMotion)
		{
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