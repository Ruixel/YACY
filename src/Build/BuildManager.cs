using System;
using System.Runtime.InteropServices;
using Godot;
using YACY.Build.Tools;
using YACY.Entities;
using YACY.Geometry;
using YACY.UI;
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
		private Control _ui;

		private Spatial _previewContainer;
		
		private PackedScene _uiScene = ResourceLoader.Load<PackedScene>("res://Scenes/UI/BuildUI.tscn");

		public event EventHandler<int> OnLevelChange;
		public event EventHandler<(ToolType, Type)> OnToolChange;
		
		public int Level { get; private set; }

		public BuildManager()
		{
			Level = 1;
			
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

			OnLevelChange?.Invoke(this, 1);
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
			_ui = _uiScene.Instance<BuildInterface>();

			root.AddChild(_editorCamera);
			root.AddChild(_cursor);
			root.AddChild(_grid);
			root.AddChild(_previewContainer);
			root.AddChild(_ui);
		}

		private void DestroyBuildTools(Node root)
		{
			root.RemoveChild(_editorCamera);
			root.RemoveChild(_cursor);
			root.RemoveChild(_grid);
			root.RemoveChild(_previewContainer);
			root.RemoveChild(_ui);

			_editorCamera = null;
			_cursor = null;
			_grid = null;
			_previewContainer = null;
			_ui = null;

			_enabled = false;
		}

		public void SetLevel(int level)
		{
			var levelManager = Core.GetManager<LevelManager>();
			level = (level > levelManager.MaxLevel) ? levelManager.MaxLevel : level;
			level = (level < levelManager.MinLevel) ? levelManager.MinLevel : level;

			Level = level;
			OnLevelChange?.Invoke(this, level);
		}

		public void SetTool<T>() where T : PencilBuildEntity, new()
		{
			BuildItemAttribute itemMetadata = null;
			var attrs = System.Attribute.GetCustomAttributes(typeof(T));
			foreach (var attribute in attrs)
			{
				if (attribute is BuildItemAttribute itemAttribute)
				{
					itemMetadata = itemAttribute;
				}
			}

			if (itemMetadata != null)
			{
				_cursor.UsePencilCursor<T>();
				//OnToolChange?.Invoke(this, (itemMetadata.Tool, typeof(T)));
			}
		}

		public void Ready()
		{
			GD.Print("Build Manager: Ready");
		}
	}
}