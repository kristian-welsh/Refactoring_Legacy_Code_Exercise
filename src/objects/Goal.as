package src.objects {
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	/** @author Kristian Welsh */
	public class Goal extends Globe {
		public function Goal(container:DisplayObjectContainer) {
			super(container, GoalGraphics, new Point(600, 240));
		}
	}
}