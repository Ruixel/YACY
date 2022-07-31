using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Legacy.Objects;

namespace YACY.Geometry
{
	public class LegacyGeometryManager : ILegacyGeometryManager
	{
		private Spatial _geometryContainer;
		private bool _containerInLevel = false;
		
		private List<LegacyWall> _geometry;

		public LegacyGeometryManager()
		{
			_geometryContainer = new Spatial();
			_geometry = new List<LegacyWall>();
		}
		public void AddLine(Vector2 startPosition, Vector2 endPosition)
		{
			var newWall = new LegacyWall(startPosition, endPosition);
			AddWall(newWall);
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
		}
	}
}