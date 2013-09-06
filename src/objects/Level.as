package src.objects{
	import flash.display.*;
	
	/** @author Kristian Welsh */
	public class Level {
		private var graphics:MovieClip;
		
		public function Level(container:DisplayObjectContainer) {
			graphics = new LevelGraphics();
			container.addChild(graphics);
		}
		
		public function show():void {
			graphics.visible = true;
		}
		
		public function hide():void {
			graphics.visible = false;
		}
		
		public function hitTestPoint(x:Number, y:Number):Boolean {
			return graphics.hitTestPoint(x, y, true)
		}
	}
}