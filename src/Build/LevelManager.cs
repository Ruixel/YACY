using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using YACY.Entities;

namespace YACY.Build
{
	// Holds level data for the world
	// Also, it is where all the Godot entities reside
	public class LevelManager : ILevelManager
	{
		private Spatial _levelContainer;
		private bool _containerAdded;

		private Dictionary<int, BuildEntity> _entities;
		private LevelData[] _levelData;

		public int MaxLevel { get; }
		public int MinLevel { get; }

		public LevelManager()
		{
			_levelContainer = new Spatial();
			_levelContainer.Name = "LevelContainer";
			_entities = new Dictionary<int, BuildEntity>();

			MaxLevel = 20;
			MinLevel = 0;

			_levelData = new LevelData[MaxLevel - MinLevel + 1];
			for (int i = MinLevel; i <= MaxLevel; i++)
			{
				var levelData = new LevelData(i);
				_levelData[i] = levelData;
			}
		}

		public void AddNodeContainer(Node root)
		{
			if (_containerAdded)
				return;

			root.AddChild(_levelContainer);

			_containerAdded = true;
		}

		public Spatial GetContainer()
		{
			return _levelContainer;
		}

		public void AddEntity<T>(BuildEntity entity, int? level = null) where T : BuildEntity
		{
			var receivedLevel = level ?? Core.GetManager<BuildManager>().Level;
			var levelItemMap = _levelData[receivedLevel]._itemMap;

			// Add to entity container
			_levelContainer.AddChild(entity);
			_entities.Add(entity.Id, entity);

			// If positions of entity need to be remembered
			if (entity is IStoredPosition entityWithStoredPos)
			{
				// Check level container exists
				if (!levelItemMap.ContainsKey(typeof(T)))
				{
					var gridMap = new Dictionary<Vector2, List<int>>();
					levelItemMap.Add(typeof(T), gridMap);
				}

				var positionsToAdd = entityWithStoredPos.GetPositions();
				var entityId = entity.Id;

				foreach (var pos in positionsToAdd)
				{
					if (levelItemMap[typeof(T)].TryGetValue(pos, out var grid))
					{
						grid.Add(entityId);
					}
					else
					{
						grid = new List<int> {entityId};
						levelItemMap[typeof(T)].Add(pos, grid);
					}
				}
			}
		}

		public List<T> GetEntitiesAtPosition<T>(Vector2 pos, int omitId = -1, int? level = null)
			where T : BuildEntity, IStoredPosition
		{
			var receivedLevel = level ?? Core.GetManager<BuildManager>().Level;
			var levelItemMap = _levelData[receivedLevel]._itemMap;
			
			if (!levelItemMap.ContainsKey(typeof(T))) return new List<T>();
			if (!levelItemMap[typeof(T)].TryGetValue(pos, out var entities)) return new List<T>();

			var entitiesIterator =
				from entityId in entities
				where omitId != entityId
				select _entities[entityId] as T;

			return entitiesIterator.ToList();
		}


		public void Ready()
		{
			GD.Print("Level Manager: Ready");
		}
	}

	class LevelData
	{
		public Dictionary<Type, Dictionary<Vector2, List<int>>> _itemMap;
		private int _level;

		public LevelData(int level)
		{
			_level = level;
			_itemMap = new Dictionary<Type, Dictionary<Vector2, List<int>>>();
		}
	}
}