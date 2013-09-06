package src.lightcanvas {
	import src.objects.Arrow;
	import src.objects.Level;
	
	/** @author Kristian Welsh */
	public interface ILightCanvas {
		function drawLight(arrow:Arrow, level:Level):void
		function flicker():void
		function removeChild():void
	}
	
}