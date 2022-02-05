using Godot;

namespace YACY.Legacy
{
    public interface ICYObject
    {
        void CreateObject();
        string SerializeObject();
    }
}