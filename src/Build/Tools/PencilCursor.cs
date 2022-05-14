using Godot;

namespace YACY.Build.Tools
{
	public class PencilCursor : ICursorMode
	{
		public void Ready()
		{
			
		}
		
		public void Process(float delta, Vector2 mouseMotion)
		{
			// Has mouse moved?
			if (mouseMotion != Vector2.Zero)
			{
				//var rayOrigin = 
			}
		}

		public void onToolChange()
		{
			throw new System.NotImplementedException();
		}

		public void onModeChange()
		{
			throw new System.NotImplementedException();
		}

		public void onLevelChange()
		{
			throw new System.NotImplementedException();
		}
	}
}