package src.lightcanvas {
	import flash.display.*;
	import flash.geom.*;
	import src.objects.*;
	
	/** @author Kristian Welsh */
	public class LightCanvas implements ILightCanvas {
		private static const WHITE:uint = 0xFFFFFF;
		private static const FULL_GRADIENT_RATIO:Array = [0, 255];
		private static const LIGHT_PRECISION:Number = 180;//60
		
		private var objectGraphics:Sprite = new Sprite();
		
		public function LightCanvas(container:DisplayObjectContainer) {
			container.addChild(objectGraphics)
		}
		
		public function removeChild():void {
			objectGraphics.parent.removeChild(objectGraphics);
		}
		
		public function drawLight(arrow:Arrow, level:Level):void {
			objectGraphics.graphics.clear();
			beginGradientFill(arrow.x, arrow.y);
			moveGraphicsPen(arrow, 2 * Math.PI, arrow.findNearestPointOnLevelAlongVector(2 * Math.PI, level));
			
			for (var i:uint = 1; i <= LIGHT_PRECISION; i++) {
				var rayAngle:Number = 2 * Math.PI / LIGHT_PRECISION * i;
				var rayDistance = arrow.findNearestPointOnLevelAlongVector(rayAngle, level)
				drawGraphicsPen(arrow, rayAngle, rayDistance);
			}
			
			objectGraphics.graphics.endFill();
		}
		
		private function beginGradientFill(x:Number, y:Number):void {
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(232, 232, 0, x - 116, y - 116);
			objectGraphics.graphics.beginGradientFill(GradientType.RADIAL, [WHITE, WHITE], [0.5, 0], FULL_GRADIENT_RATIO, mtx);
		}
		
		private function moveGraphicsPen(arrow:Arrow, rayAngle:Number, rayDistance:Number):void {
			var pos:Point = arrow.positionAtSurfaceNormalVectorEnd(rayAngle, rayDistance)
			objectGraphics.graphics.moveTo(pos.x, pos.y);
		}
		
		private function drawGraphicsPen(arrow:Arrow, rayAngle:Number, rayDistance:Number):void {
			var pos:Point = arrow.positionAtSurfaceNormalVectorEnd(rayAngle, rayDistance)
			objectGraphics.graphics.lineTo(pos.x, pos.y);
		}
		
		public function flicker():void {
			objectGraphics.alpha = 0.5 + Math.random() * 0.5;
		}
	}
}