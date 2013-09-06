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
	}
}