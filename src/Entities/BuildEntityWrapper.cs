using System;
using System.Collections.Generic;
using Godot;
using MessagePack;
using YACY.Entities.Components;
using YACY.Geometry;
using YACY.Legacy.Objects;
using ItemList = YACY.Build.ItemList;

namespace YACY.Entities;

[MessagePackObject]
public class BuildEntityWrapper
{
	[Key(0)] public int Id { get; set; }
	[Key(1)] public Vector2 Position { get; set; }
	[Key(2)] public int Level { get; set; }
	[Key(3)] public ItemList.BuildEntityType EntityType { get; set; }
	
	[Key(4)] public List<Component> Components = new List<Component>();

	public static BuildEntityWrapper CreateWrapper<T>(T entity) where T : BuildEntity
	{
		var newWrapper = new BuildEntityWrapper
		{
			Id = entity.Id,
			Position = entity.Position,
			Level = entity.Level,
			EntityType = entity.Type,
			Components = entity.GetAllComponents()
		};

		return newWrapper;
	}

	public static BuildEntity Unwrap(BuildEntityWrapper wrappedEntity)
	{
		var entity = wrappedEntity.EntityType switch
		{
			ItemList.BuildEntityType.Wall => new Wall(wrappedEntity.Id, wrappedEntity.Components),
			ItemList.BuildEntityType.LegacyWall => new LegacyWall(wrappedEntity.Id, wrappedEntity.Components),
			ItemList.BuildEntityType.LegacyPlatform => new LegacyPlatform(wrappedEntity.Id, wrappedEntity.Components),
			_ => new BuildEntity(wrappedEntity.Id, wrappedEntity.Components)
		};

		entity.Position = wrappedEntity.Position;
		entity.Level = wrappedEntity.Level;

		return entity;
	}
}