using Godot;

namespace YACY.Build.Tools
{
	public interface IPencilService
	{
		void AddLine(Vector2 startPosition, Vector2 endPosition);
	}
}