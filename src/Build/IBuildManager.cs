using System;
using Godot;
using YACY.Entities;
using YACY.Util;

namespace YACY.Build
{
	public interface IBuildManager : IManager
	{
		event EventHandler<int> OnLevelChange;
		event EventHandler<(ToolType, Type)> OnToolChange;
		
		void EnableBuildMode(Node root);
		bool IsEnabled();
		Ray GetMouseRay();
		Grid GetGrid();

		void AddPreviewMesh(BuildEntity entity);
		void RemovePreviewMesh();
	}
}