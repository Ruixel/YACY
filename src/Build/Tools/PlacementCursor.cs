using System;
using Godot;
using Godot.Collections;
using YACY.Entities;
using YACY.Util;

namespace YACY.Build.Tools;

public partial class PlacementCursor<T> : ICursorMode where T : BuildEntity, new()
{
	private BuildManager _buildManager;

	private Vector2 _prototypeSize = new Vector2(2, 2);
	private Dictionary<Vector2, bool> _prototypePlacements = new Dictionary<Vector2, bool>();
	private Vector2 _prototypePlacementOffset = new Vector2();

	private Vector2 _gridPos = new Vector2();

	private BuildEntity _prototype = null;

	public PlacementCursor(Node parent)
	{
		_prototype = new T();
		_prototype.IsTransparent = true;
		_prototype.Level = 1;
		parent.AddChild(_prototype);
		
		_prototypeSize = new Vector2(1, 1);
	}
	
	public void Enable()
	{
		_buildManager = Core.GetManager<BuildManager>();
		
		_prototype.GenerateMesh();
	}

	public void Delete()
	{
		if (_prototype != null)
		{
			_prototype.QueueFree();
			_prototype = null;
		}
	}

	public void Process(float delta, Vector2 mouseMotion)
	{
		var grid = _buildManager.GetGrid();
		
		if (mouseMotion != Vector2.Zero)
		{
			var ray = _buildManager.GetMouseRay();
        
			var gridIntersection = grid.GridPlane.IntersectsRay(ray.Origin - new Vector3(0, grid.Height, 0), ray.Direction);
			if (gridIntersection.HasValue)
			{
				_gridPos.X = Mathf.Clamp(Mathf.RoundToInt(gridIntersection.Value.X / grid.Spacing), 0, grid.Size.X);
				_gridPos.Y = Mathf.Clamp(Mathf.RoundToInt(gridIntersection.Value.Z / grid.Spacing), 0, grid.Size.Y);
				//Console.WriteLine($"X: {_gridPos.x}, Y: {_gridPos.y}");
			}
		}

		if (_prototype != null)
		{
			// Why is this Vector3 and why did it work before?
			//_prototype.Position = new Vector3(_gridPos.X * grid.Spacing, grid.Height - Constants.LevelHeight + 0.01f, _gridPos.Y * grid.Spacing);
			
			_prototype.Position = new Vector2(_gridPos.X * grid.Spacing, _gridPos.Y * grid.Spacing);
		}
		
		//if (parent.mousePlacePressed)
		//{
		//	if (parent.motionDetected)
		//	{
		//		if (CheckPrototypePlacements(gridPos, prototypeSize))
		//		{
		//			WorldAPI.ObjCreate(gridPos.ToVector2());
		//			AddPrototypePlacements(gridPos, prototypeSize);
		//		}
		//	}
		//}
		//else
		//{
		//	gridPos.x = Mathf.Clamp(gridPos.x, Mathf.FloorToInt(prototypeSize.x / 2.0f), parent.gridNum - Mathf.FloorToInt(prototypeSize.x / 2.0f));
		//	gridPos.y = Mathf.Clamp(gridPos.y, Mathf.FloorToInt(prototypeSize.y / 2.0f), parent.gridNum - Mathf.FloorToInt(prototypeSize.y / 2.0f));
		//	prototype.Transform.origin = new Vector3(gridPos.x, 0, gridPos.y);
		//}
        
		//if (parent.mousePlaceReleased)
		//{
		//	// Do something here
		//}
	}

	public void onMousePress()
	{
		Core.GetManager<SelectionManager>().Deselect();
		
		var grid = _buildManager.GetGrid();
		var newEntity = new T();
		newEntity.Position.X = _gridPos.X * grid.Spacing;
		newEntity.Position.Y = _gridPos.Y * grid.Spacing;
		
		Core.GetManager<LevelManager>().AddEntity(newEntity, _buildManager.Level);
		
		Core.GetManager<SelectionManager>().SelectEntity(newEntity);
	}

	public void onMouseRelease()
	{
		//throw new System.NotImplementedException();
		return;
	}

	public void onKeyPressed(string scancode)
	{
		float? height = scancode switch
		{
			"1" => 0.00f,
			"2" => 0.25f,
			"3" => 0.50f,
			"4" => 0.75f,
			_ => null
		};

		if (height.HasValue)
		{
			var selection = Core.GetManager<SelectionManager>().GetItemsSelected();
			if (selection.Count > 0 && selection[0] != null)
			{
				var command = new ChangeHeightCommand(selection[0].Id, height.Value, 1.0f);
				Core.GetManager<LevelManager>().BroadcastCommandToEntity(selection[0].Id, command);
			}
		}
	}

	public void onToolChange()
	{
		throw new System.NotImplementedException();
	}

	public void onModeChange()
	{
		throw new System.NotImplementedException();
	}

	public void onLevelChange()
	{
		throw new System.NotImplementedException();
	}
}