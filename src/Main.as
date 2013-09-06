package src {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import src.lightcanvas.*;
	import src.objects.*;
	import src.objects.light.*;
	
	// TODO: create a raycaster that handles raycasting things for other objects
	public class Main extends Sprite {
		private static const RAYCAST_DISTANCE_STEP_SIZE:Number = 1;
		
		private var arrow:Arrow;
		private var radar:Radar;
		private var level:Level;
		private var light:ILight;
		private var goal:Goal;
		private var lightCanvas:ILightCanvas = NullLightCanvas.nullLightCanvas;
		
		private var hasCollectedLight:Boolean = false;
		
		public function Main() {
			arrow = new Arrow(this)
			level = new Level(this);
			radar = new Radar(this);
			light = new Light(this);
			goal = new Goal(this);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
		}
		
		private function startDrawing(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			addEventListener(Event.ENTER_FRAME, update);
			
			arrow.saveCurrentMousePosition(mouseX, mouseY);
			level.hide();
		}
		
		private function mouseMoved(e:MouseEvent):void {
			arrow.move(mouseX, mouseY);
			conditionallyEndGame();
			collectLightIfArrowTouchingLight();
			renderFrame(distanceFromCollision());
		}
		
		private function conditionallyEndGame():void {
			loseGameIfColliding();
			winGameIfArrowTouchingGoal();
		}
		
		private function loseGameIfColliding():void {
			if (distanceFromCollision() < 1)
				loseGame();
		}
		
		private function loseGame():void {
			endGame();
		}
		
		private function endGame():void {
			removeMouseListeners();
			removeEventListener(Event.ENTER_FRAME, update);
			setEndGraphics();
			new Replayer().replay(arrow);
		}
		
		private function removeMouseListeners():void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseReleased);
		}
		
		private function setEndGraphics():void {
			level.show();
			lightCanvas.removeChild();
			radar.removeChild();
		}
		
		private function winGameIfArrowTouchingGoal():void {
			if (arrow.isTouching(goal))
				winGame();
		}
		
		private function winGame():void {
			endGame();
		}
		
		private function distanceFromCollision():Number {
			return distanceFromClosestCollision(20, RAYCAST_DISTANCE_STEP_SIZE, 50);
		}
		
		private function distanceFromClosestCollision(angleStepSize:Number, distanceStepSize:Number, maxDistance:Number):Number {
			var returnMe:Number = maxDistance;
			for (var i:Number = 0; i <= angleStepSize; i++) {
				var rayAngle:Number = 2 * Math.PI / angleStepSize * i;
				var rayDistance:Number = arrow.findNearestPointOnLevelAlongVector(rayAngle, level);
				returnMe = Math.min(returnMe, rayDistance - arrow.radius);
			}
			return returnMe;
		}
		
		private function collectLightIfArrowTouchingLight():void {
			if (arrow.isTouching(light))
				pickupLight();
		}
		
		private function pickupLight():void {
			light.destroy();
			light = new NullLight();
			lightCanvas = new LightCanvas(this);
		}
		
		private function renderFrame(radarSize:Number):void {
			radar.size = radarSize;
			lightCanvas.drawLight(arrow, level)
		}
		
		private function mouseReleased(e:MouseEvent):void {
			removeMouseListeners();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
		}
		
		private function update(e:Event):void {
			lightCanvas.flicker();
			arrow.recordMousePosition();
		}
	}
}