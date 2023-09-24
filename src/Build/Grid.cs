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
		private MeshInstance3D _gridDarkMesh;

		public Grid()
		{
			_gridMesh = new MeshInstance3D();
			AddChild(_gridMesh);
			
			_gridDarkMesh = new MeshInstance3D();
			AddChild(_gridDarkMesh);
			
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

		private void GenerateMesh()
		{
			_gridMesh.Transform = new Transform3D(Basis.Identity, new Vector3(Size.X * Spacing / 2, Height + 0.005f, Size.Y * Spacing / 2));
			
			var planeMesh = new PlaneMesh();
			planeMesh.Size = Size * Spacing;
			_gridMaterial.Uv1Scale = new Vector3(Size.X, Size.Y, 1);
			_gridMaterial.Anisotropy = 16;
			_gridMaterial.ShadingMode = BaseMaterial3D.ShadingModeEnum.Unshaded;
			_gridMaterial.DisableReceiveShadows = true;
			planeMesh.Material = _gridMaterial;

			_gridMesh.Mesh = planeMesh;
			
			// Dark grid
			var darkPlaneMesh = new PlaneMesh();
			darkPlaneMesh.Size = Size * Spacing;
			_gridDarkMesh.Transform = new Transform3D(Basis.Identity, new Vector3(Size.X * Spacing / 2, Height - 0.005f, Size.Y * Spacing / 2));
			
			// Dark grid material
			var darkGridMaterial = new StandardMaterial3D();
			darkGridMaterial.AlbedoColor = new Color(0.1f, 0.1f, 0.1f, 0.5f);
			darkGridMaterial.Transparency = BaseMaterial3D.TransparencyEnum.Alpha;
			darkGridMaterial.ShadingMode = BaseMaterial3D.ShadingModeEnum.Unshaded;
			darkGridMaterial.DisableReceiveShadows = true;
			
			darkPlaneMesh.Material = darkGridMaterial;
			_gridDarkMesh.Mesh = darkPlaneMesh;
		}
	}
}