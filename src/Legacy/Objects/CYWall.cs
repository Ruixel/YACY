using Godot;
using YACY.Build;
using YACY.Util;

namespace YACY.Legacy.Objects
{
	[BuildItem(
		Name = "Wall",
        Tool = ToolType.Pencil,
		ItemPanelPreview = "res://Scenes/UI/Previews/ItemPanel/CYWall.tscn", 
		SelectionPreview = "res://Scenes/UI/Previews/Selected/CYWall.tscn")]
    public class CYWall : ICYObject
    {
        public Vector2 StartPosition;
        public Vector2 Displacement;

        public CYTexture FrontTexture;
        public CYTexture BackTexture;

        public CYHeight Height;
        internal int LegacyHeight; // CY uses a set number of heights
        public int Level;

        public void CreateObject(Node worldApi)
        {
            worldApi.Call("create_wall", Displacement, StartPosition, FrontTexture.ToVariant(), 
                BackTexture.ToVariant(), LegacyHeight, Level);
        }

        public string SerializeObject()
        {
            throw new System.NotImplementedException();
        }
    }
}