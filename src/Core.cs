using System.Collections.Generic;
using Godot;
using SimpleInjector;
using Container = SimpleInjector.Container;

namespace YACY
{
	public class Core : Node
	{
		private readonly Container _container;
		public Core()
		{
			_container = new Container();
			_container.Register<IWallManager, WallManager>(Lifestyle.Singleton);
			
			_container.Verify();
		}

		public override void _Ready()
		{
			GD.Print("Core node ready");

			var handler = _container.GetInstance<IWallManager>();
			handler.HelloWorld();
		}
	}
}
