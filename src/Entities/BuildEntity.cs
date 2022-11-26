using Godot;

namespace YACY.Entities;

public class BuildEntity : Spatial
{
	public int Id { get; }
	
	public BuildEntity()
	{
		Id = Core.GetCore().GetNextId();
	}

	public virtual void GenerateMesh()
	{
		throw new System.NotImplementedException();
	}
}