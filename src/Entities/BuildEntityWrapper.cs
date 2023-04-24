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
	[Key(1)] public (float x, float y) Position { get; set; }
	[Key(2)] public int Level { get; set; }
	[Key(3)] public ItemList.BuildEntityType EntityType { get; set; }
	
	[Key(4)] public List<Component> Components = new List<Component>();

	public static BuildEntityWrapper CreateWrapper<T>(T entity) where T : BuildEntity
	{
		var newWrapper = new BuildEntityWrapper
		{
			Id = entity.Id,
			Position = (entity.Position.x, entity.Position.y),
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
			ItemList.BuildEntityType.Wall => new Wall(),
			ItemList.BuildEntityType.LegacyWall => new LegacyWall(),
			ItemList.BuildEntityType.LegacyPlatform => new LegacyPlatform(),
			_ => new BuildEntity()
		};

		entity.Position = new Vector2(wrappedEntity.Position.x, wrappedEntity.Position.y);
		entity.Level = wrappedEntity.Level;
		entity.ReplaceComponents(wrappedEntity.Components);

		return entity;
	}
}