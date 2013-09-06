package src.objects{
	import flash.display.*;
	
	/** @author Kristian Welsh */
	public class Light implements IGlobe {
		private var graphics:MovieClip;
		
		public function Light(container:DisplayObjectContainer) {
			graphics = new LightGraphics();
			container.addChild(graphics);
			graphics.x = 50;
			graphics.y = 200;
		}
		
		public function get x():Number {
			return graphics.x;
		}
		
		public function get y():Number {
			return graphics.y;
		}
		
		public function get radius():Number {
			return graphics.width/2;
		}
		
		public function removeChild():void {
			graphics.parent.removeChild(graphics);
		}
	}
}