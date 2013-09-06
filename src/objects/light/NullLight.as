package src.objects.light {
	
	/** @author Kristian Welsh */
	public class NullLight implements ILight {
		public function NullLight() {
			
		}
		
		public function destroy():void {
			
		}
		
		public function get radius():Number {
			return 0;
		}
		
		public function get x():Number {
			return 0;
		}
		
		public function get y():Number {
			return 0;
		}
	}
}