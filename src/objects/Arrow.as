package src.objects {
	import flash.display.*;
	import flash.geom.Point;
	/** @author Kristian Welsh */
	public class Arrow extends Globe {
		public function Arrow(container:DisplayObjectContainer):void {
			super(container, ArrowGraphics, new Point(40, 40));
		}
		
		public function moveBy(movementDistance:Point):void {
			graphics.x = x + movementDistance.x;
			graphics.y = y + movementDistance.y;
		}
		
		public function moveTo(newPosition:Point):void {
			graphics.x = newPosition.x;
			graphics.y = newPosition.y;
		}
		
		public function findNearestPointOnLevel(raycastStepSize:Number, collisionDistance:Number, rayAngle:Number, level:Level):Number {
			for (var j:Number = radius; j <= collisionDistance + radius; j += raycastStepSize)
				if (raycastCollidingWithLevel(j, rayAngle, level))
					return j - radius;
			return Number.MAX_VALUE;
		}
		
		public function raycastCollidingWithLevel(rayDistance:Number, rayAngle:Number, level:Level):Boolean {
			return level.hitTestPoint(x + rayDistance * Math.cos(rayAngle), y + rayDistance * Math.sin(rayAngle));
		}
	}
}