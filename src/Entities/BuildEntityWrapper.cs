using System;
using Godot;
using MessagePack;

namespace YACY.Entities;

[MessagePackObject]
public class BuildEntityWrapper
{
	[Key(0)] public int Id { get; set; }
	[Key(1)] public (float x, float y) Position { get; set; }
	[Key(2)] public int Level { get; set; }

	public static BuildEntityWrapper CreateWrapper<T>(T entity) where T : BuildEntity
	{
		var newWrapper = new BuildEntityWrapper
		{
			Id = entity.Id,
			Position = (entity.Position.x, entity.Position.y),
			Level = entity.Level
		};

		return newWrapper;
	}
}