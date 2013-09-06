package src.objects{
	import flash.display.*;
	import flash.geom.Point;
	
	/** @author Kristian Welsh */
	public class Light extends Globe {
		public function Light(container:DisplayObjectContainer) {
			super(container, LightGraphics, new Point(50, 200));
		}
		
		public function removeChild():void {
			graphics.parent.removeChild(graphics);
		}
	}
}