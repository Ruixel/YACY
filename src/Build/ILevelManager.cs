using Godot;

namespace YACY.Build
{
	public interface ILevelManager : IManager
	{
		void AddNodeContainer(Node root);
		Spatial GetContainer();
	}
}