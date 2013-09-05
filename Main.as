package {
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	public class Main extends Sprite {
		private static const RAYCAST_STEP_SIZE:Number = 1;
		
		private var arrow:Arrow;
		private var radar:Radar;
		private var level:Level = new Level();
		private var light:Light = new Light();
		private var goal:Goal = new Goal();
		// lightCanvas is the sprite where we'll display the light
		private var lightCanvas:Sprite = new Sprite();
		
		private var mousePositionOnClick:Point;
		
		private var shouldPlayMouse:Boolean = false;
		private var hasCollectedLight:Boolean = false;
		private var shouldRecordMouse:Boolean = false;
		
		private var mouseMovementRecord:Vector.<Point> = new Vector.<Point>();
		
		public function Main() {
			arrow = new Arrow(this)
			
			addChild(level);
			
			radar = new Radar(this);
			
			addChild(light);
			light.x = 50;
			light.y = 200;
			
			addChild(lightCanvas);
			
			addChild(goal);
			goal.x = 600;
			goal.y = 240;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function startDrawing(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			
			mousePositionOnClick = new Point(mouseX, mouseY);
			level.visible = false;
			shouldRecordMouse = true;
		}
		
		private function mouseMoved(e:MouseEvent):void {
			arrow.moveBy(movementDistance());
			// saving current mouse position;
			mousePositionOnClick.x = mouseX;
			mousePositionOnClick.y = mouseY;
			
			var radarPrecision:Number = 20;
			var collisionDistance:Number = 50;
			collisionDistance = closestCollision(radarPrecision, RAYCAST_STEP_SIZE, collisionDistance);
			var rayAngle:Number = 2 * Math.PI / radarPrecision * radarPrecision;
			
			
			radar.size = collisionDistance;
			
			if (collisionDistance < 1) {
				loseGame();
			}
			
			// checking the collision between the arrow and the light, if we still did not pick up the light
			if (!hasCollectedLight) {
				collectLightIfAppropriate();
			} else {
				// do you remember the radar? Things are quite similar for the light, we only want more precision
				lightCanvas.graphics.clear();
				lightCanvas.graphics.lineStyle(0, 0xffffff, 0);
				var mtx:Matrix = new Matrix();
				mtx.createGradientBox(232, 232, 0, arrow.x - 116, arrow.y - 116);
				// we are drawing a gradient this time;
				lightCanvas.graphics.beginGradientFill(GradientType.RADIAL, [0xffffff, 0xffffff], [0.5, 0], [0, 255], mtx);
				radarPrecision = 60;
				for (var i:uint = 0; i <= radarPrecision; i++) {
					rayAngle = 2 * Math.PI / radarPrecision * i;
					for (var j:uint = 16; j <= 116; j += RAYCAST_STEP_SIZE) {
						if (level.hitTestPoint(arrow.x + j * Math.cos(rayAngle), arrow.y + j * Math.sin(rayAngle), true)) {
							break;
						}
					}
					if (i == 0) {
						// moving the graphic pen if it's the first point we find
						lightCanvas.graphics.moveTo(arrow.x + j * Math.cos(rayAngle), arrow.y + j * Math.sin(rayAngle));
					} else {
						// or drawing if it's not the first point we find
						lightCanvas.graphics.lineTo(arrow.x + j * Math.cos(rayAngle), arrow.y + j * Math.sin(rayAngle));
					}
				}
				lightCanvas.graphics.endFill();
			}
			// checking the collision with the goal;
			var arrowToGoalX:Number = arrow.x - goal.x;
			var arrowToGoalY:Number = arrow.y - goal.y;
			// 1296 = (arrow.radius + 20 (goal radius))^2
			if (arrowToGoalX * arrowToGoalX + arrowToGoalY * arrowToGoalY < (arrow.radius + 20) * (arrow.radius + 20)) { // 20 = goal radius
				// great! you won!
				winGame();
			}
		}
		
		private function collectLightIfAppropriate():void {
			var arrowToLightX:Number = arrow.x - light.x;
			var arrowToLightY:Number = arrow.y - light.y;
			if (arrowToLightX * arrowToLightX + arrowToLightY * arrowToLightY < (arrow.radius + 10) * (arrow.radius + 10)) //10 = light radius
				pickupLight();
		}
		
		private function pickupLight():void {
			hasCollectedLight = true;
			removeChild(light);
		}
		
		private function closestCollision(radarPrecision:Number, raycastStepSize:Number, collisionDistance:Number):Number {
			var returnMe:Number = collisionDistance;
			for (var i:Number = 0; i <= radarPrecision; i++) {
				var rayAngle:Number = 2 * Math.PI / radarPrecision * i;
				returnMe = Math.min(returnMe, findNearestSurface(raycastStepSize, collisionDistance, rayAngle));
			}
			return returnMe;
		}
		
		// should be on arrow?
		private function findNearestSurface(raycastStepSize:Number, collisionDistance:Number, rayAngle:Number):Number {
			for (var j:Number = arrow.radius; j <= collisionDistance + arrow.radius; j += raycastStepSize)
				if (level.hitTestPoint(arrow.x + j * Math.cos(rayAngle), arrow.y + j * Math.sin(rayAngle), true))
					return j - arrow.radius
			return Number.MAX_VALUE;
		}
		
		private function mouseReleased(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
		}
		
		private function update(e:Event):void {
			flickerLight();
			recordMousePosition();
			playMousePosition();
		}
		
		private function movementDistance():Point {
			return new Point(mouseX - mousePositionOnClick.x, mouseY - mousePositionOnClick.y);
		}
		
		private function flickerLight():void {
			lightCanvas.alpha = 0.5 + Math.random() * 0.5;
		}
		
		private function recordMousePosition():void {
			if (shouldRecordMouse)
				mouseMovementRecord.push(new Point(arrow.x, arrow.y));
		}
		
		private function playMousePosition():void {
			if (shouldPlayMouse) {
				var currentPoint:Point = mouseMovementRecord.shift();
				arrow.moveTo(currentPoint);
				if (mouseMovementRecord.length == 0)
					removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		private function loseGame():void {
			endGame();
		}
		
		private function winGame():void {
			endGame();
		}
		
		private function endGame():void {
			mouseMovementRecord.push(new Point(arrow.x, arrow.y));
			level.visible = true;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			removeChild(lightCanvas);
			radar.removeChild();
			shouldRecordMouse = false;
			shouldPlayMouse = true;
		}
	}
}