package src.lightcanvas {
	import src.objects.Arrow;
	import src.objects.Level;
	
	/** @author Kristian Welsh */
	public class NullLightCanvas implements ILightCanvas {
		public static const nullLightCanvas:NullLightCanvas = new NullLightCanvas();
		
		public function drawLight(arrow:Arrow, level:Level):void {
			
		}
		
		public function flicker():void {
			
		}
		
		public function removeChild():void {
			
		}
	}
}