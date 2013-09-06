package src.objects {
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/** @author Kristian Welsh */
	public class Globe implements IGlobe {
		protected var graphics:MovieClip;
		
		public function Globe(container:DisplayObjectContainer, graphicsClass:Class, position:Point) {
			graphics = new graphicsClass();
			container.addChild(graphics);
			graphics.x = position.x;
			graphics.y = position.y;
		}
		
		public function get x():Number {
			return graphics.x;
		}
		
		public function get y():Number {
			return graphics.y;
		}
		
		public function get radius():Number {
			return graphics.width / 2;
		}
		
		private function pythagDistanceTo(target:IPositioned):Number {
			return squareOf(x - target.x) + squareOf(y - target.y);
		}
		
		private function squareOf(input:Number):Number {
			return input * input;
		}
		
		public function isTouching(object:IGlobe):Boolean {
			return (pythagDistanceTo(object) < squareOf(radius + object.radius));
		}
	}
}