using System.Collections.Generic;
using Godot;
using YACY.Entities.Components;

namespace YACY.Entities
{
	public abstract class PencilBuildEntity : BuildEntity
	{
		public Vector2 StartPosition { get; set; }
		public Vector2 EndPosition { get; set; }
		
		public PencilBuildEntity(Vector2 startPosition, Vector2 endPosition)
		{
			StartPosition = startPosition;
			EndPosition = endPosition;
		}
		
		public PencilBuildEntity(int id, List<Component> components): base(id, components)
		{
			StartPosition = Vector2.Zero;
			EndPosition = Vector2.Zero;
		}
	}
}