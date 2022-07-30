using System.Collections.Generic;
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
			
		private readonly Container _container;
		private int _nextId = 1;
		
		public Core()
		{
			_buildTools = new List<Node>();
			
			// Create DI Container
			_container = new Container();
			_container.Register<ILevelManager, LevelManager>(Lifestyle.Singleton);
			_container.Register<IWallManager, WallManager>(Lifestyle.Singleton);
			_container.Register<IBuildManager, BuildManager>(Lifestyle.Singleton);
			
			_container.Verify();
			
			// Add build tools
			//AddBuildTools();
			
			_container.GetInstance<ILevelManager>().AddNodeContainer(this);
			_container.GetInstance<IBuildManager>().EnableBuildMode(this);

			_singleton = this;
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

		public static TService GetService<TService>() where TService : class
		{
			return _singleton._container.GetInstance<TService>();
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
