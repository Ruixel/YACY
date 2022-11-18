using YACY.Build.Tools;
using YACY.Legacy.Objects;

namespace YACY.Geometry
{
	public interface ILegacyGeometryManager : IPencilService, IManager
	{
		void AddWall(LegacyWall wall);
	}
}