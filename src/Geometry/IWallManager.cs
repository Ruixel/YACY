using System.Collections.Generic;
using Godot;

namespace YACY.Geometry
{
	public interface IWallManager
	{
		void HelloWorld();
		void AddWall(Wall wall);
		List<Wall> GetWallsAtPosition(Vector2 pos);
	}
}