using System;
using System.Collections.Generic;
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

		private Dictionary<Type, Dictionary<int, BuildEntity>> _entities;
		private Dictionary<Type, Dictionary<Vector2, List<int>>> _gridMap;
		
		public int MaxLevel { get; }
		public int MinLevel { get; }

		public LevelManager()
		{
			_levelContainer = new Spatial();
			_entities = new Dictionary<Type, Dictionary<int, BuildEntity>>();
			_gridMap = new Dictionary<Type, Dictionary<Vector2, List<int>>>();

			MaxLevel = 20;
			MinLevel = 0;
		}
		
		public void AddNodeContainer(Node root)
		{
			if (_containerAdded)
				return;
			
			_levelContainer = new Spatial();
			root.AddChild(_levelContainer);

			_containerAdded = true;
		}

		public Spatial GetContainer()
		{
			return _levelContainer;
		}

		public void AddEntity<T>(BuildEntity entity) where T : BuildEntity
		{
			// Add to main container
			if (!_entities.TryGetValue(typeof(T), out var list))
			{
				list = new Dictionary<int, BuildEntity>();
				_entities.Add(typeof(T), list);

				if (entity is IStoredPosition)
				{
					var gridMap = new Dictionary<Vector2, List<int>>();
					_gridMap.Add(typeof(T), gridMap);
				}
			}
			
			_levelContainer.AddChild(entity);
			list.Add(entity.Id, entity);

			// If positions of entity need to be remembered
			if (entity is IStoredPosition entityWithStoredPos)
			{
				var positionsToAdd = entityWithStoredPos.GetPositions();
				var entityId = entity.Id;

				foreach (var pos in positionsToAdd)
				{
					if (_gridMap[typeof(T)].TryGetValue(pos, out var grid))
					{
						grid.Add(entityId);
					}
					else
					{
						grid = new List<int> {entityId};
						_gridMap[typeof(T)].Add(pos, grid);
					}
				}
			}
		}
		
		public List<T> GetEntitiesAtPosition<T>(Vector2 pos, int omitId = -1) where T : BuildEntity, IStoredPosition
		{
			if (!_gridMap.ContainsKey(typeof(T))) return new List<T>();
			
			if (_gridMap[typeof(T)].TryGetValue(pos, out var entities))
			{
				var foundEntities = new List<T>();
				foreach (var entityId in entities)
				{
					if (_entities[typeof(T)].TryGetValue(entityId, out var entity))
					{
						if (omitId != entity.Id)
							foundEntities.Add(entity as T);
					}
				}

				return foundEntities;
			}
			
			return new List<T>();
		}

		public void Ready()
		{
			GD.Print("Level Manager: Ready");
		}
	}
}