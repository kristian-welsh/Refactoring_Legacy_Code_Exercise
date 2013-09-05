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
			
			saveCurrentMousePosition();
			level.visible = false;
			shouldRecordMouse = true;
		}
		
		private function mouseMoved(e:MouseEvent):void {
			arrow.moveBy(movementDistance());
			saveCurrentMousePosition();
			
			var radarPrecision:Number = 20;
			var collisionDistance:Number = 50;
			collisionDistance = closestCollision(radarPrecision, RAYCAST_STEP_SIZE, collisionDistance);
			
			radar.size = collisionDistance;
			
			loseGameIfAppropriate(collisionDistance);
			
			if (!hasCollectedLight)
				collectLightIfAppropriate();
			else
				drawLight();
			
			winGameIfAppropriate();
		}
		
		private function movementDistance():Point {
			return new Point(mouseX - mousePositionOnClick.x, mouseY - mousePositionOnClick.y);
		}
		
		private function saveCurrentMousePosition():void {
			mousePositionOnClick = new Point(mouseX, mouseY);
		}
		
		private function closestCollision(radarPrecision:Number, raycastStepSize:Number, collisionDistance:Number):Number {
			var returnMe:Number = collisionDistance;
			for (var i:Number = 0; i <= radarPrecision; i++) {
				var rayAngle:Number = 2 * Math.PI / radarPrecision * i;
				returnMe = Math.min(returnMe, findNearestSurface(raycastStepSize, collisionDistance, rayAngle));
			}
			return returnMe;
		}
		
		private function loseGameIfAppropriate(collisionDistance:Number):void {
			if (collisionDistance < 1)
				loseGame();
		}
		
		private function drawLight():void {
			lightCanvas.graphics.clear();
			lightCanvas.graphics.lineStyle(0, 0xffffff, 0);
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(232, 232, 0, arrow.x - 116, arrow.y - 116);
			// we are drawing a gradient this time;
			lightCanvas.graphics.beginGradientFill(GradientType.RADIAL, [0xffffff, 0xffffff], [0.5, 0], [0, 255], mtx);
			var radarPrecision:Number = 60;
			for (var i:uint = 0; i <= radarPrecision; i++) {
				var rayAngle:Number = 2 * Math.PI / radarPrecision * i;
				for (var j:uint = 16; j <= 116; j += RAYCAST_STEP_SIZE) {
					if (level.hitTestPoint(arrow.x + j * Math.cos(rayAngle), arrow.y + j * Math.sin(rayAngle), true)) {
						break;
					}
				}
				if (i == 0) {
					moveGraphicsPen(rayAngle, j);
				} else {
					drawGraphicsPen(rayAngle, j);
				}
			}
			lightCanvas.graphics.endFill();
		}
		
		private function moveGraphicsPen(rayAngle:Number, j:Number):void {
			lightCanvas.graphics.moveTo(arrow.x + j * Math.cos(rayAngle), arrow.y + j * Math.sin(rayAngle));
		}
		
		private function drawGraphicsPen(rayAngle:Number, j:Number):void {
			lightCanvas.graphics.lineTo(arrow.x + j * Math.cos(rayAngle), arrow.y + j * Math.sin(rayAngle));
		}
		
		private function winGameIfAppropriate():void {
			var arrowToGoalX:Number = arrow.x - goal.x;
			var arrowToGoalY:Number = arrow.y - goal.y;
			if (squareOf(arrowToGoalX) + squareOf(arrowToGoalY) < squareOf(arrow.radius + 20)) // 20 = goal radius
				winGame();
		}
		
		private function collectLightIfAppropriate():void {
			var arrowToLightX:Number = arrow.x - light.x;
			var arrowToLightY:Number = arrow.y - light.y;
			if (squareOf(arrowToLightX) + squareOf(arrowToLightY) < squareOf(arrow.radius + 10)) //10 = light radius
				pickupLight();
		}
		
		private function pickupLight():void {
			hasCollectedLight = true;
			removeChild(light);
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
		
		private function squareOf(input:Number):Number {
			return input * input;
		}
	}
}