using System.Collections.Generic;
using YACY.Entities;

namespace YACY
{
	public interface ISelectionManager: IManager
	{
		void SelectEntity(BuildEntity entity);
		void Deselect();
		List<BuildEntity> GetItemsSelected();
		
	}
}