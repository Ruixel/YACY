using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Build.Tools;
using YACY.MeshGen;

namespace YACY.Geometry
{
	public class WallManager : IWallManager
	{
		private Spatial _wallContainer;

		private Dictionary<Vector2, List<int>> _gridMap;
		private Dictionary<int, Wall> _wallMap;

		private MeshInstance _previewWall;

		public WallManager()
		{
			_wallContainer = new Spatial();
			_gridMap = new Dictionary<Vector2, List<int>>();
			_wallMap = new Dictionary<int, Wall>();

			_previewWall = new MeshInstance();
			_wallContainer.AddChild(_previewWall);
		}
		
		public void HelloWorld()
		{
			GD.Print("HelloWorld from the Wall Manager");
		}

		private void CreateContainer()
		{
			Core.GetManager<LevelManager>().GetContainer().AddChild(_wallContainer);
		}

		private void AddToGrid(Vector2 pos, Wall wall)
		{
			List<int> grid;
			var entityId = wall.Id;
			if (_gridMap.TryGetValue(pos, out grid))
			{
				grid.Add(entityId);
			}
			else
			{
				grid = new List<int> {entityId};
				_gridMap.Add(pos, grid);
			}

		}

		/*private void AddToGrid(Vector2 pos, Wall wall)
		{
			List<int> grid;
			if (_wallMap.TryGetValue(pos, out grid))
			{
				grid.Add(wall);
			}
			else
			{
				grid = new List<int> {entityId};
				_gridMap.Add(pos, grid);
			}
		}*/
		
		private List<Wall> GetWalls(IEnumerable<int> entityIds, int omitId = -1)
		{
			var walls = new List<Wall>();
			foreach (var entityId in entityIds)
			{
				if (_wallMap.TryGetValue(entityId, out var wall))
				{
					if (omitId != wall.Id)
						walls.Add(wall);
				}
			}

			return walls;
		}

		public List<Wall> GetWallsAtPosition(Vector2 pos, int omitId = -1)
		{
			if (_gridMap.TryGetValue(pos, out var walls))
			{
				return GetWalls(walls, omitId);
			}
			
			return new List<Wall>();
		}
		
		public void AddWall(Wall wall)
		{
			if (_gridMap.ContainsKey(wall.StartPosition) || _gridMap.ContainsKey(wall.EndPosition))
				GD.Print("Already part of a wall here :P");
			
			AddToGrid(wall.StartPosition, wall);
			AddToGrid(wall.EndPosition, wall);
			_wallMap.Add(wall.Id, wall);
			
			wall.GenerateMergedMesh(GetWallsAtPosition(wall.StartPosition, wall.Id), GetWallsAtPosition(wall.EndPosition, wall.Id), true);
			_wallContainer.AddChild(wall);
		}

		public void AddLine(Vector2 startPosition, Vector2 endPosition)
		{
			var wall = new Wall(startPosition, endPosition);
			AddWall(wall);
		}

		public void GeneratePreview(Vector2 startPosition, Vector2 endPosition)
		{
			_previewWall.Visible = true;
			_previewWall.Mesh = WallGenerator.GenerateWall(startPosition, endPosition, 1, 0, 1, 0.1f);
		}

		public void HidePreview()
		{
			_previewWall.Visible = false;
		}

		public void Ready()
		{
			var levelContainer = Core.GetManager<LevelManager>().GetContainer();
			levelContainer.AddChild(_wallContainer);
		}
	}
}