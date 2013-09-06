package src {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import src.objects.Arrow;
	
	/** @author Kristian Welsh */
	public class Replayer {
		private static const ONE_SECCOND:Number = 1000;
		private static const FRAME_RATE:uint = 120;
		
		private var arrow:Arrow;
		private var timer:Timer = new Timer(ONE_SECCOND / FRAME_RATE);
		
		public function replay(arrow_:Arrow):void {
			arrow = arrow_;
			arrow.recordMousePosition();
			timer.addEventListener(TimerEvent.TIMER, playFrame);
			timer.start();
		}
		
		private function playFrame(event:TimerEvent):void {
			arrow.advanceAlongRecording();
			if (arrow.finishedRecording)
				timer.removeEventListener(TimerEvent.TIMER, playFrame);
		}
	}
}