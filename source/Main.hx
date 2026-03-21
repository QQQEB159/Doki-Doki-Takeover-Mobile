package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;

#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class Main extends Sprite
{
	var game:FlxGame;
	var gameWidth:Int = 1280; // Width of the game in pixels
	var gameHeight:Int = 720; // Height of the game in pixels
	var initialState:Class<FlxState> = Init; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsVar:FPSCounter;
	public static var tongue:FireTongueEx;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}

	public function new()
	{
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		CrashHandler.init();
		
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		// Run this first so we can see logs.
		Debug.onInitProgram();

		#if linux
		startFullscreen = isSteamDeck();
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		FlxG.game.addChild(fpsVar);

		if (fpsVar != null)
			fpsVar.visible = SaveData.showFPS;

		#if mobile
		lime.system.System.allowScreenTimeout = SaveData.screensaver;
		#if android
		FlxG.android.preventDefaultKeys = [BACK]; 
		#end
		#end
		
		// Finish up loading debug tools.
		// NOTE: Causes Hashlink to crash, so it's disabled.
		#if !hl
		Debug.onGameStart();
		#end
	}

	inline public static function isSteamDeck():Bool
	{
		#if linux
		return Sys.environment()["USER"] == "deck";
		#else
		return false;
		#end
	}

	inline public static function alertPopup(desc:String, title:String = 'Error!')
	{
		Application.current.window.alert(desc, title);
	}
}
