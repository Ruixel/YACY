using Godot;

namespace YACY.Entities
{
	public interface IEntity
	{
		int Id { get; }

		Mesh CreateSelectionMesh();
	}
}