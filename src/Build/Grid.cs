using Godot;

namespace YACY.Build
{
	public class Grid : Node
	{
		public Plane GridPlane { get; }
		public float Spacing { get; }
		public Vector2 Size { get; }
		public float Height { get; }

		private SpatialMaterial _gridMaterial = GD.Load<SpatialMaterial>("res://Entities/Editor/Grid/GridMaterial.tres");

		public Grid()
		{
			// Generate simple grid to CY coordinates
			GridPlane = new Plane(new Vector3(0, -1, 0), 0f);
			Spacing = 1f;
			Size = new Vector2(80, 80);
			Height = 0f;
			
			GenerateMesh();
		}

		public Grid(Vector2 size, float spacing, float height = 0)
		{
			Size = size;
			Spacing = spacing;
			Height = height;
			GridPlane = new Plane(new Vector3(0, -1, 0), height);
			
			GenerateMesh();
		}

		private void GenerateMesh()
		{
			var mesh = new MeshInstance();
			mesh.Transform = new Transform(Basis.Identity, new Vector3(Size.x * Spacing / 2, Height, Size.y * Spacing / 2));
			
			var planeMesh = new PlaneMesh();
			planeMesh.Size = Size * Spacing;
			_gridMaterial.Uv1Scale = new Vector3(Size.x, Size.y, 1);
			planeMesh.Material = _gridMaterial;

			mesh.Mesh = planeMesh;
			AddChild(mesh);
		}
	}
}