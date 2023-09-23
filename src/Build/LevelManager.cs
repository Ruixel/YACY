using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using MessagePack;
using YACY.Entities;
using YACY.Legacy;
using YACY.Legacy.Objects;
using YACY.Util;

namespace YACY.Build
{
	// Holds level data for the world
	// Also, it is where all the Godot entities reside
	public partial class LevelManager : ILevelManager
	{
		private Node3D _levelContainer;
		private bool _containerAdded;

		private Dictionary<int, BuildEntity> _entities;
		private LevelData[] _levelData;

		public int MaxLevel { get; }
		public int MinLevel { get; }

		public LevelManager()
		{
			_levelContainer = new Node3D();
			_levelContainer.Name = "LevelContainer";
			_entities = new Dictionary<int, BuildEntity>();

			MaxLevel = 20;
			MinLevel = 0;

			_levelData = new LevelData[MaxLevel - MinLevel + 1];
			for (var i = MinLevel; i <= MaxLevel; i++)
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

		public Node3D GetContainer()
		{
			return _levelContainer;
		}

		public BuildEntity GetEntity(int id)
		{
			return _entities[id];
		}

		public void AddEntity(BuildEntity entity, int? level = null)
		{
			var receivedLevel = level ?? Core.GetManager<BuildManager>().Level;
			var levelItemMap = _levelData[receivedLevel]._itemMap;
			var entityType = entity.Type;

			// Add to entity container
			_levelContainer.AddChild(entity);
			_entities.Add(entity.Id, entity);

			// If positions of entity need to be remembered
			if (entity is IStoredPosition entityWithStoredPos)
			{
				// Check level container exists
				if (!levelItemMap.ContainsKey(entityType))
				{
					var gridMap = new Dictionary<Vector2, List<int>>();
					levelItemMap.Add(entityType, gridMap);
				}

				var positionsToAdd = entityWithStoredPos.GetPositions();
				var entityId = entity.Id;

				foreach (var pos in positionsToAdd)
				{
					if (levelItemMap[entityType].TryGetValue(pos, out var grid))
					{
						grid.Add(entityId);
					}
					else
					{
						grid = new List<int> {entityId};
						levelItemMap[entityType].Add(pos, grid);
					}
				}
			}

			entity.GenerateMesh();
		}

		public List<T> GetEntitiesAtPosition<T>(Vector2 pos, BuildEntityList.Type entityType, int omitId = -1,
			int? level = null) where T : BuildEntity
		{
			var receivedLevel = level ?? Core.GetManager<BuildManager>().Level;
			var levelItemMap = _levelData[receivedLevel]._itemMap;

			if (!levelItemMap.ContainsKey(entityType)) return new List<T>();
			if (!levelItemMap[entityType].TryGetValue(pos, out var entities)) return new List<T>();

			var entitiesIterator =
				from entityId in entities
				where omitId != entityId
				select _entities[entityId] as T;

			return entitiesIterator.ToList();
		}

		public void BroadcastCommandToEntity(int entityId, ICommand command)
		{
			var selectedEntity = GetEntity(entityId);
			if (selectedEntity != null)
			{
				selectedEntity.ExecuteCommand(command);
				GD.Print(command.GetInfo());
				
				Core.GetManager<SelectionManager>().RegenerateSelectionMesh();
			}
		}

		public byte[] SerializeLevel()
		{
			var wrappedEntities = new LinkedList<BuildEntityWrapper>();
			foreach (var entity in _entities)
			{
				var wrapper = BuildEntityWrapper.CreateWrapper(entity.Value);
				wrappedEntities.AddLast(wrapper);
			}

			return MessagePackSerializer.Serialize(wrappedEntities, LevelSerializerResolver.Options);
		}

		private void ClearLevel()
		{
			Core.GetManager<SelectionManager>().Deselect();

			foreach (var buildEntity in _entities)
			{
				buildEntity.Value.QueueFree();
			}

			_levelData = new LevelData[MaxLevel - MinLevel + 1];
			for (var i = MinLevel; i <= MaxLevel; i++)
			{
				var levelData = new LevelData(i);
				_levelData[i] = levelData;
			}

			_entities = new Dictionary<int, BuildEntity>();
		}

		public void LoadLevel(byte[] data)
		{
			// Check if it's a legacy aMazer level (they all start with '[#name:')
			if (CYLevelParser.CheckMagicValue(data))
			{
				var legacyLevelData = CYLevelParser.ParseCYLevel(data.GetStringFromUtf8());
				Console.WriteLine($"Loaded \"{legacyLevelData.Title}\" by {legacyLevelData.Author}");

				ClearLevel();
				CYLevelCoreFactory.CreateObjectsInWorld(legacyLevelData);
				return;
			}

			var levelData =
				MessagePackSerializer.Deserialize<LinkedList<BuildEntityWrapper>>(data,
					LevelSerializerResolver.Options);
			ClearLevel();

			foreach (var wrappedEntity in levelData)
			{
				var entity = BuildEntityWrapper.Unwrap(wrappedEntity);
				AddEntity(entity, entity.Level);
			}
		}

		public void Ready()
		{
			GD.Print("Level Manager: Ready");
		}
	}

	class LevelData
	{
		public Dictionary<BuildEntityList.Type, Dictionary<Vector2, List<int>>> _itemMap;
		private int _level;

		public LevelData(int level)
		{
			_level = level;
			_itemMap = new Dictionary<BuildEntityList.Type, Dictionary<Vector2, List<int>>>();
		}
	}
}