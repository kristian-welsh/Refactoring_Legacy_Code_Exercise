package {
	import flash.display.*;
	
	/** @author Kristian Welsh */
	public class Radar {
		private var graphics:MovieClip;
		public function Radar(container:DisplayObjectContainer):void {
			graphics = new RadarGraphics();
			container.addChild(graphics);
			graphics.x = 600;
			graphics.y = 40;
		}
		
		public function removeChild():void {
			graphics.parent.removeChild(graphics);
		}
		
		public function set size(value:Number):void {
			graphics.width = value;
			graphics.height = value;
		}
	}
}