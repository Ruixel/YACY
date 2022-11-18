using System.Collections.Generic;
using Godot;
using YACY.Build.Tools;

namespace YACY.Geometry
{
	public interface IWallManager: IPencilService, IManager
	{
		void HelloWorld();
		void AddWall(Wall wall);
		List<Wall> GetWallsAtPosition(Vector2 pos, int omitId);
	}
}