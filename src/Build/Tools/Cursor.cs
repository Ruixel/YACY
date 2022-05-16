using System;
using Godot;
using YACY.Build;
using YACY.Build.Tools;

namespace YACY
{
	public class Cursor : Spatial
	{
		private readonly IBuildManager _buildManager;
		private ICursorMode _cursorMode;

		private Vector2 _mouseMotion;

		public Cursor(IBuildManager buildManager)
		{
			_buildManager = buildManager;
			_buildManager.onLevelChange += onLevelChange;

			_cursorMode = new PencilCursor(buildManager, this);

			_mouseMotion = new Vector2();
		}

		public override void _Ready()
		{
			GD.Print("Cursor is ready :D");
			
			_cursorMode.Enable();
		}

		public override void _Process(float delta)
		{
			_cursorMode.Process(delta, _mouseMotion);
			
			_mouseMotion = Vector2.Zero; // Reset
		}

		public override void _Input(InputEvent @event)
		{
			if (@event is InputEventMouseMotion mouseEvent)
			{
				_mouseMotion = mouseEvent.Relative;
			}
		}

		public override void _UnhandledInput(InputEvent @event)
		{
		}

		private void onLevelChange(object sender, EventArgs eventArgs)
		{
			GD.Print("Level changed");
		}
	}
}