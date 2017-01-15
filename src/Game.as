package
{
	
	import com.greensock.TweenMax;
	
	import flash.geom.Point;
	import flash.media.SoundTransform;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	
	import screens.Assets;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	public class Game extends Sprite
	{
		private var space:Space;
		private var Debugg:BitmapDebug;
		private var fruitParticles:int=0;
		private var fruit:Body;
		private var drawing:Boolean;
		private var canvas:starling.display.Shape = new starling.display.Shape();
		private var pointsArray:Array;
		private var savedX:Number;
		private var savedY:Number;
		private var pixelDist:int=20;
		private var drawingQuad:Quad;
		
		private var basketIntListener:InteractionListener;
		private var basketCType:CbType=new CbType();
		private var fruitCollisionType:CbType=new CbType();
		
		private var MaxNumOfParticles:int = 100;
		private var collisionCounter:int = 0;
		private var basketCapacityText:TextField ;
		public function Game()
		{
			space = new Space(new Vec2(0,60));	
			
			Debugg = new BitmapDebug(Starling.current.nativeStage.stageWidth,Starling.current.nativeStage.stageHeight,358888, true);
			Starling.current.nativeStage.stage.addChild(Debugg.display);
			Debugg.drawConstraints = true;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		//-----------------------------------------------------------------
		private function onAddedToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			drawLevel();
		}
		
		//-------------------------
		private function drawLevel():void
		{
			drawingQuad= new Quad(800, 600,0xffffff);
			addChild(drawingQuad);
			drawingQuad.alpha = 0;
			
			addChild(canvas);
			canvas.touchable = false;
			canvas.graphics.lineStyle(3, 0x26ff00);
			drawingQuad.addEventListener(TouchEvent.TOUCH, onTouch);
			
			basketIntListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION, fruitCollisionType,basketCType,removeBall);
			space.listeners.add(basketIntListener);
			
			createWalls();
			createBasket();
			
			startGame();
		}
		//===================
		public function startGame():void
		{
			addEventListener(Event.ENTER_FRAME,updateWorld);
			TweenMax.delayedCall(1,spawnFruits);
			
		}
		//------------------------------------------------
		private function createWalls():void
		{
			var xs:Array=[0,790,0,0];
			var ys:Array=[0,0,0,590];
			var ws:Array=[10,10,800,800];
			var hs:Array=[600,600,10,10];
			
			var wallSegBody:Body;
			var wallSegShape:nape.shape.Shape;
			
			for(var i:int=0;i<4;i++)
			{
				wallSegBody = new Body(BodyType.STATIC);
				wallSegShape =new Polygon(Polygon.rect(xs[i], ys[i] , ws[i] , hs[i]));
				wallSegBody.shapes.add(wallSegShape);
				wallSegBody.space = space;
			}
				
		}
		//---------------------------------
		private function createBasket( ):void
		{
			var basketTopBody:Body = new Body(BodyType.STATIC);
			var basketTopShape:nape.shape.Shape;
			var basketBody:Body = new Body(BodyType.STATIC);
			var basketShape:nape.shape.Shape;
			
			
			basketTopShape = new Polygon(Polygon.rect(558,530, 108 , 10));
			basketShape = new Polygon(Polygon.rect(572, 540 , 80 , 50));
			
			basketTopBody.cbTypes.add(basketCType);
			
			
			basketTopBody.shapes.add(basketTopShape);
			basketTopBody.space = space;
			
			basketBody.shapes.add(basketShape);
			basketBody.space = space;
			
			//creating text for basket capacity
			basketCapacityText = new TextField(100, 50, "0%");
			
			basketCapacityText.hAlign = "center";
			basketCapacityText.fontSize = 18;
			basketCapacityText.vAlign = "center";
			basketCapacityText.touchable = false;
			basketCapacityText.x = 570;
			basketCapacityText.y = 545;
			basketCapacityText.color = 0xd0ff00;
			addChild(basketCapacityText);
			
			
		}
		//------------------------------------------
		private function spawnFruits():void
		{
			if (fruitParticles< MaxNumOfParticles) 
			{
				createFruit(30+Math.random()*6, 114);
			}
			
			TweenMax.delayedCall(0.3,spawnFruits);
		}
		//--------------------------------------------
		private function createFruit(_x:Number, _y:Number):void
		{
			fruitParticles++;
			
			fruit = new Body(BodyType.DYNAMIC, new Vec2(_x, _y));
			fruit.mass = 5000;
			fruit.shapes.add(new Circle(5,null, new Material(-1.0,2,2)));//,1.6,5.0)));
			fruit.cbTypes.add(fruitCollisionType);
			fruit.space=space;
			
		}
		//=========================================================================================
		private function onTouch(e:TouchEvent):void
		{
			var touchDown:Touch=e.getTouch(drawingQuad,TouchPhase.BEGAN); 	
			var touchMove:Touch=e.getTouch(drawingQuad,TouchPhase.MOVED);
			var touchUp:Touch=e.getTouch(drawingQuad,TouchPhase.ENDED); 	
			var touch:Touch = e.getTouch(drawingQuad);
			var position:Point;
			if(e.target == drawingQuad)
			{
				//position = touch.getLocation(this);
			}
			if(touchDown)
			{
				position = touch.getLocation(this);
				drawing=true;
				
				canvas.graphics.moveTo(position.x, position.y); 
				//canvas.graphics.curveTo(175, 125, 200, 200);
				
				pointsArray=new Array();
				savedX=position.x;
				savedY=position.y;
				pointsArray.push(savedX);
				pointsArray.push(savedY);
			}
			else if(touchMove)
			{
				if (drawing) 
				{
					if(e.target == drawingQuad)
					{
						position = touch.getLocation(this);
						var distX:int=position.x-savedX;
						var distY:int=position.y-savedY;
						if ((distX*distX+distY*distY)>pixelDist*pixelDist) 
						{
							canvas.graphics.lineTo(position.x,position.y);
							savedX=position.x;
							savedY=position.y;
							pointsArray.push(savedX);
							pointsArray.push(savedY);
						}
					}
				}
			}
			else if(touchUp)
			{
				drawing=false;
				var sx:int;
				var ex:int;
				var sy:int;
				var ey:int;
				var distX2:int;
				var distY2:int;
				var dist:Number;
				var angle:Number;
				var segments:int=pointsArray.length/2-1;
				for (var i:int=0; i<segments; i++) 
				{
					sx=pointsArray[i*2];
					sy=pointsArray[i*2+1];
					ex=pointsArray[i*2+2];
					ey=pointsArray[i*2+3];
					distX2=sx-ex;
					distY2=sy-ey;
					dist=Math.sqrt(distX2*distX2+distY2*distY2);
					angle=Math.atan2(distY2,distX2);
					addPath((sx+ex)/2,(sy+ey)/2,Math.abs(dist),4,angle);
				}
				//canvas.graphics.clear();
				canvas.graphics.lineStyle(3, 0x26ff00);
			}
			//var mg:Quad = new Quad ( 10,100,0)
			
		}
		//------------------------------------------------
		private function addPath(pX:Number,pY:Number,w:Number,h:Number,angle:Number):void 
		{
			var napeBody:Body=new Body(BodyType.STATIC,new Vec2(pX,pY));
			var polygon:Polygon=new Polygon(Polygon.box(w,h));
			polygon.rotate(angle);
			polygon.material.elasticity=0;
			polygon.material.density=1;
			polygon.material.staticFriction=2;
			napeBody.shapes.add(polygon);
			//napeBody.scaleShapes(Main.STAGE_SCALE_RATIO,Main.STAGE_SCALE_RATIO);
			napeBody.space=space;
		}
	
		//--------------------------------------------------------------------------------------
		private function removeBall(collision:InteractionCallback):void 
		{
			collisionCounter++;
			if(collisionCounter <= 50)
			{
				updateText(collisionCounter);
				var ball:Body = collision.int1 as Body;
				space.bodies.remove(ball);
				removeChild(ball.userData.sprite);
			}
			else
			{
				space.listeners.remove(basketIntListener);
				basketIntListener = null
			}
			
		}
		//----------------------------------------------
		private function updateText(percentage:int):void 
		{
			var str:String = (percentage*2).toString()+"%";
			basketCapacityText.text = str;
		}
		//-----------------------------------------
		private function updateWorld(event:Event):void
		{
			space.step(1/60);	
			Debugg.clear();
			Debugg.draw(space);
			Debugg.flush();
			
			var bodies:BodyList=space.bodies;
			var body:Body;
			for (var i:int = 0; i < bodies.length; i++) {
				body =bodies.at(i);
				if(body.userData.sprite!=null){
					body.userData.sprite.x=body.position.x;
					body.userData.sprite.y=body.position.y;
				}
			}
		}
	}
}