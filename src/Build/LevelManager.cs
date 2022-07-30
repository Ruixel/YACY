using Godot;

namespace YACY.Build
{
	public class LevelManager : ILevelManager
	{
		private Spatial _levelContainer;
		private bool _containerAdded = false;

		public LevelManager()
		{
			
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
	}
}