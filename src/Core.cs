using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using Godot;
using SimpleInjector;
using YACY.Build;
using YACY.Build.Tools;
using YACY.Geometry;
using Container = SimpleInjector.Container;

namespace YACY
{
	public class Core : Node
	{
		private readonly List<Node> _buildTools;
		private static Core _singleton;
			
		private readonly Dictionary<Type, IManager> _container;
		private int _nextId = 1;
		
		private static bool _isReady = false;
		
		public Core()
		{
			_buildTools = new List<Node>();
			
			// Create DI Container
			_container = new Dictionary<Type, IManager>();
			Register<LevelManager>();
			//Register<WallManager>();
			Register<BuildManager>();
			//Register<LegacyGeometryManager>();
			Register<SelectionManager>();
			
			_singleton = this;
			_isReady = true;
			
			// Run ready
			foreach (var manager in _container)
			{
				manager.Value.Ready();
			}
			
			GetManager<LevelManager>().AddNodeContainer(this);
			GetManager<BuildManager>().EnableBuildMode(this);
		}

		private void Register<T>() where T: IManager, new()
		{
			_container.Add(typeof (T), new T());
		}

		private void AddBuildTool<T>() where T : Node, new()
		{
			var tool = new T();
			AddChild(tool);
			_buildTools.Add(tool);
		}

		private void AddBuildTools()
		{
			//AddBuildTool<Cursor>();
			//AddBuildTool<EditorCamera>();
		}

		public void RemoveBuildTools()
		{
			foreach (var tool in _buildTools)
			{
				RemoveChild(tool);
			}

			_buildTools.Clear();
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
