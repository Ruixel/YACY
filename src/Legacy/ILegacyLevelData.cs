using System.Collections.Generic;

namespace YACY.Legacy
{
    public struct LegacyLevelData
    {
        public string Title { get; set; }
        public string Author { get; set; }

        public Dictionary<string, ICollection<string>> RawObjectData { get; set; }
        public Dictionary<string, ICollection<ICYObject>> Objects { get; set; }
    }
}