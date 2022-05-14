using Godot;

namespace YACY.Build.Tools
{
	public interface ICursorMode
	{
		void Ready();
		void Process(float delta, Vector2 mouseMotion);
		void onToolChange();
		void onModeChange();
		void onLevelChange();
	}
}