using Godot;

namespace YACY.Legacy
{
    public class LegacyWorldLoaderNode : Node
    {
        [Export] private NodePath _loaderNodePath;

        HTTPClient Client;

        public override void _Ready()
        {
            GD.Print("Hello world");
            LoadLevelFromFileSystem("user://Ashoto District.cy");
        }

        public void LoadLevelFromFileSystem(string fileName)
        {
            var WorldAPI = GetNode<Node>(_loaderNodePath);

            var GameFile = new File();
            if (GameFile.FileExists(fileName))
            {
                GD.Print($"[C#] Found: {fileName}");
            }
            else
            {
                GD.Print($"[C#] File not found");
                return;
            }

            GameFile.Open(fileName, File.ModeFlags.Read);
            GD.Print(GameFile.ToString());
            GameFile.Close();
        }
    }
}