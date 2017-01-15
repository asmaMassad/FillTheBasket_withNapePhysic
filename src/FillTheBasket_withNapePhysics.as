package
{
	import flash.display.Sprite;
	
	import starling.core.Starling;
	[SWF(width="800",height="600",frameRate="120", backgroundColor="#303030")]
	public class FillTheBasket_withNapePhysics extends Sprite
	{
		private var _starling:Starling;
		public function FillTheBasket_withNapePhysics()
		{
			_starling = new Starling(Game, stage, null, null, "auto", "baseline");
			_starling.start();
		}
	}
}