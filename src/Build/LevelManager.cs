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

		private Dictionary<Type, List<BuildEntity>> _entities;

		public LevelManager()
		{
			_levelContainer = new Spatial();
			_entities = new Dictionary<Type, List<BuildEntity>>();
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
			if (!_entities.TryGetValue(typeof(T), out var list))
			{
				list = new List<BuildEntity>();
				_entities.Add(typeof(T), list);
			}
			
			_levelContainer.AddChild(entity);
			list.Add(entity);
		}

		public void Ready()
		{
			GD.Print("Level Manager: Ready");
		}
	}
}