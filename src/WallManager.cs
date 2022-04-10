using System;
using Godot;

namespace YACY
{
	public class WallManager : IWallManager
	{
		public void HelloWorld()
		{
			GD.Print("HelloWorld from the Wall Manager");
		}
	}
}