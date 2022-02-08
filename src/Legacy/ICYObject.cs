using Godot;

namespace YACY.Legacy
{
    public interface ICYObject
    {
        void CreateObject(Node worldAPI);
        string SerializeObject();
    }
}