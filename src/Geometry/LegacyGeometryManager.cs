using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Legacy.Objects;
using YACY.MeshGen;

namespace YACY.Geometry
{
	public class LegacyGeometryManager : ILegacyGeometryManager
	{
		private Spatial _geometryContainer;
		private bool _containerInLevel = false;
		
		private List<LegacyWall> _geometry;
		
		private MeshInstance _previewWall;

		public LegacyGeometryManager()
		{
			_geometryContainer = new Spatial();
			_geometry = new List<LegacyWall>();
			
			_previewWall = new MeshInstance();
			_geometryContainer.AddChild(_previewWall);
		}
		public void AddLine(Vector2 startPosition, Vector2 endPosition)
		{
			var newWall = new LegacyWall(startPosition, endPosition);
			AddWall(newWall);
		}

		public void GeneratePreview(Vector2 startPosition, Vector2 endPosition)
		{
			_previewWall.Visible = true;
			_previewWall.Mesh = WallGenerator.GenerateFlatWall(startPosition, endPosition, 1, 0, 1);
		}

		public void HidePreview()
		{
			_previewWall.Visible = false;
		}

		public void AddWall(LegacyWall wall)
		{
			if (!_containerInLevel)
			{
				Core.GetService<ILevelManager>().GetContainer().AddChild(_geometryContainer);
				_containerInLevel = true;
			}
			
			_geometry.Add(wall);
			wall.GenerateMesh();
			
			_geometryContainer.AddChild(wall);
			
			Core.GetService<ISelectionManager>().SelectEntity(wall);
		}
	}
}