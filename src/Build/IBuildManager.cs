using System;
using Godot;
using YACY.Util;

namespace YACY.Build
{
	public interface IBuildManager : IManager
	{
		event EventHandler onLevelChange;
		
		void EnableBuildMode(Node root);
		bool IsEnabled();
		Ray GetMouseRay();
		Grid GetGrid();
	}
}