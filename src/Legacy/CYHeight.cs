using System;

namespace YACY.Legacy
{
	// This defines the height of an object
	// It normalises to the height of a level, where StartHeight is the bottom and EndHeight is the top
	//
	// ----------- EndHeight
	// |
	// |
	// |
	// |
	// ----------- StartHeight
	//
	public partial class CYHeight
	{
		private static readonly int[] MaxHeightList = new int[] {4, 3, 2, 1, 2, 3, 4, 4, 4, 3};
		private static readonly int[] MinHeightList = new int[] {0, 0, 0, 0, 1, 2, 3, 2, 1, 1};
		
		private double _endHeight;
		private double _startHeight;

		public double EndHeight
		{
			get => _endHeight;
			set
			{
				if (_endHeight > _startHeight && _endHeight > 0.0) _endHeight = value;
			}
		}

		public double StartHeight
		{
			get => _startHeight;
			set
			{
				if (_startHeight < _endHeight && _startHeight < 1.0) _startHeight = value;
			}
		}

		public CYHeight(int legacyHeight)
		{
			_startHeight = MinHeightList[legacyHeight - 1] / 4.0;
			_endHeight = MaxHeightList[legacyHeight - 1] / 4.0;
		}
		
	}
}
