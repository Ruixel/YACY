using Godot;

namespace YACY.Build
{
	public interface ILevelManager
	{
		void AddNodeContainer(Node root);
		Spatial GetContainer();
	}
}