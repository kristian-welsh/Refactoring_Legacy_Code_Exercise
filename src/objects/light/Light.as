package src.objects.light{
	import flash.display.*;
	import flash.geom.Point;
	import src.objects.Globe;
	
	/** @author Kristian Welsh */
	public class Light extends Globe implements ILight {
		public function Light(container:DisplayObjectContainer) {
			super(container, LightGraphics, new Point(50, 200));
		}
		
		public function destroy():void {
			graphics.parent.removeChild(graphics);
		}
	}
}