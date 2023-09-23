using Godot;
using YACY.Util;

namespace YACY.Build
{
	public partial class Grid : Node
	{
		public Plane GridPlane { get; private set; }
		public float Spacing { get; }
		public Vector2 Size { get; }
		public float Height { get; private set; }

		private StandardMaterial3D _gridMaterial = GD.Load<StandardMaterial3D>("res://Entities/Editor/Grid/GridMaterial.tres");

		private MeshInstance3D _gridMesh;

		public Grid()
		{
			_gridMesh = new MeshInstance3D();
			AddChild(_gridMesh);
			
			// Generate simple grid to CY coordinates
			Spacing = 1f;
			Size = new Vector2(80, 80);
			Height = GetHeightFromLevel(Core.GetManager<BuildManager>().Level);
			GridPlane = new Plane(new Vector3(0, Height-1, 0), 0f);

			Core.GetManager<BuildManager>().OnLevelChange += (_, level) =>
			{
				Height = GetHeightFromLevel(level);
				GridPlane = new Plane(new Vector3(0, 1, 0), 0f);
				GenerateMesh();
			};
			
			GenerateMesh();
		}

		private float GetHeightFromLevel(int level)
		{
			return level * Constants.LevelHeight;
		}

		//public Grid(Vector2 size, float spacing, MeshInstance gridMesh, float height = 0)
		//{
		//	Size = size;
		//	Spacing = spacing;
		//	_gridMesh = gridMesh;
		//	Height = height;
		//	GridPlane = new Plane(new Vector3(0, -1, 0), height);
		//	
		//	GenerateMesh();
		//}

		private void GenerateMesh()
		{
			_gridMesh.Transform = new Transform3D(Basis.Identity, new Vector3(Size.X * Spacing / 2, Height + 0.005f, Size.Y * Spacing / 2));
			
			var planeMesh = new PlaneMesh();
			planeMesh.Size = Size * Spacing;
			_gridMaterial.Uv1Scale = new Vector3(Size.X, Size.Y, 1);
			planeMesh.Material = _gridMaterial;

			_gridMesh.Mesh = planeMesh;
		}
	}
}