package {
	import flash.display.*;
	import flash.geom.Point;
	/** @author Kristian Welsh */
	public class Arrow {
		private var graphics:MovieClip;
		public function Arrow(container:DisplayObjectContainer):void {
			graphics = new ArrowGraphics();
			container.addChild(graphics);
			graphics.x = 40;
			graphics.y = 40;
		}
		
		public function moveBy(movementDistance:Point):void {
			x = x + movementDistance.x;
			y = y + movementDistance.y;
		}
		
		public function moveTo(newPosition:Point):void {
			x = newPosition.x;
			y = newPosition.y;
		}
		
		public function set x(value:Number):void {
			graphics.x = value;
		}
		
		public function set y(value:Number):void {
			graphics.y = value;
		}
		
		public function get x():Number {
			return graphics.x;
		}
		
		public function get y():Number {
			return graphics.y;
		}
		
		public function get radius():Number {
			return 16;
		}
	}
}