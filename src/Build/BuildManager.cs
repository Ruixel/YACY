using System;
using System.Runtime.InteropServices;
using Godot;
using YACY.Build.Tools;
using YACY.Entities;
using YACY.Geometry;
using YACY.Util;

namespace YACY.Build
{
	// Takes care of adding, editing and removing entities from the level
	// When active, it gives the player building tools
	public class BuildManager : IBuildManager
	{
		private Node _root;
		private bool _enabled;

		private EditorCamera _editorCamera;
		private Cursor _cursor;
		private Grid _grid;

		private Spatial _previewContainer;

		public event EventHandler onLevelChange;

		public BuildManager()
		{
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

		public void AddPreviewMesh(BuildEntity entity)
		{
			if (_previewContainer.GetChildCount() > 0)
			{
				RemovePreviewMesh();
			}
			
			_previewContainer.AddChild(entity);
		}

		public void RemovePreviewMesh()
		{
			foreach (Node child in _previewContainer.GetChildren())
			{
				_previewContainer.RemoveChild(child);
				child.QueueFree();
			}
		}

		private void CreateBuildTools(Node root)
		{
			_editorCamera = new EditorCamera();
			_cursor = new Cursor(this);
			_grid = new Grid();
			_previewContainer = new Spatial();

			root.AddChild(_editorCamera);
			root.AddChild(_cursor);
			root.AddChild(_grid);
			root.AddChild(_previewContainer);
		}

		private void DestroyBuildTools(Node root)
		{
			root.RemoveChild(_editorCamera);
			root.RemoveChild(_cursor);
			root.RemoveChild(_grid);
			root.RemoveChild(_previewContainer);

			_editorCamera = null;
			_cursor = null;
			_grid = null;
			_previewContainer = null;

			_enabled = false;
		}

		public void Ready()
		{
			GD.Print("Build Manager: Ready");
		}
	}
}