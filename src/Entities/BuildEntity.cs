using System.Collections.Generic;
using Godot;
using MessagePack;
using YACY.Build;
using YACY.Entities.Components;
using static YACY.Build.ItemList;

namespace YACY.Entities;

public class BuildEntity : Spatial
{
	public int Id { get; }
	public Vector2 Position;
	public int Level;
	
	public BuildEntityType Type = BuildEntityType.Unknown;
	
	private List<Component> _components = new List<Component>();
	
	[IgnoreMember]
	public bool IsTransparent;

	public BuildEntity()
	{
		Id = Core.GetCore().GetNextId();
		
		Position = Vector2.Zero;
		IsTransparent = false;
		Level = 1;
	}

	//public BuildEntity(int id, Vector2 position, int level)
	//{
	//	Id = id;
	//	Position = position;
	//	Level = level;
	//}

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

	public void ReplaceComponents(List<Component> newComponents)
	{
		_components = newComponents;
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