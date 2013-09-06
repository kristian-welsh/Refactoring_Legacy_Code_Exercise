package src {
	import src.objects.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class Main extends Sprite {
		private static const RAYCAST_DISTANCE_STEP_SIZE:Number = 1;
		
		private var arrow:Arrow;
		private var radar:Radar;
		private var level:Level;
		private var light:Light;
		private var goal:Goal;
		// displays the light
		private var lightCanvas:Sprite = new Sprite();
		
		private var mousePositionOnClick:Point;
		
		private var shouldPlayMouse:Boolean = false;
		private var hasCollectedLight:Boolean = false;
		private var shouldRecordMouse:Boolean = false;
		
		private var mouseMovementRecord:Vector.<Point> = new Vector.<Point>();
		
		public function Main() {
			arrow = new Arrow(this)
			level = new Level(this);
			radar = new Radar(this);
			light = new Light(this);
			addChild(lightCanvas);
			goal = new Goal(this);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function startDrawing(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			
			saveCurrentMousePosition();
			level.hide();
			shouldRecordMouse = true;
		}
		
		private function mouseMoved(e:MouseEvent):void {
			arrow.moveBy(movementDistance());
			saveCurrentMousePosition();
			winGameIfAppropriate();
			var distanceFromCollision:Number = distanceFromClosestCollision(20, RAYCAST_DISTANCE_STEP_SIZE, 50);
			loseGameIfAppropriate(distanceFromCollision);
			renderFrame(distanceFromCollision);
		}
		
		private function movementDistance():Point {
			return new Point(mouseX - mousePositionOnClick.x, mouseY - mousePositionOnClick.y);
		}
		
		private function saveCurrentMousePosition():void {
			mousePositionOnClick = new Point(mouseX, mouseY);
		}
		
		private function distanceFromClosestCollision(raycastAngleStepSize:Number, raycastDistanceStepSize:Number, maxDistanceFromCollision:Number):Number {
			var returnMe:Number = maxDistanceFromCollision;
			for (var i:Number = 0; i <= raycastAngleStepSize; i++) {
				var rayAngle:Number = 2 * Math.PI / raycastAngleStepSize * i;
				returnMe = Math.min(returnMe, findNearestSurface(raycastDistanceStepSize, maxDistanceFromCollision, rayAngle));
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
				
				for (var j:uint = 16; j <= 116; j += RAYCAST_DISTANCE_STEP_SIZE)
					if (playerRaycastCollidingWithLevel(j, rayAngle))
						break;
				
				if (i == 0)
					moveGraphicsPen(rayAngle, j);
				else
					drawGraphicsPen(rayAngle, j);
			}
			lightCanvas.graphics.endFill();
		}
		
		private function moveGraphicsPen(rayAngle:Number, rayDistance:Number):void {
			lightCanvas.graphics.moveTo(arrow.x + rayDistance * Math.cos(rayAngle), arrow.y + rayDistance * Math.sin(rayAngle));
		}
		
		private function drawGraphicsPen(rayAngle:Number, rayDistance:Number):void {
			lightCanvas.graphics.lineTo(arrow.x + rayDistance * Math.cos(rayAngle), arrow.y + rayDistance * Math.sin(rayAngle));
		}
		
		private function winGameIfAppropriate():void {
			if (arrow.isTouchingGlobe(goal))
				winGame();
		}
		
		private function collectLightIfTouchingIt():void {
			if (arrow.isTouchingGlobe(light))
				pickupLight();
		}
		
		private function pickupLight():void {
			hasCollectedLight = true;
			light.removeChild();
		}
		
		// should be on arrow?
		private function findNearestSurface(raycastStepSize:Number, collisionDistance:Number, rayAngle:Number):Number {
			for (var j:Number = arrow.radius; j <= collisionDistance + arrow.radius; j += raycastStepSize)
				if (playerRaycastCollidingWithLevel(j, rayAngle))
					return j - arrow.radius;
			return Number.MAX_VALUE;
		}
		
		private function playerRaycastCollidingWithLevel(rayDistance:Number, rayAngle:Number):Boolean {
			return level.hitTestPoint(arrow.x + rayDistance * Math.cos(rayAngle), arrow.y + rayDistance * Math.sin(rayAngle));
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
			level.show()
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
		
		private function renderFrame(radarSize:Number):void {
			radar.size = radarSize;
			if (!hasCollectedLight)
				collectLightIfTouchingIt();
			else
				drawLight();
		}
	}
}