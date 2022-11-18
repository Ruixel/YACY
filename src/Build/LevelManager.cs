using Godot;

namespace YACY.Build
{
	// Holds level data for the world
	// Also, it is where all the Godot entities reside
	public class LevelManager : ILevelManager
	{
		private Spatial _levelContainer;
		private bool _containerAdded = false;

		public LevelManager()
		{
			_levelContainer = new Spatial();
		}
		
		public void AddNodeContainer(Node root)
		{
			if (_containerAdded)
				return;
			
			_levelContainer = new Spatial();
			root.AddChild(_levelContainer);

			_containerAdded = true;
		}

		public Spatial GetContainer()
		{
			return _levelContainer;
		}

		public void Ready()
		{
			GD.Print("Level Manager: Ready");
		}
	}
}