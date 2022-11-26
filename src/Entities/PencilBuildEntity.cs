using Godot;

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
	}
}