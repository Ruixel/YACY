using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Entities.Components;

namespace YACY.Entities;

public class BuildEntity : Spatial
{
	public int Id { get; }
	public Vector2 Position;
	public bool IsTransparent;
	private readonly List<Component> _components = new List<Component>();

	public BuildEntity()
	{
		Id = Core.GetCore().GetNextId();
		
		Position = Vector2.Zero;
		IsTransparent = false;
	}

	public void AddComponent(Component component)
	{
		_components.Add(component);
	}

	// TODO: Convert to dictionary
	public T GetComponent<T>() where T : Component
	{
		foreach (var component in _components)
		{
			if (component is T foundComponent)
			{
				return foundComponent;
			}
		}

		return null;
	}

	public List<Component> GetAllComponents()
	{
		return _components;
	}

	public void ExecuteCommand(ICommand command)
	{
		command.Execute();
		GenerateMesh();
	}

	public virtual void GenerateMesh()
	{
		throw new System.NotImplementedException();
	}

	public virtual Mesh CreateSelectionMesh()
	{
		throw new System.NotImplementedException();
	}
}