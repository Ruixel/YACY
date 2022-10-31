using System.Collections.Generic;
using YACY.Entities;

namespace YACY
{
	public interface ISelectionManager
	{
		void SelectEntity(IEntity entity);
		void Deselect();
		List<IEntity> GetItemsSelected();
		
	}
}