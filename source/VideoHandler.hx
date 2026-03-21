#if FEATURE_MP4
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import video.FunkinVideoSprite;
import openfl.events.KeyboardEvent;

class VideoHandler extends FunkinVideoSprite
{
	public var canSkip:Bool = false;
	public var skipKeys:Array<FlxKey> = [];

	public function new():Void
	{
		super();

		bitmap.onEndReached.add(function()
		{
		    this.destroy();
		});
	}

	override public function play():Bool
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.mouse.visible = false;
		FlxG.sound.music.stop();

		return bitmap != null ? bitmap.play() : false;
	}

	override public function destroy():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.mouse.visible = true;
		super.destroy();
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		if (!canSkip)
			return;

		if (skipKeys.contains(event.keyCode))
		{
			canSkip = false;
			bitmap.onEndReached.dispatch();
		}
	}
}
#end
