using Godot;

namespace YACY.Build.Tools
{
	public interface ICursorMode
	{
		void Enable();
		void Process(float delta, Vector2 mouseMotion);
		void onMousePress();
		void onMouseRelease();
		void onKeyPressed(string scancode);
		void onToolChange();
		void onModeChange();
		void onLevelChange();
	}
}