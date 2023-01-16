using System;
using System.Collections.Generic;
using Godot;
using YACY.Build;

namespace YACY
{
	public class Core : Node
	{
		private readonly List<Node> _buildTools;
		private static Core _singleton;
			
		private readonly Dictionary<Type, IManager> _container;
		private int _nextId = 1;

		public static bool _isReady;
		
		public Core()
		{
			_buildTools = new List<Node>();
			
			// Create DI Container
			_container = new Dictionary<Type, IManager>();
			Register<LevelManager>();
			Register<BuildManager>();
			Register<SelectionManager>();
			
			_singleton = this;
			_isReady = true;
			
			// Run ready
			foreach (var manager in _container)
			{
				manager.Value.Ready();
			}

			GetManager<BuildManager>().OnLevelChange += (sender, level) =>
			{
				GD.Print($"Level set to {level}");
			};
			
			GetManager<LevelManager>().AddNodeContainer(this);
			GetManager<BuildManager>().EnableBuildMode(this);
		}

		private void Register<T>() where T: IManager, new()
		{
			_container.Add(typeof (T), new T());
		}

		public static T GetManager<T>() where T : IManager
		{
			_singleton._container.TryGetValue(typeof(T), out var manager);
			return (T)manager;
		}
		
		public override void _Ready()
		{
			GD.Print("Core node ready");
		}

		public static Core GetCore()
		{
			return _singleton;
		}

		public int GetNextId()
		{
			return _nextId++;
		}
	}
}
