using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Godot;
using YACY.Build.Tools;
using YACY.Util;

namespace YACY.Build
{
	public class BuildManager : IBuildManager
	{
		private readonly IWallManager _wallManager;

		private Node _root;
		private bool _enabled;

		private EditorCamera _editorCamera;
		private Cursor _cursor;
		private Grid _grid;

		public event EventHandler onLevelChange;

		public BuildManager(IWallManager wallManager)
		{
			_wallManager = wallManager;
			_enabled = false;
		}

		public void EnableBuildMode(Node root)
		{
			if (!IsEnabled())
			{
				_root = root;
				_enabled = true;
			}

			CreateBuildTools(root);

			onLevelChange?.Invoke(this, EventArgs.Empty);
		}

		public bool IsEnabled()
		{
			return _enabled && _root != null;
		}

		public Ray GetMouseRay()
		{
			var mousePosition = _root.GetViewport().GetMousePosition();

			var rayOrigin = _editorCamera.GetCamera().GetCameraTransform().origin;
			var rayDirection = _editorCamera.GetCamera().ProjectRayNormal(mousePosition);

			return new Ray(rayOrigin, rayDirection);
		}

		public Grid GetGrid()
		{
			return _grid;
		}

		private void CreateBuildTools(Node root)
		{
			_editorCamera = new EditorCamera();
			_cursor = new Cursor(this);
			_grid = new Grid();

			root.AddChild(_editorCamera);
			root.AddChild(_cursor);
			root.AddChild(_grid);
		}

		private void DestroyBuildTools(Node root)
		{
			root.RemoveChild(_editorCamera);
			root.RemoveChild(_cursor);
			root.RemoveChild(_grid);

			_editorCamera = null;
			_cursor = null;
			_grid = null;

			_enabled = false;
		}
	}
}