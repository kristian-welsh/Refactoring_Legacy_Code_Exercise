package src.objects {
	import flash.display.*;
	import flash.geom.Point;
	
	/** @author Kristian Welsh */
	public class Arrow extends Globe {
		private static const RAYCAST_DISTANCE_STEP_SIZE:uint = 1;
		static private const COLLISION_SEARCH_RADIUS:Number = 100;
		
		private var lastMousePosition:Point = new Point(0, 0);
		
		private var _mouseMovementRecord:Vector.<Point> = new Vector.<Point>();
		
		public function Arrow(container:DisplayObjectContainer):void {
			super(container, ArrowGraphics, new Point(40, 40));
		}
		
		private function moveBy(movementDistance:Point):void {
			graphics.x = x + movementDistance.x;
			graphics.y = y + movementDistance.y;
		}
		
		private function moveTo(newPosition:Point):void {
			graphics.x = newPosition.x;
			graphics.y = newPosition.y;
		}
		
		public function findNearestPointOnLevelAlongVector(rayAngle:Number, level:Level):Number {
			for (var distanceStep:uint = radius; distanceStep <= COLLISION_SEARCH_RADIUS + radius; distanceStep += RAYCAST_DISTANCE_STEP_SIZE)
				if (isCollidingWithLevel(distanceStep, rayAngle, level))
					return distanceStep;
			return distanceStep;
		}
		
		private function isCollidingWithLevel(raycastDistance:Number, raycastAngle:Number, level:Level):Boolean {
			var pos = positionAtSurfaceNormalVectorEnd(raycastAngle, raycastDistance);
			return level.hitTestPoint(pos.x,  pos.y);
		}
		
		public function positionAtSurfaceNormalVectorEnd(angle:Number, distance:Number):Point {
			return new Point(x + distance * Math.cos(angle), y + distance * Math.sin(angle));
		}
		
		public function move(mouseX:Number, mouseY:Number):void {
			moveBy(movementDistance(mouseX, mouseY));
			saveCurrentMousePosition(mouseX, mouseY);
		}
		
		private function movementDistance(mouseX:Number, mouseY:Number):Point {
			return new Point(mouseX - lastMousePosition.x, mouseY - lastMousePosition.y);
		}
		
		public function saveCurrentMousePosition(mouseX:Number, mouseY:Number):void {
			lastMousePosition = new Point(mouseX, mouseY);
		}
		
		public function recordMousePosition():void {
			mouseMovementRecord.push(new Point(x, y));
		}
		
		public function advanceAlongRecording():void {
			moveTo(mouseMovementRecord.shift());
		}
		
		public function get mouseMovementRecord():Vector.<Point> {
			return _mouseMovementRecord;
		}
		
		public function get finishedRecording():Boolean {
			return _mouseMovementRecord.length == 0;
		}
	}
}