using Godot;
using Godot.Collections;

namespace YACY.Legacy
{
    public class LegacyWorldLoaderNode : Node
    {
        [Export] private NodePath _loaderNodePath;

        HTTPClient Client;

        private Node ObjectLoader;
        private Node WorldApi;

        public override void _Ready()
        {
            GD.Print("Hello world");
            
            WorldApi = GetNode<Node>(_loaderNodePath);
            ObjectLoader = WorldApi.GetNode<Node>("ObjectLoader");

            // var test = new Array();
            // test.Add("res://res/levels/Panda.cy");
            // WorldApi = GetNode<Node>(_loaderNodePath);
            // WorldApi.Connect("ready", this, "LoadLevelFromFileSystem", test);
            OnReady();
        }

        public async void OnReady()
        {
            await ToSignal(WorldApi, "ready");
            LoadLevelFromFileSystem("res://res/levels/Panda.cy");
        }

        public void LoadLevelFromFileSystem(string fileName)
        {
            var gameFile = new File();
            if (gameFile.FileExists(fileName))
            {
                GD.Print($"[C#] Found: {fileName}");
            }
            else
            {
                GD.Print($"[C#] File not found");
                return;
            }

            gameFile.Open(fileName, File.ModeFlags.Read);
            var level = CYLevelParser.ParseCYLevel(gameFile.GetAsText());
            gameFile.Close();
            
            CYLevelFactory.CreateObjectsInWorld(level, WorldApi);
        }
    }
}