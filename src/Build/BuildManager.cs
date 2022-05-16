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
		private Node _root;
		private bool _enabled;
		
		private Dictionary<Type, object> _buildTools;

		private EditorCamera _editorCamera;
		private Cursor _cursor;
		private Grid _grid;

		public event EventHandler onLevelChange;
		
		public BuildManager()
		{
			_enabled = false;
			_buildTools = new Dictionary<Type, object>();
		}

		public void EnableBuildMode(Node root)
		{
			if (!IsEnabled())
			{
				_root = root;
				_enabled = true;
			}
			
			//AddBuildTools();
			CreateBuildTools(root);

			onLevelChange?.Invoke(this, EventArgs.Empty);
			//var camera = GetBuildTool<EditorCamera>();
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

		/*private void AddBuildTool<T>() where T : Node, new()
		{
			var tool = new T();
			_root.AddChild(tool);
			_buildTools.Add(typeof(T), tool);
		}
		
		private void AddBuildTools()
		{
			AddBuildTool<Cursor>();
			AddBuildTool<EditorCamera>();
		}

		public T GetBuildTool<T>()
		{
			if (_buildTools.TryGetValue(typeof(T), out var tool))
			{
				return (T) tool;
			}

			throw new NullReferenceException($"Build tool ${typeof(T)} not found.");
		}

		public void RemoveBuildTools()
		{
			foreach (var pair in _buildTools)
			{
				var type = pair.Key;
				if (type.IsAssignableFrom(typeof(ITool)))
				{
					var tool = (type) pair.Value;
					tool.
				}
			}

			_buildTools.Clear();
		}*/
	}
}