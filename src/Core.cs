using System.Collections.Generic;
using Godot;
using SimpleInjector;
using YACY.Build;
using YACY.Build.Tools;
using Container = SimpleInjector.Container;

namespace YACY
{
	public class Core : Node
	{
		private readonly List<Node> _buildTools;
		
		private readonly Container _container;
		public Core()
		{
			_buildTools = new List<Node>();
			
			// Create DI Container
			_container = new Container();
			_container.Register<IWallManager, WallManager>(Lifestyle.Singleton);
			_container.Register<IBuildManager, BuildManager>(Lifestyle.Singleton);
			
			_container.Verify();
			
			// Add build tools
			//AddBuildTools();
			
			_container.GetInstance<IBuildManager>().EnableBuildMode(this);
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

		public TService GetService<TService>() where TService : class
		{
			return _container.GetInstance<TService>();
		}
		
		public override void _Ready()
		{
			GD.Print("Core node ready");

			var handler = _container.GetInstance<IWallManager>();
			handler.HelloWorld();
		}
	}
}
