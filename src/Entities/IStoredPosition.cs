using System.Collections.Generic;
using Godot;

namespace YACY.Entities;

public interface IStoredPosition
{
	public IEnumerable<Vector2> GetPositions();
}