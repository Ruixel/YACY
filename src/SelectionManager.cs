using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Entities;

namespace YACY
{
	public class SelectionManager: ISelectionManager
	{
		private List<IEntity> _selected;
		
		private Spatial _container;
		private bool _containerInLevel;

		private MeshInstance _selectionMesh;

		private SpatialMaterial _selectionMaterial =
			ResourceLoader.Load<SpatialMaterial>("res://res/materials/selection.tres");

		public SelectionManager()
		{
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
		
		public void SelectEntity(IEntity entity)
		{
			_selected = new List<IEntity> {entity};
			GenerateSelectionMesh();
		}

		public void Deselect()
		{
			_selected = new List<IEntity>();
			_selectionMesh.Mesh = null;
		}

		public List<IEntity> GetItemsSelected()
		{
			return _selected;
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