using Godot;

namespace YACY.Legacy.Objects
{
    public class CYWall : ICYObject
    {
        private Vector2 StartPosition;
        private Vector2 Displacement;

        private CYTexture FrontTexture;
        private CYTexture BackTexture;

        private CYHeight Height;
        private int Level;
        
        public void CreateObject()
        {
            throw new System.NotImplementedException();
        }

        public string SerializeObject()
        {
            throw new System.NotImplementedException();
        }
    }
}