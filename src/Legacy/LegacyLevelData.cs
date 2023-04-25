using System.Collections.Generic;

namespace YACY.Legacy
{
    public struct LegacyLevelData
    {
        public string Title { get; set; }
        public string Author { get; set; }

        public Dictionary<string, ICollection<IList<string>>> RawObjectData { get; set; }
    }
}