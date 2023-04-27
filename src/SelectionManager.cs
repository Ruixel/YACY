using System;
using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Entities;
using YACY.Util;

namespace YACY
{
	public class SelectionManager: ISelectionManager
	{
		private List<BuildEntity> _selected;
		
		private Spatial _container;
		private bool _containerInLevel;

		private MeshInstance _selectionMesh;

		private SpatialMaterial _selectionMaterial =
			ResourceLoader.Load<SpatialMaterial>("res://res/materials/selection.tres");
		
		public event EventHandler<BuildEntity> OnSelection;

		public SelectionManager()
		{
			_selected = new List<BuildEntity>();
			
			_container = new Spatial();
			_container.Name = "SelectionContainer";

			_selectionMesh = new MeshInstance();
			_selectionMesh.Name = "SelectionMesh";
			_container.AddChild(_selectionMesh);
		}
		
		public void Ready()
		{
			Core.GetManager<LevelManager>().GetContainer().AddChild(_container);
		}
		
		public void SelectEntity(BuildEntity entity)
		{
			_selected = new List<BuildEntity> {entity};
			OnSelection?.Invoke(this, entity);
			
			GenerateSelectionMesh();
		}

		public void Deselect()
		{
			_selected = new List<BuildEntity>();
			_selectionMesh.Mesh = null;
		}

		public List<BuildEntity> GetItemsSelected()
		{
			return _selected;
		}

		// Is this needed? Should this be called only as an event?
		public void RegenerateSelectionMesh()
		{
			GenerateSelectionMesh();
		}

		private void GenerateSelectionMesh()
		{
			if (_selected.Count >= 1)
			{
				_selectionMesh.Mesh = _selected[0].CreateSelectionMesh();
				_selectionMesh.Mesh.SurfaceSetMaterial(0, _selectionMaterial);
				_selectionMesh.Visible = true;
			}
		}
	}
}