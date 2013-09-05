package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.events.Event;
	public class Main extends Sprite {
		// Arrow is the name class you can find in the library containing the arrow image
		private var arrow:Arrow=new Arrow();
		// mousePoint is the actual point we are moving the mouse on
		private var mousePoint:Point;
		// Level is the name of the class you can find in the library storing levels
		private var level:Level=new Level();
		// Radar is the name of the class you can find in the library storing radar image
		private var radar:Radar=new Radar();
		// Light is the name of the class you can find in the librart storing light image
		private var light:Light=new Light();
		// Goal is the name of the class you can find in the librart storing goal image
		private var goal:Goal=new Goal();
		// lightCanvas is the sprite where we'll display the light
		private var lightCanvas:Sprite=new Sprite();
		// Boolean variable to see if we collected the light
		private var hasLight:Boolean=false;
		// vector to store all mouse movements
		private var mouseVector:Vector.<Point>=new Vector.<Point>();
		// Boolean variable to tell us if we shoud record mouse movements
		private var recordMouse:Boolean=false;
		// Boolean variable to tell us if we shoud play mouse movements
		private var playMouse:Boolean=false;
		public function Main() {
			// adding the arrow in the upper left corner of the stage
			addChild(arrow);
			arrow.x=40;
			arrow.y=40;
			// adding the level to stage
			addChild(level);
			// adding the radar in the upper right corner of the stage
			addChild(radar);
			radar.x=600;
			radar.y=40;
			// placing the light in the middle of the stage
			addChild(light);
			light.x=320;
			light.y=240;
			// adding light canvas
			addChild(lightCanvas);
			// placing the goal in the right end of the stage
			addChild(goal);
			goal.x=600;
			goal.y=240;
			// at this time we only have to wait for the player to press the mouse button
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mousePressed);
			// a listener to give a flickering effect to the light and record mouse movements
			addEventListener(Event.ENTER_FRAME,update);
		}
		private function mousePressed(e:MouseEvent):void {
			// the player pressed the mouse so we can start drawing - we don't need to wait for the player to press the mouse
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,mousePressed);
			// now we must wait for the player to move or release mouse button
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseReleased);
			// saving mouse position
			mousePoint=new Point(mouseX,mouseY);
			// hiding the level;
			level.visible=false;
			// let's start recording mouse movements
			recordMouse=true;
		}
		private function mouseMoved(e:MouseEvent):void {
			var dx:Number=mouseX-mousePoint.x;
			var dy:Number=mouseY-mousePoint.y;
			// moving arrow Sprite according to such distances
			arrow.x+=dx;
			arrow.y+=dy;
			// saving current mouse position;
			mousePoint.x=mouseX;
			mousePoint.y=mouseY;
			// a couple of temporary variables
			var rayAngle:Number;
			// precision is the... precision of the radar system. I suggest a number which divides 360
			var precision:Number=20;
			// rayStep is the number of steps in pixels the raycast performs to find an obstacle
			var rayStep:Number=1;
			// default minimum distance is 50 pixels
			var minDistance:Number=50;
			// looping and looking for the closest point to the arrow
			for (var i:Number=0; i<=precision; i++) {
				// finding the i-th angle
				rayAngle=2*Math.PI/precision*i;
				// arrow radius is 16px. We are looking for obstacles closer than 50px. So we must see from 16 to 66
				// the bigger rayStep, the faster and less accurate the process
				for (var j:Number=16; j<=66; j+=rayStep) {
					// here we go, looking for obstacles
					if (level.hitTestPoint(arrow.x+j*Math.cos(rayAngle),arrow.y+j*Math.sin(rayAngle),true)) {
						// we found it!!
						minDistance=Math.min(j-16,minDistance);
						break;
					}
				}
			}
			// updating radar size;
			radar.width=minDistance;
			radar.height=minDistance;
			// you hit the wall = game over
			if (minDistance<1) {
				mouseVector.push(new Point(arrow.x,arrow.y));
				level.visible=true;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
				stage.removeEventListener(MouseEvent.MOUSE_UP,mouseReleased);
				removeChild(lightCanvas);
				removeChild(radar);
				recordMouse=false;
				playMouse=true;
			}
			// checking the collision between the arrow and the light, if we still did not pick up the light
			if (! hasLight) {
				var arrowToLightX:Number=arrow.x-light.x;
				var arrowToLightY:Number=arrow.y-light.y;
				// 676 = (16 (arrow radius) + 10 (light radius))^2
				if (arrowToLightX*arrowToLightX+arrowToLightY*arrowToLightY<676) {
					// you got light powerup!!
					hasLight=true;
					removeChild(light);
				}
			}
			else {
				// do you remember the radar? Things are quite similar for the light, we only want more precision
				lightCanvas.graphics.clear();
				lightCanvas.graphics.lineStyle(0,0xffffff,0);
				var mtx:Matrix = new Matrix();
				mtx.createGradientBox(232,232,0,arrow.x-116,arrow.y-116);
				// we are drawing a gradient this time;
				lightCanvas.graphics.beginGradientFill(GradientType.RADIAL,[0xffffff,0xffffff],[0.5,0],[0,255],mtx);
				precision=60;
				for (i=0; i<=precision; i++) {
					rayAngle=2*Math.PI/precision*i;
					for (j=16; j<=116; j+=rayStep) {
						if (level.hitTestPoint(arrow.x+j*Math.cos(rayAngle),arrow.y+j*Math.sin(rayAngle),true)) {
							break;
						}
					}
					if (i==0) {
						// moving the graphic pen if it's the first point we find
						lightCanvas.graphics.moveTo(arrow.x+j*Math.cos(rayAngle), arrow.y+j*Math.sin(rayAngle));
					}
					else {
						// or drawing if it's not the first point we find
						lightCanvas.graphics.lineTo(arrow.x+j*Math.cos(rayAngle), arrow.y+j*Math.sin(rayAngle));
					}
				}
				lightCanvas.graphics.endFill();
			}
			// checking the collision with the goal;
			var arrowToGoalX:Number=arrow.x-goal.x;
			var arrowToGoalY:Number=arrow.y-goal.y;
			// 1296 = (16 (arrow radius) + 20 (goal radius))^2
			if (arrowToGoalX*arrowToGoalX+arrowToGoalY*arrowToGoalY<1296) {
				// great! you won!
				mouseVector.push(new Point(arrow.x,arrow.y));
				level.visible=true;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
				stage.removeEventListener(MouseEvent.MOUSE_UP,mouseReleased);
				removeChild(lightCanvas);
				removeChild(radar);
				recordMouse=false;
				playMouse=true;
			}
		}
		private function mouseReleased(e:MouseEvent):void {
			// the player released the mouse. Stop drawing and let's wait for mouse press
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseReleased);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mousePressed);
		}
		private function update(e:Event):void {
			// just flickering the light
			lightCanvas.alpha=0.5+Math.random()*0.5;
			// recording mouse position
			if (recordMouse) {
				mouseVector.push(new Point(arrow.x,arrow.y));
			}
			// playing mouse position
			if(playMouse){
				var currentPoint:Point=mouseVector.shift();
				arrow.x=currentPoint.x;
				arrow.y=currentPoint.y;
				if(mouseVector.length==0){
					removeEventListener(Event.ENTER_FRAME,update);
					}
			}
		}
	}
}