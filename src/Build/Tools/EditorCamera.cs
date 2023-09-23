using System;
using Godot;
using YACY.Util;

namespace YACY.Build.Tools
{
	public partial class EditorCamera : Node3D
	{
		private readonly Camera3D _camera;
		private Vector2 _mouseMotion;

		private Vector2 _cameraPosition = new Vector2(0, 10);
		private float _cameraAngle = 35f;
		private float _cameraZoom = 6f;
		private float _cameraHeight = Constants.LevelHeight;
		private float _cameraHeightTarget = Constants.LevelHeight;

		private const float CamZoomMin = 5;
		private const float CamZoomMax = 20;
		private const float CamAngleMin = 15;
		private const float CamAngleMax = 85;
		private const float CamDragSpeed = 2;
		private const float CamKeyboardDragSpeed = 8;

		public EditorCamera()
		{
			_camera = new Camera3D();
			_camera.Rotation = new Vector3(Mathf.DegToRad(-45), Mathf.DegToRad(-90), 0);

			AddChild(_camera);

			Core.GetManager<BuildManager>().OnLevelChange += (sender, level) =>
			{
				_cameraHeightTarget = level * Constants.LevelHeight;
			};
		}

		private void ProcessInput(float delta)
		{
			var modifier = Input.IsActionPressed("modifier");
			
			if (Input.IsActionPressed("editor_camera_rotate") || (modifier && Input.IsActionPressed("editor_camera_pan")))
			{
				// Rotate Vertically
				_cameraAngle += _mouseMotion.Y * delta * 10;
				_cameraAngle = Mathf.Clamp(_cameraAngle, CamAngleMin, CamAngleMax);

				// Rotate Horizontally
				this.RotateY(-_mouseMotion.X * delta * 0.2f);
			}
			else if (Input.IsActionPressed("editor_camera_pan"))
			{
				var ySpeed = _mouseMotion.Y * delta;
				var xSpeed = _mouseMotion.X * delta;

				_cameraPosition.X += CamDragSpeed *
				                     ((Mathf.Cos(this.Rotation.Y) * ySpeed) + (Mathf.Sin(this.Rotation.Y) * -xSpeed));
				_cameraPosition.Y += CamDragSpeed *
				                     ((Mathf.Sin(this.Rotation.Y) * -ySpeed) + (Mathf.Cos(this.Rotation.Y) * -xSpeed));
			}
			
			// Pan camera using keyboard
			if (Input.IsActionPressed("move_forward") || Input.IsActionPressed("move_left") ||
			    Input.IsActionPressed("move_right") || Input.IsActionPressed("move_back"))
			{
				var forwards = Input.IsActionPressed("move_forward") ? 1 : 0;
				var backwards = Input.IsActionPressed("move_back") ? 1 : 0;
				
				var right = Input.IsActionPressed("move_right") ? 1 : 0;
				var left = Input.IsActionPressed("move_left") ? 1 : 0;
				
				var ySpeed = (forwards - backwards) * delta;
				var xSpeed = -(right - left) * delta;

				_cameraPosition.X += CamKeyboardDragSpeed *
				                     ((Mathf.Cos(this.Rotation.Y) * ySpeed) + (Mathf.Sin(this.Rotation.Y) * -xSpeed));
				_cameraPosition.Y += CamKeyboardDragSpeed *
				                     ((Mathf.Sin(this.Rotation.Y) * -ySpeed) + (Mathf.Cos(this.Rotation.Y) * -xSpeed));
			}
		}

		private void _Process(float delta)
		{
			// Input 
			ProcessInput(delta);

			// Move the camera away from target by the zoom distance
			var cameraTransform = _camera.Transform;
			var cameraRotation = _camera.Rotation;
			cameraTransform.Origin.X = Mathf.Sin(Mathf.DegToRad((_cameraAngle))) * _cameraZoom;
			cameraTransform.Origin.X = -Mathf.Cos(Mathf.DegToRad((_cameraAngle))) * _cameraZoom;

			cameraRotation.X = -Mathf.DegToRad(_cameraAngle);
			_cameraHeight = Mathf.Lerp(_cameraHeight, _cameraHeightTarget, 0.2f);

			_camera.Transform = cameraTransform;
			_camera.Rotation = cameraRotation;

			// Lerp the camera to match grid position
			var finalPosition = new Vector3(_cameraPosition.X, _cameraHeight, _cameraPosition.Y);
			//finalPosition = this.GlobalTransform.origin.LinearInterpolate(finalPosition, 0.4f);
			this.GlobalTransform = new Transform3D(this.GlobalTransform.Basis, finalPosition);

			// Reset mouse movement
			_mouseMotion = Vector2.Zero;
		}

		public override void _Input(InputEvent @event)
		{
			// Check for mouse movement
			if (@event is InputEventMouseMotion mouseEvent)
			{
				_mouseMotion = mouseEvent.Relative;
			}
			
			// Zoom input
			if (@event.IsActionPressed("editor_camera_zoom_in"))
			{
				_cameraZoom -= 1;
				_cameraZoom = Mathf.Clamp(_cameraZoom, CamZoomMin, CamZoomMax);
			}
			else if (@event.IsActionPressed("editor_camera_zoom_out"))
			{
				_cameraZoom += 1;
				_cameraZoom = Mathf.Clamp(_cameraZoom, CamZoomMin, CamZoomMax);
			}
		}

		public Camera3D GetCamera3d()
		{
			return _camera;
		}
	}
}