using System.Collections.Generic;
using Godot;
using MessagePack;
using YACY.Build;
using YACY.Entities.Components;

namespace YACY.Entities;

public class BuildEntity : Spatial
{
	[Key(0)]
	public int Id { get; }
	[Key(1)]
	public Vector2 Position;
	[Key(2)]
	public int Level;
	
	//[Key(3)]
	private readonly List<Component> _components = new List<Component>();
	
	[IgnoreMember]
	public bool IsTransparent;

	public BuildEntity()
	{
		Id = Core.GetCore().GetNextId();
		
		Position = Vector2.Zero;
		IsTransparent = false;
		Level = 1;
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