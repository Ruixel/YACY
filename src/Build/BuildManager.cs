using System;
using System.Collections.Generic;
using Godot;
using YACY.Build.Tools;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;
using YACY.UI;
using YACY.Util;

namespace YACY.Build
{
	// Takes care of adding, editing and removing entities from the level
	// When active, it gives the player building tools
	public partial class BuildManager : IBuildManager
	{
		private Node _root;
		private bool _enabled;

		private EditorCamera _editorCamera;
		private Cursor _cursor;
		private Grid _grid;
		private Control _ui;

		private Node3D _previewContainer;

		private Dictionary<Type, BuildEntity> _defaultEntities;

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

			var rayOrigin = _editorCamera.GetCamera3d().GetCameraTransform().Origin;
			var rayDirection = _editorCamera.GetCamera3d().ProjectRayNormal(mousePosition);

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
			_previewContainer = new Node3D();
			//_ui = _uiScene.Instantiate<BuildInterface>();
			
			SetTool<Wall>();

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

		public void SetTool<T>() where T : BuildEntity, new()
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
				if (itemMetadata.Tool == ToolType.Pencil)
				{
					_cursor.UsePencilCursor<T>();
				}
				else if (itemMetadata.Tool == ToolType.Placement)
				{
					_cursor.UsePlacementCursor<T>();
				}

				OnToolChange?.Invoke(this, (itemMetadata.Tool, typeof(T)));
			}
		}

		public void TempSetPlacementTool<T>() where T : BuildEntity, new()
		{
			_cursor.UsePlacementCursor<T>();
			OnToolChange?.Invoke(this, (ToolType.Placement, typeof(T)));
		}

		public BuildEntity GetDefaultEntity(Type entityType)
		{
			return _defaultEntities.TryGetValue(entityType, out var entity) ? entity : null;
		}

		public void Ready()
		{
			// TODO: Should be loaded up from a item list
			_defaultEntities = new Dictionary<Type, BuildEntity>()
			{
				{typeof(LegacyWall), new LegacyWall()},
				{typeof(LegacyPlatform), new LegacyPlatform()},
				{typeof(Wall), new Wall()}
			};
			
			GD.Print($"type of wall {typeof(LegacyWall)}");
			
			GD.Print("Build Manager: Ready");
		}
	}
}