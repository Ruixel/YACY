using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.MeshGen;

namespace YACY.Geometry
{
	public class WallManager : IWallManager
	{
		private Spatial _wallContainer;
		private bool _containerInLevel = false;

		private Dictionary<Vector2, List<int>> _gridMap;
		private Dictionary<int, Wall> _wallMap;

		public WallManager()
		{
			_wallContainer = new Spatial();
			_gridMap = new Dictionary<Vector2, List<int>>();
			_wallMap = new Dictionary<int, Wall>();
		}
		
		public void HelloWorld()
		{
			GD.Print("HelloWorld from the Wall Manager");
		}

		private void GetContainer()
		{
			Core.GetService<ILevelManager>().GetContainer().AddChild(_wallContainer);
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
		
		private List<Wall> GetWalls(IEnumerable<int> entityIds)
		{
			var walls = new List<Wall>();
			foreach (var entityId in entityIds)
			{
				if (_wallMap.TryGetValue(entityId, out var wall))
				{
					walls.Add(wall);
				}
			}

			return walls;
		}

		public List<Wall> GetWallsAtPosition(Vector2 pos)
		{
			if (_gridMap.TryGetValue(pos, out var walls))
			{
				return GetWalls(walls);
			}
			
			return new List<Wall>();
		}
		
		public void AddWall(Wall wall)
		{
			if (!_containerInLevel)
			{
				Core.GetService<ILevelManager>().GetContainer().AddChild(_wallContainer);
				_containerInLevel = true;
			}
			
			if (_gridMap.ContainsKey(wall.StartPosition) || _gridMap.ContainsKey(wall.EndPosition))
				GD.Print("Already part of a wall here :P");

			
			wall.GenerateMergedMesh(GetWallsAtPosition(wall.StartPosition), GetWallsAtPosition(wall.EndPosition), true);
			_wallContainer.AddChild(wall);
			
			AddToGrid(wall.StartPosition, wall);
			AddToGrid(wall.EndPosition, wall);
			_wallMap.Add(wall.Id, wall);
		}
	}
}