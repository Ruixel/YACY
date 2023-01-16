using System;
using System.Reflection;
using Godot;
using YACY.Build;
using YACY.Build.Tools;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;
using YACY.Util;

namespace YACY
{
	public class Cursor : Spatial
	{
		private readonly IBuildManager _buildManager;
		private ICursorMode _cursorMode;

		private Vector2 _mouseMotion;
		private bool _isMousePressed;

		public Cursor(IBuildManager buildManager)
		{
			_buildManager = buildManager;
			_buildManager.OnLevelChange += onLevelChange;
			_buildManager.OnToolChange += onToolChange;

			_cursorMode = new PencilCursor<Wall>(this);

			_mouseMotion = new Vector2();
			_isMousePressed = false;
		}

		private void onToolChange(object sender, (ToolType, Type) toolEvent)
		{
			//var t = toolEvent.Item2;
			//switch (toolEvent.Item1)
			//{
			//	case ToolType.Pencil:
			//		//_cursorMode = new PencilCursor<t>(this);
			//		MethodInfo method = GetType().GetMethod("CreatePencilCursor")!.MakeGenericMethod(new Type[] {t});
			//		method.Invoke(this, new object[] { });
			//		break;
			//}
		}

		public void UsePencilCursor<T>() where T : PencilBuildEntity, new()
		{
			_cursorMode.Delete();
			_cursorMode = new PencilCursor<T>(this);
			_cursorMode.Enable();
		}

		public override void _Ready()
		{
			GD.Print("Cursor is ready :D");

			//(_cursorMode as PencilCursor)?.LoadPencilService(Core.GetService<IWallManager>());
			//(_cursorMode as PencilCursor)?.LoadPencilService(Core.GetManager<LegacyGeometryManager>());
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
			} else if (@event is InputEventKey keyEvent)
			{
				if (keyEvent.Pressed)
				{
					_cursorMode.onKeyPressed(OS.GetScancodeString(keyEvent.Scancode));
				}
			}
		}

		public override void _UnhandledInput(InputEvent @event)
		{
			if (@event is InputEventMouseButton mouseButton)
			{
				if (mouseButton.ButtonIndex == 1)
				{
					var isPressed = mouseButton.Pressed;
					if (_isMousePressed ^ isPressed)
					{
						if (isPressed)
						{
							_cursorMode.onMousePress();
							_isMousePressed = true;
						}
						else
						{
							_cursorMode.onMouseRelease();
							_isMousePressed = false;
						}
					}
				}
			}
		}

		private void onLevelChange(object sender, int eventArgs)
		{
			GD.Print("Level changed");
		}

	}
}