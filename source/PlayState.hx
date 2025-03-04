// sexy code -aly ant
package;

#if desktop
import Discord.DiscordClient;
#end
//filxel
import flixel.graphics.FlxGraphic;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.addons.display.FlxTiledSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.effects.FlxFlicker;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
//kinda util
// STOLEN FROM WEDNESDAY'S INFIDELITY SOURCE CODE LMAO
import flxanimate.*;
import flxanimate.FlxAnimate;
//haxe libs
import haxe.Json;
//openfl libs
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
//lime libs
import lime.utils.Assets;
//other stuff
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import editors.ChartingState;
import editors.CharacterEditorState;
import Note.EventNote;
import animateatlas.AtlasFrameMaker; // this kill my phone
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
//system
import sys.FileSystem;
import sys.io.File;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;
	public static var COMBO_X = 544; // unused
	public static var COMBO_Y = 40;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;
	//public var xval:Int = 90;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isCovers:Bool = false;
	public static var isExtras:Bool = false;
	public static var isCode:Bool = false;
	public static var isFreeplay:Bool = false;
	public static var noSkins:Bool = false; // no skins?
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	//public static var endCombo:Bool = false;

	public var vocals:FlxSound;

	// nikku skin
	var skinSelection:Int = ChooseSkinState.curSelected;

	// dad
	public var dad:Character = null;
	public var dadReflect:Character = null; // sexy but unused
	// gf
	public var gf:Character = null; // pensei q a variavel era girlfriend
	public var gfReflect:Character = null; // unused shit
	// bf
	public var boyfriend:Boyfriend = null;
	public var bfThing:Boyfriend = null; // unused shit

	// note stuff
	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];
	var targetOffsetX:Dynamic;
	var targetOffsetX2:Dynamic;

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	// song bar idk
	var songTag:SongBar;

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	var rating:String = "";
	
	var elapsedTime:Float=0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var cutCam:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	// stage variables xd
	var bg10:BGSprite;
	var cutsceneBG:BGSprite;
	var cutsceneEnd:BGSprite;
	var cutsceneLogo:BGSprite;
	var black:FlxSprite;
	var text1:BGSprite; // and yes, this is a image :trollface:
	var text2:BGSprite;

	// fun is infinite
	var majinBG:BGSprite;
	var majinTVBG:BGSprite;
	var majinOverlay:BGSprite;
	var majinTV:BGSprite;
	var majinGround:BGSprite;

	// covers stage
	var coverBG1:BGSprite;
	var coverBG2:BGSprite;
	var coverBG3:BGSprite;
	var coverBG4:BGSprite;
	var coverBG5:BGSprite;
	var coverBG6:BGSprite;
	var coverBG7:BGSprite;
	var coverBG8:BGSprite;
	var coverBG9:BGSprite;

	var bfreflect:FlxSprite = new FlxSprite();
	var dadreflect:FlxSprite = new FlxSprite();
	var gfreflect:FlxSprite = new FlxSprite(); // GOSTOSA AAAA (zoas)

	// expurgated
	var exSky:BGSprite;
	var exRock:BGSprite;
	var exGround:BGSprite;
	var exOverlay:BGSprite;
	var exFront:BGSprite;

	// this is my first time using emitters sorry if i broke something
	var particleEmitter:FlxEmitter;

	// skate
	var skateSky:BGSprite;
	var skateFloor:BGSprite;
	var skateBuildings:BGSprite;
	var skateLight:BGSprite;
	var skateTreess:BGSprite;
	var skateBuches:BGSprite;

	// sonio ponto eze variables
	var gostosa:FlxBackdrop;
	var bgExe:FlxBackdrop;
	var groundExe:FlxBackdrop;
	var nicuEze:FlxSprite;
	var eze:FlxSprite;
	var blackStart:FlxSprite;

	// octagon cutscene variables
	var octagonBG:FlxSprite;
	var octagonBG2:FlxSprite;
	var numbahEiti:FlxBackdrop;
	var numbahEiti2:FlxBackdrop;
	var numbahEiti3:FlxBackdrop;
	var octagon:FlxSprite;
	var textOctagon:FlxSprite;
	var bubbleText:FlxSprite;
	var nikkuOctagon:FlxSprite;
	var showYou:FlxSprite;
	var hereme:FlxSprite;
	var blackStart2:FlxSprite;

	// hauuei
	var hallBG:BGSprite;
	var hallFG:BGSprite;
	var hallLuzinha:BGSprite;

	var fandomaniaCutscene:FlxAnimate; //using texture atlas in android

	// ARMAGEDOM
	var bars:BGSprite;
	var rocks:BGSprite;

	// do stage da gostosa la
	var momogogoBG:FlxBackdrop;

	// da ultima musica la a astral projection
	var matzuBG:BGSprite;
	var matzuDESK:BGSprite;
	var asPlantadaMinhaMae:BGSprite;

	// é quando ta tudo fudido
	var matzuFudida1:BGSprite;
	var matzuFudida2:BGSprite;
	var matzuFudida3:BGSprite;
	var matzuFudida4:BGSprite;
	var matzuFudida5:BGSprite;
	var matzuFudida6:BGSprite;
	var matzuFudida7:BGSprite;

	// ena
	var enaOverlay:BGSprite;
	var idkWhatIsthat:BGSprite;

	// mall da nicu
	var nicuLight:BGSprite;
	var oscabodomeucu:BGSprite;
	var nicuPlants:BGSprite;

	// xigmund
	var planet:BGSprite;
	var planet2:BGSprite;
	var sun:BGSprite;
	var sun2:BGSprite;
	var asteroidEmitter1:FlxEmitter;
	var asteroidEmitter2:FlxEmitter;
	var asteroidEmitter3:FlxEmitter;

	// sus
	var osCaboSUS:BGSprite;

	// nicu vs a turma da monica so que nao
	var naoseiseissoecabomasfds:BGSprite;

	// nightland
	var blurBg:BGSprite;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var deeznut:Int = 0; // just a random thing for the flxg log lmao

	//score stuff
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var lerpScore:Int = 0;
	public var scoreTarget:Int = 0;
	public var lerpScore2:Int = 0;
	public var scoreTarget2:Int = 0;
	public var scoreTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var score:Int = 350;

	//combo stuff
	public var comboGlow:FlxSprite;
	public var combotxtscoreplus:FlxText;
	public var combotxt1:FlxText;
	public var combotxt2:FlxText;
	public var comboScore:Int = 0;
	public var comboNum:Int = 0; // its the fake combo :trollface:
	public var comboState:Int = 0;
	var pressedKey:Bool = false; // unused
	var endCombo:Bool = false; // unused
	var showCombo2:Bool = false; // unused
	var timeTxt:FlxText;
	var comboTwn:FlxTween;
	var comboTwn2:FlxTween;
	var comboTwn3:FlxTween;
	var comboGlowAlphaTwn:FlxTween;
	var comboAlphaTwn:FlxTween;
	var comboAlphaTwn2:FlxTween;
	var comboAlphaTwn3:FlxTween;
	var comboTmr:FlxTimer = new FlxTimer();
	var stopPls:FlxTimer = new FlxTimer();
	var comboTmr2:Float = 3.5; // unused shit

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit	
	var keysPressed:Array<Bool> = [];	
	var boyfriendIdleTime:Float = 0.0;	
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	var precacheList:Map<String, String> = new Map<String, String>();

	override public function create()
	{
		if (ClientPrefs.middleScroll && !ClientPrefs.downScroll){
			COMBO_Y = 160;
		}
		else if (ClientPrefs.middleScroll && ClientPrefs.downScroll){
			COMBO_Y = 475;
		}
		else if (ClientPrefs.downScroll){
			COMBO_Y = 560;
		}

		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement	
		for (i in 0...keysArray.length)	
		{	
			keysPressed.push(false);	
		}	
		FlxG.mouse.visible = false;	
		//FlxG.debugger.visible = true;

		if (FlxG.sound.music != null)	
			FlxG.sound.music.stop();	

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		cutCam = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		cutCam.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(cutCam);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
		
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
					case 'stage': //Week 1
						var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
						add(bg);
		
						var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						add(stageFront);
						if(!ClientPrefs.lowQuality) {
							var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
							stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
							stageLight.updateHitbox();
							add(stageLight);
							var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
							stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
							stageLight.updateHitbox();
							stageLight.flipX = true;
							add(stageLight);
		
							var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
							stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
							stageCurtains.updateHitbox();
							add(stageCurtains);
						}
				case 'space': //they are in the space but, HOW THEY CAN LIVE WITHOUT IN THE EARTH????
					//if(!ClientPrefs.dontShowBG) {
						var bg:BGSprite = new BGSprite('stage3/s1', -1300, -500, 0.2, 0.2);
						bg.scale.set(1.8, 1.8);
						bg.updateHitbox();
						add(bg);
		
						var bg2:BGSprite = new BGSprite('stage3/s2', -1700, -600, 0.3, 0.3);
						bg2.scale.set(1.8, 1.8);
						bg2.updateHitbox();
						add(bg2);
						
						var bg3:BGSprite = new BGSprite('stage3/s3', -1700, -600,0.3,0.3);
						bg3.scale.set(1.8, 1.8);
						bg3.updateHitbox();
						add(bg3);
		
						var bg4:BGSprite = new BGSprite('stage3/s4', -1700, -600, 0.4, 0.4);
						bg4.scale.set(1.8, 1.8);
						bg4.updateHitbox();
						add(bg4);
		
						var bg5:BGSprite = new BGSprite('stage3/s5', -1700, -800, 0.5, 0.5);
						bg5.scale.set(1.8, 1.8);
						bg5.updateHitbox();
						add(bg5);
						
						var bg6:BGSprite = new BGSprite('stage3/s6', -1700, -800,0.6,0.6);
						bg6.scale.set(1.8, 1.8);
						bg6.updateHitbox();
						add(bg6);
		
						var bg7:BGSprite = new BGSprite('stage3/s7', -1700, -800, 0.7, 0.7);
						bg7.scale.set(1.8, 1.8);
						bg7.updateHitbox();
						add(bg7);
		
						var bg8:BGSprite = new BGSprite('stage3/s8', -1950, -950, 1, 1);
						bg8.scale.set(1.8, 1.8);
						bg8.updateHitbox();
						add(bg8);
		
						var bg9:BGSprite = new BGSprite('stage3/s9', -2050, -1050, 1, 1);
						bg9.scale.set(1.8, 1.8);
						bg9.updateHitbox();
						add(bg9);
		
						bg10 = new BGSprite('stage3/s10', -2250, -725, 1, 1);
						bg10.scale.set(1.8, 1.8);
						bg10.updateHitbox();
					//}
						cutsceneBG = new BGSprite('stage3/cutscene/bg', 0,0,0,0);
						cutsceneBG.screenCenter(XY);
						//cutsceneBG.cameras = [cutCam];
						cutsceneBG.alpha = 0;
		
						cutsceneEnd = new BGSprite('stage3/cutscene/bgEnd', 0,0,0,0);
						cutsceneEnd.screenCenter(XY);
						//cutsceneEnd.cameras = [cutCam];
						cutsceneEnd.visible = false;
						
						cutsceneLogo = new BGSprite('stage3/cutscene/logo', 0,0,0,0);
						cutsceneLogo.screenCenter(XY);
						cutsceneLogo.scale.set(1.6, 1.6);
						//cutsceneLogo.cameras = [cutCam];
						cutsceneLogo.alpha = 0;
		
						black = new FlxSprite().makeGraphic(2280, 1920, FlxColor.BLACK);
						black.screenCenter(XY);
						black.scrollFactor.set(0, 0);
						black.visible = false;
						//black.cameras = [cutCam];
						black.scale.set(1.8, 1.8);
		
					  text1 = new BGSprite('stage3/cutscene/text1', 311.6, 294.8, 0, 0);
					  text1.scale.set(1.8, 1.8);
					  text1.screenCenter(XY);
					  //text1.cameras = [cutCam];
						text1.visible = false;
		
						text2 = new BGSprite('stage3/cutscene/text2', 439.4, text1.y + 85, 0, 0);
						text2.scale.set(1.8, 1.8);
						//text2.cameras = [cutCam];
						text2.visible = false;
		
					case 'covers': // covers
						//if(!ClientPrefs.dontShowBG)
							coverBG1 = new BGSprite('covers/bg', -960, -250, 0.1, 0.1);
							coverBG1.scale.set(1.4, 1.2);
							coverBG1.updateHitbox();
							add(coverBG1);
			
							coverBG2 = new BGSprite('covers/sun', -1200, -450, 0.1, 0.1);
							coverBG2.scale.set(1.3, 1.3);
							coverBG2.updateHitbox();
							add(coverBG2);
			
							coverBG9 = new BGSprite('covers/clouds', -1200, 0, 0.1, 0.1);
							coverBG9.updateHitbox();
							add(coverBG9);
			
							coverBG3 = new BGSprite('covers/castle', -1100, -250,  0.3, 0.3);
							coverBG3.scale.set(1.4, 1.2);
							coverBG3.updateHitbox();
							add(coverBG3);
			
							coverBG4 = new BGSprite('covers/buildings', -1000, -150,  0.5, 0.5);
							coverBG4.scale.set(1.4, 1.2);
							coverBG4.updateHitbox();
							add(coverBG4);
			
							coverBG5 = new BGSprite('covers/hills', -600, -150, 1, 1);
							coverBG5.scale.set(1.3, 1.3);
							coverBG5.updateHitbox();
							add(coverBG5);
		
							coverBG6 = new BGSprite('covers/ground', -260, -140, 1, 1);
							coverBG6.scale.set(1.2, 1.2);
							coverBG6.updateHitbox();
							add(coverBG6);
			
							coverBG7 = new BGSprite('covers/light', -260, -140,  1.1, 1.1);
							coverBG7.scale.set(1.2, 1.2);
							coverBG7.updateHitbox();
							coverBG7.blend = ADD;
							add(coverBG7);
			
							coverBG8 = new BGSprite('covers/cables', -260, -140, 1.2, 1.2);
							coverBG8.scale.set(1.2, 1);
							coverBG8.updateHitbox();
							add(coverBG8);
		
						/*var bfReflextion:FlxSprite = new FlxSprite(boyfriend.x, boyfriend.y);
						bfReflextion.frames = boyfriend.frames;
						bfReflextion.alpha = 0.38;
						bfReflextion.blend = ADD;
						function update()
						{
						bfReflextion.animation.frameIndex = boyfriend.animation.frameIndex;
						}*/
						
		
					case 'mazin-mall': //fun is infinite
						//if(!ClientPrefs.dontShowBG)
							majinOverlay = new BGSprite('mazin/overlay', -360, -90, 0, 0);
							majinOverlay.scale.set(1.5, 1.5);
							majinOverlay.updateHitbox();
							majinOverlay.blend = ADD;
		
							majinBG = new BGSprite('mazin/back', -400, -150, 1, 1);
							majinBG.scale.set(1.4, 1.4);
							majinBG.updateHitbox();
							add(majinBG);
		
							majinGround = new BGSprite('mazin/ground', -400, -70, 1, 1);
							majinGround.scale.set(1.4, 1.4);
							majinGround.updateHitbox();
							add(majinGround);
		
							majinTVBG = new BGSprite('mazin/mazin_mall_BG_tv', -50, 90, ['BG tv']);
							majinTVBG.animation.addByPrefix('idle', 'BG tv', 24, false);
							majinTVBG.scale.set(1, 1);
							majinTVBG.updateHitbox();
							add(majinTVBG);
			
							majinTV = new BGSprite('mazin/tv', -500, 130, 1, 1);
							majinTV.scale.set(1.1, 1.1);
							majinTV.updateHitbox();
					case 'expurgated':
						//if(!ClientPrefs.dontShowBG)
							exSky = new BGSprite('expurgated/sky', -1300, -650, 0.15, 0.15);
							exSky.scale.set(2, 2);
							exSky.updateHitbox();
							add(exSky);
			
							exRock = new BGSprite('expurgated/rock2', -2300, -1100, 0.7, 0.7);
							exRock.scale.set(2.5, 2.5);
							exRock.updateHitbox();
						///exRock.antialiasing = ClientPrefs.globalAntialiasing;
							add(exRock);
		
							// i get this code from vs afton mod (is code by fabs and others coders too, and is open source and getting from haxeflixel API)
							particleEmitter = new FlxEmitter(-2080.5, 1512.4);
							particleEmitter.launchMode = FlxEmitterMode.SQUARE;
							particleEmitter.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
							particleEmitter.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
							particleEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
							particleEmitter.width = 4787.45;
							particleEmitter.alpha.set(1, 1);
							particleEmitter.lifespan.set(1.9, 4.9);
							particleEmitter.loadParticles(Paths.image('expurgated/particle'), 500, 16, true);
		
							particleEmitter.start(false, FlxG.random.float(.01097, .0308), 1000000);
							add(particleEmitter);
		
							exGround = new BGSprite('expurgated/ground', -2800, -1400, 1, 1);
							exGround.scale.set(2.5, 2.5);
							exGround.updateHitbox();
							//exGround.antialiasing = ClientPrefs.globalAntialiasing;
							add(exGround);
			
							exOverlay = new BGSprite('expurgated/gradoverlay', -1440, -650, 0, 0);
							exOverlay.blend = ADD; // how anyone didnt get it?
							exOverlay.scale.set(2.5, 2.5);
							exOverlay.updateHitbox();
							//exOverlay.antialiasing = ClientPrefs.globalAntialiasing;
			
							exFront = new BGSprite('expurgated/signfront', -2950, -1400, 1.15, 1.15);
							exFront.scale.set(2.7, 2.7);
							exFront.updateHitbox();
							//exFront.antialiasing = ClientPrefs.globalAntialiasing;
					case 'skatepark':
						//if(!ClientPrefs.dontShowBG) {
							skateSky = new BGSprite('skatepark/sky', -100, -200, 0.4, 0.4);
							skateSky.scale.set(1, 1);
							skateSky.updateHitbox();
							//skateSky.antialiasing = ClientPrefs.globalAntialiasing;
							add(skateSky);
			
							skateBuildings = new BGSprite('skatepark/buildings', 150, 70, 0.8, 0.8);
							skateBuildings.scale.set(0.9, 0.9);
							skateBuildings.updateHitbox();
							//skateBuildings.antialiasing = ClientPrefs.globalAntialiasing;
							add(skateBuildings);
			
							skateTreess = new BGSprite('skatepark/trees', 100, 50, 1, 1);
							skateTreess.scale.set(1, 1);
							skateTreess.updateHitbox();
							add(skateTreess);
			
							skateFloor = new BGSprite('skatepark/floor', 10, 0, 1, 1);
							skateFloor.scale.set(1, 1);
							skateFloor.updateHitbox();
							//skateFloor.antialiasing = ClientPrefs.globalAntialiasing;
							add(skateFloor);
			
							skateLight = new BGSprite('skatepark/light', -20, -70, 1, 1);
							skateLight.updateHitbox();
							skateLight.blend = ADD;
							///skateLight.antialiasing = ClientPrefs.globalAntialiasing;
							skateLight.scale.set(1.1, 1.1);
			
							skateBuches = new BGSprite('skatepark/buches', 100, 100, 1, 1);
							skateBuches.scale.set(1.2, 1.2);
							skateBuches.updateHitbox();
							//skateBuches.antialiasing = ClientPrefs.globalAntialiasing;
						//}
					case 'hallway':
						//if(!ClientPrefs.dontShowBG)
							hallBG = new BGSprite('hallway/bg', -810, -790, 1, 1);
							hallBG.scale.set(1.6, 1.6);
							hallBG.updateHitbox();
							//jojoBG.antialiasing = ClientPrefs.globalAntialiasing;
							add(hallBG);
			
							hallLuzinha = new BGSprite('hallway/grad', -810, -1060, 1, 1);
							hallLuzinha.blend = ADD;
							//jojoLuzinha.antialiasing = ClientPrefs.globalAntialiasing;
							hallLuzinha.scale.set(1.6, 1.6);
							hallLuzinha.updateHitbox();
							
							hallFG = new BGSprite('hallway/fg', -810, -790, 1, 1);
							//jojoFG.antialiasing = ClientPrefs.globalAntialiasing;
							hallFG.scale.set(1.6, 1.6);
							hallFG.updateHitbox();
							
							/*SANESSS = new FlxSprite(0, 0);
							SANESSS.frames = AtlasFrameMaker.construct('hallway/cutscene1');
							SANESSS.animation.addByPrefix('idle', 'cutscene' 24, false);
							SANESSS.screenCenter();
							SANESSS.updateHitbox();
							SANESSS.scale.set(1.7, 1.7);
							SANESSS.visible = false;*/
					case 'boo':
						//if(!ClientPrefs.dontShowBG)
							var booBG:BGSprite = new BGSprite('boo/Boo-1', -50, -70, 0.7, 0.7);
							booBG.updateHitbox();
						//	booBG.antialiasing = ClientPrefs.globalAntialiasing;
							add(booBG);
			
							var booBG2:BGSprite = new BGSprite('boo/Boo-2', 25, 50, 0.85, 0.85);
							booBG2.updateHitbox();
						//	booBG2.antialiasing = ClientPrefs.globalAntialiasing;
							add(booBG2);
			
							var booBG3:BGSprite = new BGSprite('boo/Boo-3', 25, 50, 0.85, 0.85);
							booBG3.updateHitbox();
						//	booBG3.antialiasing = ClientPrefs.globalAntialiasing;
							add(booBG3);
			
							var booBG4:BGSprite = new BGSprite('boo/Boo-4', -25, 0, 0.9, 0.9);
							booBG4.updateHitbox();
						//	booBG4.antialiasing = ClientPrefs.globalAntialiasing;
							add(booBG4);
							
							var booBG5:BGSprite = new BGSprite('boo/Boo-5', -25, 0, 0.95, 0.95);
							booBG5.updateHitbox();
						//	booBG5.antialiasing = ClientPrefs.globalAntialiasing;
							add(booBG5);
							
							var booBG6:BGSprite = new BGSprite('boo/Boo-6', 50, 0, 1, 1);
							booBG6.updateHitbox();
							//booBG.antialiasing = ClientPrefs.globalAntialiasing;
							add(booBG6);
					case 'amarged': //armageddom
							var bg:BGSprite = new BGSprite('amarged/background', -100, -50, 0.9, 0.9);
							bg.updateHitbox();
							//bg.antialiasing = ClientPrefs.globalAntialiasing;
							add(bg);
			
							var thing:BGSprite = new BGSprite('amarged/build2', -100, -50, 0.9, 0.9);
							thing.updateHitbox();
							//thing.antialiasing = ClientPrefs.globalAntialiasing;
							add(thing);
							
							var hidratacao:BGSprite = new BGSprite('amarged/water', -100, -50, 0.9, 0.9);
							hidratacao.updateHitbox();
						//	hidratacao.antialiasing = ClientPrefs.globalAntialiasing;
							add(hidratacao);
							
							bars = new BGSprite('amarged/bars', 0, 0, 1, 1);
							bars.updateHitbox();
						//	bars.antialiasing = ClientPrefs.globalAntialiasing;
							add(bars);
							
							rocks = new BGSprite('amarged/rocks', 0, 0, 1.1, 1.1);
							//rocks.antialiasing = ClientPrefs.globalAntialiasing;
							rocks.updateHitbox();
					case 'momogogo':
						//var bg:FlxBackdrop;
						momogogoBG = new FlxBackdrop(Paths.image('momogogo/bg'), 0.2, 0.2, true, false); // fuck i forgor the scroll value
						momogogoBG.scrollFactor.set(0.8, 0.8);
						momogogoBG.y = -270;
						momogogoBG.scale.set(1.25, 1.25);
						momogogoBG.updateHitbox();
						momogogoBG.antialiasing = ClientPrefs.globalAntialiasing;
						momogogoBG.velocity.set(120, 0);
						add(momogogoBG);
		
					case 'astral': // pq as planta da minha mãe ta aqui
						//if(!ClientPrefs.dontShowBG)
							matzuBG = new BGSprite('matzu/BG', 0, 0, 0.1, 0.1);
							//matzuBG.updateHitbox();
							matzuBG.screenCenter(XY);
							add(matzuBG);
			
							matzuDESK = new BGSprite('matzu/DES', 0, 0, 0, 0);
							matzuDESK.updateHitbox();
							matzuDESK.screenCenter(XY);
			
							asPlantadaMinhaMae = new BGSprite('matzu/PLAMTS', 0, 0, 0.5, 0.6);
							asPlantadaMinhaMae.updateHitbox();
							asPlantadaMinhaMae.screenCenter(XY);
			
							// quando ta tudo fucked twisted
							matzuFudida1 = new BGSprite('matzu/2/BG1', 0, 0, 0.1, 0.1);
							matzuFudida1.screenCenter(XY);
							matzuFudida1.updateHitbox();
							matzuFudida1.alpha = 0.00001;
							add(matzuFudida1);
			
							matzuFudida2 = new BGSprite('matzu/2/idk', 0, 0, 0, 0);
							matzuFudida2.updateHitbox();
							matzuFudida2.screenCenter(XY);
							matzuFudida2.alpha = 0.00001;
							add(matzuFudida2);
			
							matzuFudida3 = new BGSprite('matzu/2/ground', 0, 0, 0, 0);
							matzuFudida3.updateHitbox();
							matzuFudida3.screenCenter(XY);
							matzuFudida3.alpha = 0.00001;
							add(matzuFudida3);
			
							matzuFudida4 = new BGSprite('matzu/2/messages', 0, 0, 0.4, 0.4);
							matzuFudida4.screenCenter(XY);
							matzuFudida4.updateHitbox();
							matzuFudida4.alpha = 0.00001;
							add(matzuFudida4);
			
							matzuFudida5 = new BGSprite('matzu/2/door', 0, 0, 0.4, 0.4);
							matzuFudida5.updateHitbox();
							matzuFudida5.screenCenter(XY);
							matzuFudida5.alpha = 0.00001;
							add(matzuFudida5);
			
							matzuFudida6 = new BGSprite('matzu/2/desk2', 0, 0, 0, 0);
							matzuFudida6.updateHitbox();
							matzuFudida6.screenCenter(XY);
							matzuFudida6.alpha = 0.00001;
			
							matzuFudida7 = new BGSprite('matzu/2/plamts2', 0, 0, 1.1, 1.1);
							matzuFudida7.updateHitbox();
							matzuFudida7.screenCenter(XY);
							matzuFudida7.alpha = 0.00001;
					case 'ena':
						//if(!ClientPrefs.dontShowBG)
							var enaBG1:BGSprite = new BGSprite('ena/ENA-1', -150, 0, 0.7, 0.7);
							add(enaBG1);
			
							var enaBG2:BGSprite = new BGSprite('ena/ENA-2', -150, 0, 0.8, 0.8);
							add(enaBG2);
			
							var enaBG3:BGSprite = new BGSprite('ena/ENA-3', -150, 0, 0.9, 0.9);
							add(enaBG3);
			
							enaOverlay = new BGSprite('ena/OERLAY-4', -180, 0, 0, 0);
							enaOverlay.blend = ADD;
			
							idkWhatIsthat = new BGSprite('ena/ENA-5', 145, 115, 1.4, 1.4);
		
					case 'nikkuMall':
						var bg:BGSprite  = new BGSprite('nikkuMall/back', -950, -550, 1, 1);
						bg.scale.set(2.4, 2.4);
						bg.updateHitbox();
						add(bg);
		
						var front:BGSprite = new BGSprite('nikkuMall/front', -950, -550, 1, 1);
						front.scale.set(2.4, 2.4);
						front.updateHitbox();
						add(front);
		
						oscabodomeucu = new BGSprite('nikkuMall/cables', -950, -200, 1, 1);
						oscabodomeucu.scale.set(2.4, 2.4);
						oscabodomeucu.updateHitbox();
		
						nicuLight = new BGSprite('nikkuMall/light', -950, -550, 1, 1);
						nicuLight.blend = ADD;
						nicuLight.scale.set(2.4, 2.4);
						nicuLight.updateHitbox();
		
						nicuPlants = new BGSprite('nikkuMall/plants', -975, -500, 1.1, 1.1);
						nicuPlants.scale.set(2.4, 2.4);
						nicuPlants.updateHitbox();
		
					case 'xigmund':
						var bg:BGSprite = new BGSprite('xigmund/bg', -300, -480, 0, 0);
						add(bg);
		
						planet = new BGSprite('xigmund/PlaBlue', -700, 200, 0.1, 0.1);
						add(planet);
		
						sun = new BGSprite('xigmund/SUM', 200, -480, 0.1, 0.1);
						add(sun);
		
						planet2 = new BGSprite('xigmund/PlaRed', 1000, -480, 0.4, 0.4);
						add(planet2);
		
						sun2 = new BGSprite('xigmund/SUM-2', 200, -480, 0.3, 0.3);
						add(sun2);

						asteroidEmitter1 = new FlxEmitter();
						asteroidEmitter1.drag.set(0,0,0,0,200,300,500,750);
						asteroidEmitter1.launchMode = FlxEmitterMode.SQUARE;
						asteroidEmitter1.velocity.set(-7400, -7400, -7400, -7400, -7400, -7400);
						asteroidEmitter1.lifespan.set(1.9, 8.9);
						asteroidEmitter1.loadParticles(Paths.image('xigmund/ast1'), 500, 16, true);
						asteroidEmitter1.start(false, FlxG.random.float(12, 18), FlxG.random.int(1000, 10000));
					case 'sus':
						var bg1:BGSprite = new BGSprite('sus/SUS1', -220, -120, 1.2, 1.2);
						bg1.setGraphicSize(Std.int(bg1.width * 1.5));
						bg1.updateHitbox();
						add(bg1);
		
						var bg2:BGSprite = new BGSprite('sus/SUS2', -50, -80, 1, 1);
						bg2.setGraphicSize(Std.int(bg2.width * 1.1));
						bg2.updateHitbox();
						add(bg2);
		
						osCaboSUS = new BGSprite('sus/SUS3', -517, -6, 0.8, 0.8);
						//osCaboSUS.updateHitbox();
					case 'ddto':
						var bg1:BGSprite = new BGSprite('ddto/DDLC-1', -45, -45, 1.1, 1.1);
						bg1.setGraphicSize(Std.int(bg1.width * 1.1));
						bg1.updateHitbox();
						add(bg1);
		
						naoseiseissoecabomasfds = new BGSprite('ddto/DDLC-2', 0, 0, 0, 0);
						//naoseiseissoecabomasfds.updateHitbox();
					case 'nightland':
						var bg1:BGSprite = new BGSprite('nightland/BG1', -1150, -750, .2, .2);
						bg1.setGraphicSize(Std.int(bg1.width * 1.6));
						bg1.updateHitbox();
						add(bg1);
						
						var bg2:BGSprite = new BGSprite('nightland/BAC2', -1150,-850, .3, .3);
						bg2.setGraphicSize(Std.int(bg2.width * 1.6));
						bg2.updateHitbox();
						add(bg2);
						
						var bg3:BGSprite = new BGSprite('nightland/ROC3', -1150, -850, 0.3, 0.3);
						bg3.setGraphicSize(Std.int(bg3.width * 1.6));
						bg3.updateHitbox();
						add(bg3);
						
						var bg4:BGSprite = new BGSprite('nightland/TREE4', -1900, -1150, 0.9, 0.9);
						bg4.setGraphicSize(Std.int(bg4.width * 1.7));
						bg4.updateHitbox();
						add(bg4);
		
						var bg5:BGSprite = new BGSprite('nightland/GROUMD5', -1900, -1150, 1, 1);
						bg5.setGraphicSize(Std.int(bg5.width * 1.6));
						bg5.updateHitbox();
						add(bg5);
		
						blurBg = new BGSprite('nightland/BLURROC6', -2520, -1400, 1.35, 1.35);
						blurBg.setGraphicSize(Std.int(blurBg.width * 1.8));
						blurBg.updateHitbox();
					case 'whitty':
						var bg1:BGSprite=new BGSprite('whitty/wall', -350, -260, 1, 1);
						bg1.setGraphicSize(Std.int(bg1.width * 1.3));
						bg1.updateHitbox();
						add(bg1);

						var floor2:BGSprite=new BGSprite('whitty/floor', -350, -260, 1, 1);
						floor2.setGraphicSize(Std.int(floor2.width * 1.3));
						floor2.updateHitbox();
						add(floor2);
					case 'smiling':
						var bg:BGSprite = new BGSprite('smiling/bg', 0, 0, 1, 1);
						bg.setGraphicSize(Std.int(bg.width * 0.7));
						bg.updateHitbox();
						add(bg);
					case 'stage4':
						var bg1:BGSprite=new BGSprite('stage4/bg', -2250, -1400, 1, 1);
						bg1.setGraphicSize(Std.int(bg1.width * 2));
						bg1.updateHitbox();
						add(bg1);
		
						var buildings:BGSprite=new BGSprite('stage4/buildings', -2250, -1400, 1, 1);
						buildings.setGraphicSize(Std.int(buildings.width * 2));
						buildings.updateHitbox();
						add(buildings);
		
						var buildings2:BGSprite=new BGSprite('stage4/buildings2', -2250, -1400, 1, 1);
						buildings2.setGraphicSize(Std.int(buildings2.width * 2));
						buildings2.updateHitbox();
						add(buildings2);
		
						var ground:BGSprite=new BGSprite('stage4/ground', -2250, -1450, 1, 1);
						ground.setGraphicSize(Std.int(ground.width * 2));
						ground.updateHitbox();
						add(ground);
					case 'jojo':
						//var jojoLibrary:String = 'jojo/'; // eu realmente nao sei o pq eu fiz essa porra
						var bg:BGSprite=new BGSprite('jojo/bg', -2700, -1900, 0.7, 0.7);
						bg.setGraphicSize(Std.int(bg.width * 2));
						bg.updateHitbox();
						add(bg);

						var bg2:BGSprite=new BGSprite('jojo/building', -2700, -1800, 0.95, 0.95);
						bg2.setGraphicSize(Std.int(bg2.width * 2.05));
						bg2.updateHitbox();
						add(bg2);

						var bg3:BGSprite=new BGSprite('jojo/floor', -2700, -1799, 1, 1);
						bg3.setGraphicSize(Std.int(bg3.width * 2));
						bg3.updateHitbox();
						add(bg3);
					case 'spooky': //Week 2
						if(!ClientPrefs.lowQuality) {
							halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
						} else {
							halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
						}
						add(halloweenBG);
		
						halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
						halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
						halloweenWhite.alpha = 0;
						halloweenWhite.blend = ADD;
		
						//PRECACHE SOUNDS
						precacheList.set('thunder_1', 'sound');
						precacheList.set('thunder_2', 'sound');
		
					case 'philly': //Week 3
						if(!ClientPrefs.lowQuality) {
							var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
							add(bg);
						}
						
						var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
						city.setGraphicSize(Std.int(city.width * 0.85));
						city.updateHitbox();
						add(city);
		
						phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
						phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
						phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
						phillyWindow.updateHitbox();
						add(phillyWindow);
						phillyWindow.alpha = 0;
		
						if(!ClientPrefs.lowQuality) {
							var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
							add(streetBehind);
						}
		
						phillyTrain = new BGSprite('philly/train', 2000, 360);
						add(phillyTrain);
		
						trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
						FlxG.sound.list.add(trainSound);
		
						phillyStreet = new BGSprite('philly/street', -40, 50);
						add(phillyStreet);
		
					case 'limo': //Week 4
						var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
						add(skyBG);
		
						if(!ClientPrefs.lowQuality) {
							limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
							add(limoMetalPole);
		
							bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
							add(bgLimo);
		
							limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
							add(limoCorpse);
		
							limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
							add(limoCorpseTwo);
		
							grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
							add(grpLimoDancers);
		
							for (i in 0...5)
							{
								var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
								dancer.scrollFactor.set(0.4, 0.4);
								grpLimoDancers.add(dancer);
							}
		
							limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
							add(limoLight);
		
							grpLimoParticles = new FlxTypedGroup<BGSprite>();
							add(grpLimoParticles);
		
							//PRECACHE BLOOD
							var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
							particle.alpha = 0.01;
							grpLimoParticles.add(particle);
							resetLimoKill();
		
							//PRECACHE SOUND
							precacheList.set('dancerdeath', 'sound');
						}
		
						limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
		
						fastCar = new BGSprite('limo/fastCarLol', -300, 160);
						fastCar.active = true;
						limoKillingState = 0;
		
					case 'mall': //Week 5 - Cocoa, Eggnog
						var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						add(bg);
		
						if(!ClientPrefs.lowQuality) {
							upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
							upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
							upperBoppers.updateHitbox();
							add(upperBoppers);
		
							var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
							bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
							bgEscalator.updateHitbox();
							add(bgEscalator);
						}
		
						var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
						add(tree);
		
						bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
						bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
						bottomBoppers.updateHitbox();
						add(bottomBoppers);
		
						var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
						add(fgSnow);
		
						santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
						add(santa);
						precacheList.set('Lights_Shut_off', 'sound');
		
					case 'mallEvil': //Week 5 - Winter Horrorland
						var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						add(bg);
		
						var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
						add(evilTree);
		
						var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
						add(evilSnow);
		
					case 'school': //Week 6 - Senpai, Roses
						GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
						GameOverSubstate.loopSoundName = 'gameOver-pixel';
						GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
						GameOverSubstate.characterName = 'bf-pixel-dead';
		
						var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
						add(bgSky);
						bgSky.antialiasing = false;
		
						var repositionShit = -200;
		
						var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
						add(bgSchool);
						bgSchool.antialiasing = false;
		
						var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
						add(bgStreet);
						bgStreet.antialiasing = false;
		
						var widShit = Std.int(bgSky.width * 6);
						if(!ClientPrefs.lowQuality) {
							var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
							fgTrees.setGraphicSize(Std.int(widShit * 0.8));
							fgTrees.updateHitbox();
							add(fgTrees);
							fgTrees.antialiasing = false;
						}
		
						var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
						bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
						bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
						bgTrees.animation.play('treeLoop');
						bgTrees.scrollFactor.set(0.85, 0.85);
						add(bgTrees);
						bgTrees.antialiasing = false;
		
						if(!ClientPrefs.lowQuality) {
							var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
							treeLeaves.setGraphicSize(widShit);
							treeLeaves.updateHitbox();
							add(treeLeaves);
							treeLeaves.antialiasing = false;
						}
		
						bgSky.setGraphicSize(widShit);
						bgSchool.setGraphicSize(widShit);
						bgStreet.setGraphicSize(widShit);
						bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		
						bgSky.updateHitbox();
						bgSchool.updateHitbox();
						bgStreet.updateHitbox();
						bgTrees.updateHitbox();
		
						if(!ClientPrefs.lowQuality) {
							bgGirls = new BackgroundGirls(-100, 190);
							bgGirls.scrollFactor.set(0.9, 0.9);
		
							bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
							bgGirls.updateHitbox();
							add(bgGirls);
						}
		
					case 'schoolEvil': //Week 6 - Thorns
						GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
						GameOverSubstate.loopSoundName = 'gameOver-pixel';
						GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
						GameOverSubstate.characterName = 'bf-pixel-dead';
		
						/*if(!ClientPrefs.lowQuality) { //Does this even do something?
							var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
							var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
						}*/
						var posX = 400;
						var posY = 200;
						if(!ClientPrefs.lowQuality) {
							var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
							bg.scale.set(6, 6);
							bg.antialiasing = false;
							add(bg);
		
							bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
							bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
							bgGhouls.updateHitbox();
							bgGhouls.visible = false;
							bgGhouls.antialiasing = false;
							add(bgGhouls);
						} else {
							var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
							bg.scale.set(6, 6);
							bg.antialiasing = false;
							add(bg);
						}
		
					case 'tank': //Week 7 - Ugh, Guns, Stress
						var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
						add(sky);
		
						if(!ClientPrefs.lowQuality)
						{
							var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
							clouds.active = true;
							clouds.velocity.x = FlxG.random.float(5, 15);
							add(clouds);
		
							var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
							mountains.setGraphicSize(Std.int(1.2 * mountains.width));
							mountains.updateHitbox();
							add(mountains);
		
							var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
							buildings.setGraphicSize(Std.int(1.1 * buildings.width));
							buildings.updateHitbox();
							add(buildings);
						}
		
						var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
						ruins.setGraphicSize(Std.int(1.1 * ruins.width));
						ruins.updateHitbox();
						add(ruins);
		
						if(!ClientPrefs.lowQuality)
						{
							var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
							add(smokeLeft);
							var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
							add(smokeRight);
		
							tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
							add(tankWatchtower);
						}
		
						tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
						add(tankGround);
		
						tankmanRun = new FlxTypedGroup<TankmenBG>();
						add(tankmanRun);
		
						var ground:BGSprite = new BGSprite('tankGround', -420, -150);
						ground.setGraphicSize(Std.int(1.15 * ground.width));
						ground.updateHitbox();
						add(ground);
						moveTank();
		
						foregroundSprites = new FlxTypedGroup<BGSprite>();
						foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
						if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
						foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
						if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
						foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
						if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(boyfriendGroup);
		add(dadGroup);

		//if(!ClientPrefs.dontShowBG) {
			if (curStage == 'space')
			{
				add(bg10);
				add(black);
				add(cutsceneBG);
				add(cutsceneEnd);
				add(cutsceneLogo);
				add(text1);
				add(text2);
			}
	
			if (curStage == 'covers')
			{
				add(coverBG7);
				add(coverBG8);
			}
	
			if (curStage == 'mazin-mall')
			{
				add(majinOverlay);
				add(majinTV);
			}
	
			if (curStage == 'expurgated')
			{
				add(exOverlay);
				add(exFront);
			}
	
			if (curStage == 'skatepark')
			{
				add(skateLight);
				add(skateBuches);
			}
	
			if (curStage == 'hallway')
			{
				add(hallLuzinha);
				add(hallFG);
			}

			if (curStage == 'amarged')
			{
				add(rocks);
			}
	
			if (curStage == 'astral') {
				add(matzuDESK);
				add(asPlantadaMinhaMae);
				add(matzuFudida6);
				add(matzuFudida7);
			}
	
			if (curStage == 'ena') {
				add(enaOverlay);
				add(idkWhatIsthat);
			}

			if (curStage == 'nikkuMall') {
				add(nicuLight);
				add(oscabodomeucu);
				add(nicuPlants);
			}

			if (curStage == 'xigmund'){
				add(asteroidEmitter1);
			}

			if (curStage == 'sus'){
				//add(osCaboSUS);
			}

			if (curStage == 'ddto'){
				//add(naoseiseissoecabomasfds); esqueci
			}

			if (curStage == 'nightland'){
				add(blurBg);
			}

			if (curStage == 'whitty'){
				var fg3:BGSprite=new BGSprite('whitty/fg', -350, -260, 1, 1);
				fg3.setGraphicSize(Std.int(fg3.width * 1.3));
				fg3.updateHitbox();
				add(fg3);
			}

			if (curStage == 'stage4'){
				var overlay1:BGSprite=new BGSprite('stage4/overlay1', -2350, -1500, 1, 1);
				overlay1.setGraphicSize(Std.int(overlay1.width * 2));
				overlay1.updateHitbox();
				overlay1.blend = ADD;
				add(overlay1);

				var overlay2:BGSprite=new BGSprite('stage4/overlay2', -2350, -1500, 1, 1);
				overlay2.setGraphicSize(Std.int(overlay2.width * 2));
				overlay2.updateHitbox();
				overlay2.blend = ADD;
				add(overlay2);
	
				var overlay3:BGSprite=new BGSprite('stage4/overlay3', -2350, -900, 1, 1);
				overlay3.setGraphicSize(Std.int(overlay3.width * 2));
				overlay3.updateHitbox();
				overlay3.blend = ADD;
				add(overlay3);
				
				var bushes:BGSprite=new BGSprite('stage4/bushes', -2350, -1500, 1, 1);
				bushes.setGraphicSize(Std.int(bushes.width * 2));
				bushes.updateHitbox();
				add(bushes);
			}

			if (curStage == 'jojo'){
				var grad:BGSprite=new BGSprite('jojo/grad', -2700, -1900, 0.7, 0.7);
				grad.setGraphicSize(Std.int(grad.width * 2));
				grad.updateHitbox();
				grad.blend = ADD;
				add(grad);
			}

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if (songName == 'sugarcrush') // crush de açuca
		{
					//FlxG.debugger.visible = true;
			octagonBG = new FlxSprite().makeGraphic(1980, 1080, FlxColor.WHITE);
			octagonBG.screenCenter(XY);
			octagonBG.scrollFactor.set(0, 0);
			octagonBG.scale.set(1.4, 1.4);
			octagonBG.cameras = [cutCam];
			octagonBG.alpha = 0.00001; // está nesse valor para o jogo entender que o bagui faz parte do stage ai quando acontecer ai o jogo não laga, genial, né?
			add(octagonBG);

			octagonBG2 = new FlxSprite().makeGraphic(1980, 236, 0xFFFE923D);
			octagonBG2.alpha = 0.00001;
			octagonBG2.screenCenter(XY);
			octagonBG2.scrollFactor.set(0, 0);
			octagonBG2.cameras = [cutCam];
			add(octagonBG2);

			// analfabeto do caralho
			numbahEiti = new FlxBackdrop(Paths.image('skatepark/octagon/numbah_eight'), 0.5, 0.5, true, false, 0, Std.int(1900));
			numbahEiti.alpha = .0001;
			numbahEiti.y = 0;
			//numbahEiti.scale.set(1.3, 1.3);
			numbahEiti.scrollFactor.set(0, 0);
			numbahEiti.cameras = [cutCam];
		//	numbahEiti.offset.y = 20000000;
			numbahEiti.velocity.x = -150;
			add(numbahEiti);

			numbahEiti2 = new FlxBackdrop(Paths.image('skatepark/octagon/numbah_eight'), 0.5, 0.5, true, false, 0, 1900);
			numbahEiti2.alpha = .0001;
			numbahEiti2.y = 245;
			numbahEiti2.alpha = 0.00001;
		//	numbahEiti2.scale.set(1, 1);
			numbahEiti2.scrollFactor.set(0, 0);
		//	numbahEiti2.offset.y += 20000000;
			numbahEiti2.velocity.set(150, 0);
			numbahEiti2.cameras = [cutCam];
			add(numbahEiti2);

			numbahEiti3 = new FlxBackdrop(Paths.image('skatepark/octagon/numbah_eight'), 0.5, 0.5, true, false, 0, Std.int(1900));
			numbahEiti3.alpha = 0.00001;
			numbahEiti3.screenCenter(X);
			numbahEiti3.y = 480;
			//numbahEiti3.scale.set(1, 1);
			numbahEiti3.scrollFactor.set(0, 0);

		//	numbahEiti3.offset.y += 20000000;
			numbahEiti3.velocity.set(-150, 0);
			numbahEiti3.cameras = [cutCam];
			add(numbahEiti3);

			nikkuOctagon = new FlxSprite(-425, 465);
			nikkuOctagon.frames = Paths.getSparrowAtlas('skatepark/octagon/nikku');
			nikkuOctagon.animation.addByPrefix('idle', 'Nikku Move 1', 24, true);
			nikkuOctagon.animation.addByPrefix('lastFrame', 'Nikku Last Frame', 24, true);
			nikkuOctagon.animation.play('idle', true);
			nikkuOctagon.setGraphicSize(Std.int(nikkuOctagon.width * 3.62));
			nikkuOctagon.updateHitbox();
			nikkuOctagon.alpha = 0.00001;
			nikkuOctagon.antialiasing = ClientPrefs.globalAntialiasing;
			nikkuOctagon.cameras = [cutCam];
			add(nikkuOctagon);
			//nikkuOctagon.visible = false;

			bubbleText = new FlxSprite();
			bubbleText.loadGraphic(Paths.image('skatepark/octagon/textbox'));
			bubbleText.screenCenter();
			bubbleText.scale.set(0.00001, 0.00001);
			bubbleText.alpha = 0.00001;
			bubbleText.updateHitbox();
			bubbleText.antialiasing = ClientPrefs.globalAntialiasing;
			bubbleText.cameras = [cutCam];
			add(bubbleText);

			textOctagon = new FlxSprite(bubbleText.x + 20, bubbleText.y + 80);
				textOctagon.frames = Paths.getSparrowAtlas('skatepark/octagon/text', 'h24');
				textOctagon.animation.addByPrefix('text', 'Text', 24, false);
				textOctagon.setGraphicSize(Std.int(textOctagon.width*0.6));
				textOctagon.updateHitbox();
				textOctagon.antialiasing = ClientPrefs.globalAntialiasing;
				textOctagon.alpha = 0.00001;
				textOctagon.cameras = [cutCam];
				add(textOctagon);

				hereme = new FlxSprite().loadGraphic(Paths.image('skatepark/octagon/hereletme', 'h24')); //tween y: 250
				hereme.antialiasing = ClientPrefs.globalAntialiasing;
				hereme.alpha = 0.00001;
				add(hereme);

				showYou/*here let me show you bitch*/ = new FlxSprite().loadGraphic(Paths.image('skatepark/octagon/showyou', 'h24')); //tween y: 250
				showYou.antialiasing = ClientPrefs.globalAntialiasing;
				showYou.alpha = 0.00001;
				add(showYou);

				octagon = new FlxSprite().loadGraphic(Paths.image('skatepark/octagon/octagon', 'h24')); // tween x:295 tween 2 x: 1238
				octagon.antialiasing = ClientPrefs.globalAntialiasing;
				octagon.alpha = 0.00001;
				octagon.cameras = [cutCam];
				add(octagon);

				// sonio ponto eze cutscene
				//var library:String = 'skatepark/cutscene/'; // lazy
				bgExe = new FlxBackdrop(Paths.image('skatepark/cutscene/background'), 0.3, 0.3, true, false);
				bgExe.antialiasing = false;
				bgExe.scrollFactor.set();
				bgExe.x = -1135;
				bgExe.y = -85;
				bgExe.alpha = 0.00001;
				bgExe.setGraphicSize(Std.int(bgExe.width * 8)); // to larger cuz its pixel and its low quality
				bgExe.updateHitbox();
				bgExe.cameras = [cutCam];
				add(bgExe);
		
				groundExe = new FlxBackdrop(Paths.image('skatepark/cutscene/ground'), 0.3, 0.3, true, false);
				groundExe.antialiasing = false;
				groundExe.scrollFactor.set();
				groundExe.y = 470;
				groundExe.setGraphicSize(Std.int(groundExe.width * 6.73));
				groundExe.updateHitbox();
				groundExe.alpha = 0.00001;
				groundExe.cameras = [cutCam];
				add(groundExe);

				eze=new FlxSprite(-350, 245).loadGraphic(Paths.image('skatepark/cutscene/exe', 'h24')); // é hj q eu te pego gostosa kkkkkk
				eze.antialiasing = false;
				eze.scrollFactor.set();
				eze.setGraphicSize(Std.int(eze.width * 5.4));
				eze.updateHitbox();
				eze.cameras = [cutCam];
				eze.alpha = 0.00001;
				add(eze);

				nicuEze = new FlxSprite(565, 180).loadGraphic(Paths.image('skatepark/cutscene/nikku', 'h24')); // pqp me dexa em paz seu porra da o cu na esquina chupa rola
				nicuEze.antialiasing = false;
				nicuEze.scrollFactor.set();
				nicuEze.setGraphicSize(Std.int(nicuEze.width * 5.1));
				nicuEze.updateHitbox();
				nicuEze.alpha = 0.00001;
				nicuEze.cameras = [cutCam];
				add(nicuEze);

				gostosa = new FlxBackdrop(Paths.image('skatepark/cutscene/leaves'), 0.3, 0.3, true, false);
				gostosa.antialiasing = false;
				gostosa.scrollFactor.set();
				gostosa.y = 375;
				gostosa.setGraphicSize(Std.int(gostosa.width * 8.35));
				gostosa.updateHitbox();
				gostosa.alpha = 0.00001;
				gostosa.cameras = [cutCam];
				add(gostosa);

				blackStart = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackStart.cameras = [cutCam];
				blackStart.alpha = 0.00001;
				add(blackStart);
		}
		switch(songName) // texture atlas cutscenes
		{
			case "fandomania":
				fandomaniaCutscene = new FlxAnimate(0, 0, Paths.h024TextureAtlas("cutscene1", "hallway"));
				fandomaniaCutscene.anim.addBySymbol('cutscene', 'ExportAtlas', 24, false);
				fandomaniaCutscene.alpha=0.00001;
				fandomaniaCutscene.screenCenter();
				fandomaniaCutscene.cameras = [cutCam];
				add(fandomaniaCutscene);
			case "killer-queen":
				
		}

		FileSystem.createDirectory(Main.path + "assets"); // saving lines

		// "GLOBAL" SCRIPT
		#if LUA_ALLOWED
		var doPush:Bool = false;

		if(openfl.utils.Assets.exists("assets/scripts/" + "script.lua"))
		{
			var path = Paths.luaAsset("scripts/" + "script");
			var luaFile = openfl.Assets.getBytes(path);

			FileSystem.createDirectory(Main.path + "assets/scripts");
			FileSystem.createDirectory(Main.path + "assets/scripts/");
			
			File.saveBytes(Paths.lua("scripts/" + "script"), luaFile);
			doPush = true;
		}
		if(doPush)
			luaArray.push(new FunkinLua(Paths.lua("scripts/" + "script")));
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		var doPush:Bool = false;

		if(openfl.utils.Assets.exists("assets/stages/" + curStage + ".lua"))
		{
			var path = Paths.luaAsset("stages/" + curStage);
			var luaFile = openfl.Assets.getBytes(path);

			FileSystem.createDirectory(Main.path + "assets/stages");
			FileSystem.createDirectory(Main.path + "assets/stages/");

			File.saveBytes(Paths.lua("stages/" + curStage), luaFile);

			doPush = true;
		}
		if(doPush)
			luaArray.push(new FunkinLua(Paths.lua("stages/" + curStage)));

                #end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend && !ClientPrefs.dontShowGF)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);
	
					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		if (noSkins)
		{
			dad = new Character(0, 0, SONG.player2);
		}
		else {
			switch(skinSelection) {
				case 0:
					dad = new Character(0, 0, 'nikku');
				case 1:
					dad = new Character(0, 0, 'nikku-24');
				case 2:
					dad = new Character(0, 0, 'nikku-jojo');
				case 3:
					dad = new Character(0, 0, 'nikku-classic');
			}
		}
		switch(songName){
			case 'killer-queen':
				dad = new Character(0, 0, 'nikku-jojo');
		}
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'covers':
				bfreflect.frames = boyfriend.frames;
				bfreflect.flipY = true;
				bfreflect.blend = ADD;
				bfreflect.alpha = .55;
				bfreflect.x = boyfriend.x;
				switch(boyfriend.curCharacter)
				{
					case 'bf':
						bfreflect.y = boyfriend.y + 390;
					default:
						bfreflect.y = boyfriend.height;
				}
				insert(members.indexOf(boyfriendGroup), bfreflect);

				gfreflect.frames = gf.frames;
				gfreflect.flipY = true;
				gfreflect.blend = ADD;
				gfreflect.alpha = .8;
				gfreflect.x = gf.x;
				gfreflect.y = gf.y + 550; // talvez poder a altura tb
				gfreflect.scale.set(gf.scale.x, gf.scale.y);
				insert(members.indexOf(gfGroup), gfreflect);

				dadreflect.frames = dad.frames;
				dadreflect.flipY = true;
				dadreflect.blend = ADD; // por isso q no mod os reflexo é mt lindo q da ate vontade de chorar
				dadreflect.alpha = .8;
				dadreflect.x = dad.x;
				dadreflect.scale.set(dad.scale.x, dad.scale.y);
				dadreflect.y = dad.height;
				insert(members.indexOf(dadGroup), dadreflect);

			case 'stage4':
				bfreflect.frames = boyfriend.frames;
				bfreflect.flipY = true;
				bfreflect.blend = ADD;
				bfreflect.alpha = .55;
				bfreflect.x = boyfriend.x;
				switch(boyfriend.curCharacter)
				{
					case 'bf':
						bfreflect.y = boyfriend.y + 390;
					default:
						bfreflect.y = boyfriend.height;
				}
				insert(members.indexOf(boyfriendGroup), bfreflect);

				gfreflect.frames = gf.frames;
				gfreflect.flipY = true;
				gfreflect.blend = ADD;
				gfreflect.alpha = .8;
				gfreflect.x = gf.x;
				gfreflect.y = gf.y + 550; // talvez poder a altura tb
				gfreflect.scale.set(gf.scale.x, gf.scale.y);
				insert(members.indexOf(gfGroup), gfreflect);

				dadreflect.frames = dad.frames;
				dadreflect.flipY = true;
				dadreflect.blend = ADD; // por isso q no mod os reflexo é mt lindo q da ate vontade de chorar
				dadreflect.alpha = .8;
				dadreflect.x = dad.x;
				dadreflect.scale.set(dad.scale.x, dad.scale.y);
				dadreflect.y = dad.height;
				insert(members.indexOf(dadGroup), dadreflect);
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(SUtil.getPath() + file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("goodbyeDespair.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys()) {
			var luaToLoad:String = 'custom_notetypes/' + notetype + '.lua';
			luaToLoad = Paths.getPreloadPath(luaToLoad);
			if(OpenFlAssets.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(Asset2File.getPath(luaToLoad)));
			}
		}
		for (event in eventPushedMap.keys()) {
			var luaToLoad:String = 'custom_events/' + event + '.lua';
			luaToLoad = Paths.getPreloadPath(luaToLoad);    
			if(OpenFlAssets.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(Asset2File.getPath(luaToLoad)));
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 32);
		scoreTxt.setFormat(Paths.font("goodbyeDespair.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("goodbyeDespair.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);

			comboGlow = new FlxSprite().loadGraphic(Paths.image('comboGlow'));
			comboGlow.screenCenter(X); // nao botei o combo_x pq preguiça vou chorar
			comboGlow.y = COMBO_Y;
			comboGlow.alpha = 0.00001;
			comboGlow.blend = ADD; // nao me perguntem o pq o blend ta em add
			comboGlow.cameras = [camHUD];
			add(comboGlow);

			combotxt1 = new FlxText(0, COMBO_Y + 15, FlxG.width, "", 33);
			combotxt1.color = FlxColor.WHITE;
			combotxt1.setFormat(Paths.font("goodbyeDespair.ttf"), 33, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			combotxt1.scrollFactor.set();
			combotxt1.borderSize = 1.25;
			combotxt1.cameras = [camHUD];
			combotxt1.alpha = 0.00001;
			add(combotxt1);

			combotxtscoreplus = new FlxText(0, combotxt1.y + 23, FlxG.width, "", 23);
			combotxtscoreplus.color = FlxColor.WHITE;
			combotxtscoreplus.setFormat(Paths.font("goodbyeDespair.ttf"), 23, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			combotxtscoreplus.scrollFactor.set();
			combotxtscoreplus.borderSize = 1.25;
			combotxtscoreplus.cameras = [camHUD];
			combotxtscoreplus.alpha = 0.00001;
			add(combotxtscoreplus);

			// combo score lerp
			combotxt2 = new FlxText(0, combotxtscoreplus.y + 20, FlxG.width, "", 34);
			combotxt2.setFormat(Paths.font("goodbyeDespair.ttf"), 34, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			combotxt2.scrollFactor.set();
			combotxt2.borderSize = 1.25;
			//combotxt2.setPosition(579, 0); // ibis paint coordinates moment :nerdanimechar:
			combotxt2.cameras = [camHUD];
			combotxt2.alpha = 0.00001;
			add(combotxt2);

				// so para ajudar qm iniciante em haxe ou pode ter em alguma outra linguagem de programação alem do haxe sla
				/*para vocês que são iniciantes, o sinal de exclamação, significa nao, e so funciona em variaveis do tipo bool
				por exemplo 
				if(!algumacoisa){ // a exclamação quer dizer "não".
					// a condiçao
				}
				else{
					// a condiçao quando é alguma coisa
				}
				espero que tenha ajudado.

				-Aly-Ant - 10:47(brazil timezone) 9/4/2022

				e pros cara que faz piada com formiga pq tem ant no final:
				não galerinha, o ant no final nao quer dizer formiga
				é q meu nome real é "ALYsson ANTônio",
				ai se vc separar as tres letras iniciais do nome e do sobrenome, fica ALY ANT,
				quer dizer que toda vez que vc fala "Aly-Ant", vc ta literalmente falando alysson antonio
				a mesma coisa com o "Aly", ai quer dizer que, toda vez que ta falando "Aly", vc ta literalmente falando "Alysson".
				eu pensei nesse nome dps de quando eu tive um sonho.
				*/

			songTag = new SongBar(0, healthBarBG.y + 160);
			add(songTag);

		if (curStage == 'ena') {
			iconP2.visible = false;
		}

		if (curStage == 'astral') {
			iconP1.visible = false;
			iconP2.visible = false;
			healthBarBG.visible = false;
			healthBar.visible = false;
		}

		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		songTag.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		#if android
		addAndroidControls();
		#end

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var doPush:Bool = false;

		if(openfl.utils.Assets.exists("assets/data/" + Paths.formatToSongPath(SONG.song) + "/" + "script.lua"))
		{
			var path = Paths.luaAsset("data/" + Paths.formatToSongPath(SONG.song) + "/" + "script");
			var luaFile = openfl.Assets.getBytes(path);

			FileSystem.createDirectory(Main.path + "assets/data");
			FileSystem.createDirectory(Main.path + "assets/data/");
			FileSystem.createDirectory(Main.path + "assets/data/" + Paths.formatToSongPath(SONG.song));
																				  

			File.saveBytes(Paths.lua("data/" + Paths.formatToSongPath(SONG.song) + "/" + "script"), luaFile);

			doPush = true;
		}
		if(doPush) 
			luaArray.push(new FunkinLua(Paths.lua("data/" + Paths.formatToSongPath(SONG.song) + "/" + "script")));
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isCode && !seenCutscene)
		{
			switch (daSong)
			{
				case 'satellite-picnic':
					snapCamFollowToPos(dad.x + 450, dad.y - 15);
					var cutscenePhone:FlxSound;
					cutscenePhone = new FlxSound().loadEmbedded(Paths.sound('panicPhone'));
					cutscenePhone.play();
					FlxG.sound.list.add(cutscenePhone);

					var blackStart:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width*4),Std.int(FlxG.height*4),FlxColor.BLACK);
					add(blackStart);

					boyfriend.playAnim('sit');
					new FlxTimer().start(1, function(tmr:FlxTimer){
						dad.playAnim('1shock');
						FlxTween.tween(blackStart, {alpha: 0}, 0.7, {
							onComplete: function(twn:FlxTween){
									blackStart.kill();
							}
						});
						dad.animation.finishCallback = function(name:String){
							if(name == '1shock'){
								dad.playAnim('2shock');
								dad.animation.finishCallback = function(name:String){
									if(name == '2shock'){
										dad.playAnim('3shock');
										boyfriend.playAnim('1shock');
										boyfriend.animation.finishCallback = function(name:String){
											if(name == '1shock'){
												boyfriend.playAnim('2shock');
												boyfriend.animation.finishCallback = function(name:String){
													if(name == '2shock'){
														boyfriend.playAnim('3shock');
													}
												};
											}
										};
										dad.animation.finishCallback = function(name:String){
											if(name == '3shock'){
												startCountdown();
											}
										};
									}
								};
							}
						};
					});
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		switch(daSong){
			case 'broadcasting':
				black.visible = true;
				//camGame.visible = false; // kinda buggy
				camHUD.visible = false;
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);
		
		super.create();

		Paths.clearUnusedMemory();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = camOther;

		/*for (i in 0...unspawnNotes.length){// lua script rewrite
			if (unspawnNotes[i].noteType == 'Swap Note'){
				if (!unspawnNotes[i].isSustainNote){
					targetOffsetX = unspawnNotes[i].offsetX;
				}
				else{
					targetOffsetX2 = unspawnNotes[i].offsetX;
				}
				if (unspawnNotes[i].mustPress){
					unspawnNotes[i].offsetX = unspawnNotes[i].offsetX - 640;
				}
				else{
					unspawnNotes[i].offsetX = unspawnNotes[i].offsetX + 640;
				}
			}
		}*/
		// wip
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;

		if(openfl.utils.Assets.exists("assets/characters/" + name + ".lua"))
		{
			var path = Paths.luaAsset("characters/" + name);
			var luaFile = openfl.Assets.getBytes(path);

			FileSystem.createDirectory(Main.path + "assets/characters");
			FileSystem.createDirectory(Main.path + "assets/characters/");

			File.saveBytes(Paths.lua("characters/" + name), luaFile);

			doPush = true;
		}
		if(doPush)
			luaArray.push(new FunkinLua(Paths.lua("characters/" + name)));
		#end
	}
	
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		insert(members.indexOf(dadGroup) + 1, tankman);

		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;

		var tankmanEnd:Void->Void = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;

			var stuff:Array<FlxSprite> = [tankman, gfDance, gfCutscene, picoCutscene, boyfriendCutscene];
			for (char in stuff)
			{
				char.kill();
				remove(char);
				char.destroy();
			}
			Paths.clearUnusedMemory();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');
				
				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				FlxG.sound.playMusic(Paths.music('DISTORTO'), 0, false);
				FlxG.sound.music.fadeIn();

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					camFollow.x += 800;
					camFollow.y += 100;
					
					// Beep!
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						boyfriend.playAnim('singUP', true);
						boyfriend.specialAnim = true;
						FlxG.sound.play(Paths.sound('bfBeep'));
					});

					// Move camera to Tankman
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						camFollow.x -= 800;
						camFollow.y -= 100;

						tankman.animation.play('killYou', true);
						FlxG.sound.play(Paths.sound('killYou'));
						
						// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
						new FlxTimer().start(6.1, function(tmr:FlxTimer)
						{
							tankmanEnd();
						});
					});
				});

			case 'guns':
				tankman.x += 40;
				tankman.y += 10;

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				FlxG.sound.playMusic(Paths.music('DISTORTO'), 0, false);
				FlxG.sound.music.fadeIn();

				new FlxTimer().start(0.01, function(tmr:FlxTimer) //Fixes sync????
				{
					tightBars.play(true);
				});

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

				new FlxTimer().start(11.6, function(tmr:FlxTimer)
				{
					tankmanEnd();

					gf.dance();
					gf.animation.finishCallback = null;
				});

			case 'stress':
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('cutscenes/stress2', 'image');

				gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
				gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
				gfDance.animation.play('dance', true);
				insert(members.indexOf(gfGroup) + 1, gfDance);

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				insert(members.indexOf(gfGroup) + 1, gfCutscene);
				gfCutscene.alpha = 0.00001;

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				insert(members.indexOf(gfGroup) + 1, picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				insert(members.indexOf(boyfriendGroup) + 1, boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}
				
				new FlxTimer().start(0.01, function(tmr:FlxTimer) //Fixes sync????
				{
					cutsceneSnd.play(true);
				});

				new FlxTimer().start(15.2, function(tmr:FlxTimer)
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
					new FlxTimer().start(2.3, function(tmr:FlxTimer)
					{
						zoomBack();
					});
					
					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);
							
							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				new FlxTimer().start(19.5, function(tmr:FlxTimer)
				{
					tankman.frames = Paths.getSparrowAtlas('cutscenes/stress2');
					tankman.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman.animation.play('lookWhoItIs', true);
					tankman.x += 90;
					tankman.y += 6;

					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						camFollow.set(dad.x + 500, dad.y + 170);
					});
				});

				new FlxTimer().start(31.2, function(tmr:FlxTimer)
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
					
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						zoomBack();
					});
				});

				new FlxTimer().start(35.5, function(tmr:FlxTimer)
				{
					tankmanEnd();
					boyfriend.animation.finishCallback = null;
				});
		}
	}

	//var songTwn:FlxTween;
	public function songSlide():Void
	{
		return songTag.tweenStartLololololololololololololololololololololollllmlllmlloololololololololololololololollololololollolololololllololololooloololoooloololoolooloollololllollllolookooilolololololololololololollolololololploololololololollollolllolololllololololololololololoololololllollolololololollollllololololololololololololooololololololol(); //spam function lmao
	}

	//var comboNum:Int = 0;
	var startedC:Bool = false;
	var hasStart:Bool = false;
	//var resetC:Bool = false;
	//var finishState:Bool = false;
	//endCombo = false;
	function comboStart(note:Note = null):Void // unused and combo moment 4
	{
		var pressedKey2:Bool = note.isSustainNote;
		showCombo2 = true;
		//resetC = false;
		//comboNum++;
		comboTmr.start(comboTmr2, function(tmr:FlxTimer){
				//finishState = true;
				//startedC = true;
				finishCombo();
		});
		//resetCombo();
	}

	function resetCombo(){ //unused too and combo moment 5
		return comboTmr.reset(comboTmr2);
		//reseted = true;
	}

	function finishCombo() // combo moment 6
	{
		return comboState = 1;
	}

	function popUpCombo(){ // combo moment 7
		return comboNum++;
	}

	function spawnCombo(){ // combo moment 8
		combotxt1.alpha = 1;
		combotxt2.alpha = 1;
		comboGlow.alpha = 0.3;
		FlxTween.cancelTweensOf(combotxt1);
		FlxTween.cancelTweensOf(combotxt2);
		FlxTween.cancelTweensOf(comboGlow);
		FlxFlicker.stopFlickering(combotxt1);
		FlxFlicker.stopFlickering(combotxt2);
		combotxtscoreplus.alpha = 1;
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;
			#if android
			androidc.visible = true;
			#end
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			songSlide();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	/*function cu(durationIn:Float = 1, durationOut:Float = 1) // another function for song name bar lmao
	{
		var songName:String = Paths.formatToSongPath(SONG.song);

		var text:String = "";
			songTxt = new FlxText(FlxG.width + 12, 0, 0, text, 37);
			songTxt.setFormat(Paths.font("Coco-Sharp-Heavy-Italic-trial.ttf"), 32, FlxColor.WHITE, RIGHT);

			bar = new FlxSprite().makeGraphic(1, 100, FlxColor.BLACK);
			bar.alpha = 0.40;
			bar.scale.x = songTxt.width + 20;
			bar.x -= 20;
			bar.y -= 420;

			songTxt.y = bar.y + 5;
	
			add(bar);
			add(songTxt);
	
		// o texto vai pegar o conteudo do txt
		if(FileSystem.exists(Paths.txt(songName + '/info'))) {
				text = File.getContent(Paths.txt(songName + '/info'));

				if(songName == 'extraterrestrial'){
					songTxt.visible = false;
					bar.visible = false;
			}
		}
		else {
			text = 'tu é mano?';
		}

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxTween.tween(bar, {x: -100}, durationIn, {type:PERSIST, ease:FlxEase.backInOut});
			FlxTween.tween(songTxt, {x: 100}, durationIn, {type:PERSIST, ease:FlxEase.backInOut});
		});
		new FlxTimer().start(6, function(tmr:FlxTimer)
		{
			FlxTween.tween(songTxt, {x: -200}, durationOut, {type:PERSIST, ease:FlxEase.backInOut});
			FlxTween.tween(bar, {x: -550}, durationOut, {type:PERSIST, ease:FlxEase.backInOut});
		});
	}*/

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		//cu(1, 1);

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
                startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(SUtil.getPath() + file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		switch(curStage){
			case "covers":
				elapsedTime += elapsed * 30;
	
				bfreflect.animation.frameIndex = boyfriend.animation.frameIndex;
				bfreflect.offset.set(boyfriend.offset.x); // apenas o x
	
				gfreflect.animation.frameIndex = gf.animation.frameIndex;
				gfreflect.offset.set(gf.offset.x); // apenas o x
	
				dadreflect.animation.frameIndex = dad.animation.frameIndex;
				dadreflect.offset.set(dad.offset.x); // apenas o x
				if (dad.curCharacter.startsWith('nikku'))
					dadreflect.y = (Math.sin(elapsedTime/20)*-75) + 1415; // trigonometry my beloved
			case "stage4":
				elapsedTime += elapsed * 30;

				bfreflect.animation.frameIndex = boyfriend.animation.frameIndex;
				bfreflect.offset.set(boyfriend.offset.x); // apenas o x
	
				gfreflect.animation.frameIndex = gf.animation.frameIndex;
				gfreflect.offset.set(gf.offset.x); // apenas o x
	
				dadreflect.animation.frameIndex = dad.animation.frameIndex;
				dadreflect.offset.set(dad.offset.x); // apenas o x
				if (dad.curCharacter.startsWith('nikku'))
					dadreflect.y = (Math.sin(elapsedTime/20)*-50) + 450; // trigonometry my beloved
		}

		if (comboState == 0){ // combo moment 
			combotxt1.text = rating + " x" + comboNum;
			combotxt2.text = Std.string(comboScore);
			combotxtscoreplus.text = "+" + score;
		}
		if (comboState == 1){ // combo moment 2
				comboNum = 0;
				// lerp momento
				var toZero:Int = 90;
				comboScore = Math.floor(FlxMath.lerp(comboScore, toZero, CoolUtil.boundTo(1 - (elapsed * 32), 0, 1)));
				songScore = Math.floor(FlxMath.lerp(songScore, scoreTarget, CoolUtil.boundTo(1 - (elapsed * 32), 0, 1)));
				if (Math.abs(songScore - scoreTarget) <= 10)
					songScore = scoreTarget;
				if (Math.abs(comboScore - toZero) <= 10)
					comboScore = toZero;
					toZero = 0; // fix?

				// se tiver visível é claro né meu fi ou fia sla

				// pra qm nao entendeu o sentido dessa msg aq em cima é pq tinha uma condição q se tiver no middlescroll os bagui do combo nao aparecia
				FlxFlicker.flicker(combotxt1, 1, 0.05, true, false);
				FlxFlicker.flicker(combotxt2, 1, 0.05, true, false);
				combotxtscoreplus.alpha = 0;
				FlxTween.tween(combotxt1, {alpha:0.00001}, 1, {ease: FlxEase.linear, onComplete: function(twn:FlxTween){
					combotxt1.alpha = 0;
				}});
				FlxTween.tween(combotxt2, {alpha:0.00001}, 1, {ease: FlxEase.linear, onComplete: function(twn:FlxTween){
					combotxt2.alpha = 0;
				}});
				//FlxTween.tween(combotxt1, {alpha:0}, 1); // bruh
				FlxTween.tween(comboGlow, {alpha:0.00001}, 1, {ease: FlxEase.linear, onComplete:function(twn:FlxTween){
					comboGlow.alpha = 0;
					sicks = 0;
					goods = 0;
					bads = 0;
					shits = 0;
				}});

				if (sicks>=20){
								combotxt1.text = 'PERFECT!!';
								/*if (FlxG.random.bool(0.6)){
									combotxt1.text = 'GOOD MAN!';
								}*/
				}
				if (sicks>=10||goods>=10)
				{
								combotxt1.text = 'NICE!';
				}
				if (goods>=5||sicks>=5)
				{
								combotxt1.text = 'GREAT!';
				}
				else
				{
								combotxt1.text = 'WHOOPS...';
								/*deeznut++; // nao tem nenhuma utilidade, é so pro log memo pq eu to entediado
								FlxG.log.add('deez nuts part: ' + deeznut);*/
								// na vdd tem sim, para lagar o jogo.
				}
		}

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			/*case 'expurgated':
				exParticle.forEach(function(particle:ExpurgatedParticle)
				{
					if(exParticle != null)
					{
						var i:Int = exParticle.members.length-1;
						while (i > 0)
						{
							if(particle.alpha < 0)
							{
								particle.kill();
								exParticle.remove(particle, true);
								particle.destroy();
							}
							--i;
						}
						var particlesNum:Int = FlxG.random.int(8, 12);
						var width:Float = (2000 / particlesNum);
						for (j in 0...3)
						{
							for (i in 0...particlesNum)
							{
								var particle:ExpurgatedParticle = new ExpurgatedParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), ExpurgatedParticle.originalY + 200 + (FlxG.random.float(0, 125) + j * 40));
								exParticle.add(particle);
							}
						}
					}
				}*/
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}
		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);	
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));	
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {	
				boyfriendIdleTime += elapsed;	
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss	
					boyfriendIdled = true;	
				}	
			} else {	
				boyfriendIdleTime = 0;	
			}	
		}

		/*if (curStage == 'momogogo')
		{
			momogogoBG.x += 90 * elapsed; // easy huh?
		}*/

		// not funny anymore.
		/*if(FlxG.random.bool(0.4)){
			songTxt.text += ' BITCH.'; // :trollface:
		}*/
		super.update(elapsed);

		//scoreTarget = songScore;

		scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName;
		if(ratingName != '?')
			scoreTxt.text += ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				//}
		
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;
				
				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						} 
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}
				
				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		/*for (a in 0...notes.length){
			notes.forEach(function(note:Note)
			{
				var currentBeat:Int = (Conductor.songPosition/1000)*(SONG.bpm/60);
				if (note.noteType == 'Swap Note'){
					if (note.isSustainNote){
						note.offsetX += 3 * Math.cos((currentBeat + Std.parseFloat(a) * 0.15) * Math.PI);
					}
					if ((note.strumTime - Conductor.songPosition) < 1100 / SONG.speed & !note.isSustainNote)
					{
						if (note.offsetX != targetOffsetX){
							note.offsetX = FlxMath.lerp(notes[a].offsetX, targetOffsetX, CoolUtil.boundTo(elapsed * 10, 0, 1));
						}
						else if (note.offsetX <= targetOffsetX){
							note.offsetX =targetOffsetX;
						}
					}
					else if ((note.strumTime - Conductor.songPosition) < 1200 / SONG.speed & note.isSustainNote)
					{
						if (note.offsetX != targetOffsetX2){
							note.offsetX = FlxMath.lerp(note.offsetX, targetOffsetX2, CoolUtil.boundTo(elapsed * 10, 0, 1));
						}
						else if (note.offsetX <= targetOffsetX2){
							note.offsetX =targetOffsetX2;
						}
					}
				}
			});
		}*/
		// wip

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate());

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public static function TweenParticles(go:FlxSprite, newx:Float,  amp:Float, newy:Float, newalpha:Float, tweenTime:Float, delayTime:Float, newEase:Float->Float, ?baseScale:Float=1):Void{ // unused becuz its kinda buggy

		var randomScale = 0.4 + Math.random()*baseScale;

		go.scale.set(randomScale, randomScale);
		FlxTween.tween(go, {y: newy}, tweenTime, {
			ease: newEase,
			type: FlxTween.LOOPING,
			loopDelay:delayTime});

			FlxTween.tween(go, {"scale.x": newalpha, "scale.y": newalpha}, (Math.random()*5+3), {
			ease: newEase,
			type: FlxTween.LOOPING,
			loopDelay:delayTime});
	}

	function jojoMoment():Void // jojo cutscene in killer queen song
	{
		// first scene
		var jojobg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jojo/cutscene1/bg', 'h24'));
		jojobg.antialiasing = ClientPrefs.globalAntialiasing;
		jojobg.cameras = [cutCam];
		jojobg.setGraphicSize(Std.int(jojobg.width * 2.5), Std.int(jojobg.height * 2.5));
		jojobg.screenCenter();
		jojobg.scrollFactor.set();
		add(jojobg);

		var bfjojo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jojo/cutscene1/bf_virou_hetero', 'h24'));
		bfjojo.antialiasing = ClientPrefs.globalAntialiasing;
		bfjojo.cameras = [cutCam];
		bfjojo.screenCenter();
		bfjojo.setGraphicSize(Std.int(bfjojo.width * 2.5), Std.int(bfjojo.height * 2.5));
		bfjojo.scrollFactor.set();
		add(bfjojo);

		// second scene
		var bg2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jojo/cutscene1/bg2', 'h24'));
		bg2.antialiasing = ClientPrefs.globalAntialiasing;
		bg2.cameras = [cutCam];
		bg2.screenCenter();
		bg2.setGraphicSize(Std.int(bg2.width * 2.5), Std.int(bg2.height * 2.5));
		bg2.scrollFactor.set();
		bg2.visible = false;
		add(bg2);

		var gfchocada:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jojo/cutscene1/krl_isso_e_uma_mulher_ou_um_homem', 'h24'));
		gfchocada.antialiasing = ClientPrefs.globalAntialiasing;
		gfchocada.cameras = [cutCam];
		gfchocada.screenCenter();
		gfchocada.scrollFactor.set();
		gfchocada.setGraphicSize(Std.int(gfchocada.width * 2.5), Std.int(gfchocada.height * 2.5));
		gfchocada.visible = false;
		add(gfchocada);

		// third scene
		var nicueyes:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('jojo/cutscene1/os_zoi_da_nicu', 'h24'));
		nicueyes.antialiasing = ClientPrefs.globalAntialiasing;
		nicueyes.cameras = [cutCam];
		nicueyes.screenCenter(X);
		nicueyes.setGraphicSize(Std.int(nicueyes.width * 2.5), Std.int(nicueyes.height * 2.5));
		nicueyes.visible = false;
		nicueyes.scrollFactor.set();
		add(nicueyes);

		var bfheteroEyes:FlxSprite = new FlxSprite(0, nicueyes.y + 390).loadGraphic(Paths.image('jojo/cutscene/os_zoi_do_bf', 'h24'));
		bfheteroEyes.antialiasing = ClientPrefs.globalAntialiasing;
		bfheteroEyes.cameras = [cutCam];
		bfheteroEyes.setGraphicSize(Std.int(bfheteroEyes.width * 2.5), Std.int(bfheteroEyes.height * 2.5));
		bfheteroEyes.scrollFactor.set();
		bfheteroEyes.screenCenter(X);
		bfheteroEyes.visible = false;
		add(bfheteroEyes);

		// hands scene
		var bg3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jojo/cutscene/bg3', 'h24'));
		bg3.antialiasing = ClientPrefs.globalAntialiasing;
		bg3.cameras = [cutCam];
		bg3.scrollFactor.set();
		bg3.screenCenter();
		bg3.visible = false;
		add(bg3);

		var bfhands:FlxSprite = new FlxSprite(139.3,  -198.3).loadGraphic(Paths.image('jojo/cutscene/as_mao_do_bf', 'h24'));
		bfhands.antialiasing = ClientPrefs.globalAntialiasing;
		bfhands.cameras = [cutCam];
		bfhands.scrollFactor.set();
		//bfhands.screenCenter();
		bfhands.setGraphicSize(Std.int(778.5), Std.int(960.4));
		bfhands.visible = false;
		add(bfhands);

		var nicuhands:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jojo/cutscene/as_mao_do_bf', 'h24'));
		nicuhands.antialiasing = ClientPrefs.globalAntialiasing;
		nicuhands.cameras = [cutCam];
		nicuhands.scrollFactor.set();
		//nicuhands.screenCenter();
		nicuhands.setGraphicSize(Std.int(735.1), Std.int(963.5));
		nicuhands.visible = false;
		add(nicuhands);

		// flash lol
		var flash:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 3.2), Std.int(FlxG.height * 3.2), FlxColor.WHITE);
		flash.cameras = [cutCam];
		flash.scrollFactor.set();
		flash.visible = false;
		add(flash);

		new FlxTimer().start(0.01, function(jojotmr:FlxTimer)
		{
			flash.visible = true;
			FlxTween.tween(bfjojo, {x: bfjojo.x + 200}, 2.5, {ease: FlxEase.linear});
		});
		new FlxTimer().start(0.01, function(jojotmr:FlxTimer)
		{
			flash.visible = false;
		});
		new FlxTimer().start(0.01, function(jojotmr:FlxTimer)
		{
			flash.visible = true;
		});
		new FlxTimer().start(0.01, function(jojotmr:FlxTimer)
		{
			flash.visible = false;
		});
		new FlxTimer().start(2.5, function(tmr:FlxTimer)
		{
			flash.visible = true;
			jojobg.visible = false;
			bfjojo.visible = false;
			bg2.visible = true;
			gfchocada.visible = true;

			FlxTween.tween(gfchocada, {"scale.x": gfchocada.scale.x + 0.90, "scale.y": gfchocada.scale.y + 0.90}, 3);
		});
		new FlxTimer().start(0.01, function(jojotmr:FlxTimer)
		{
			flash.visible = false;
		});
		new FlxTimer().start(0.01, function(jojotmr:FlxTimer)
		{
			flash.visible = true;
		});
		new FlxTimer().start(0.01, function(jojotmr:FlxTimer)
		{
			flash.visible = false;
		});
	}

	function octaMoment():Void
	{
		nikkuOctagon.alpha = 1;
		blackStart.alpha = 1;
				new FlxTimer().start(0.0010, function(tmr:FlxTimer)
				{
					FlxTween.tween(blackStart, {alpha:0}, 0.15);
					FlxTween.tween(octagonBG, {alpha: 1}, 0.15);
					FlxTween.tween(octagonBG2, {alpha: 1}, 0.15);
					FlxTween.tween(numbahEiti, {alpha: 1}, 0.15);
					FlxTween.tween(numbahEiti2, {alpha: 1}, 0.15);
					FlxTween.tween(numbahEiti3, {alpha: 1}, 0.15, {
						onComplete:function(twn:FlxTween)
						{
							FlxTween.tween(nikkuOctagon, {x:50,y:90}, 0.15, { // ata é por isso que tava do lado da tela saporra
								onComplete:function(twn:FlxTween) 
								{
									bubbleText.alpha = 1;
									FlxTween.tween(bubbleText, {"scale.x": 1, "scale.y": 1}, 0.15, {
										ease: FlxEase.quadInOut,
										onComplete:function(twn:FlxTween)
										{
											textOctagon.alpha = 1;
											textOctagon.animation.play('text');
											textOctagon.animation.finishCallback = function(name:String){
												if (name == 'text'){
													octaMoment2();
												}
											};
										}
									});
								}
							});
						}
					});
				});
	}
	function octaMoment2():Void // pre-end of the cutscene
	{
		//nikkuOctagon.y = 200;
		var flash:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
		flash.alpha = 0.00001;
		flash.cameras = [cutCam];
		add(flash);

		FlxTween.tween(bubbleText, {x: FlxG.width * 1.5}, 0.25, {ease:FlxEase.quadInOut});
		FlxTween.tween(nikkuOctagon, {x: 500}, 0.25, {
			onComplete: function(twn:FlxTween)
			{
				nikkuOctagon.animation.play('lastFrame');
				FlxTween.tween(nikkuOctagon, {"scale.x":1.5, "scale.y":1.5}, 2.2, {
					onComplete:function(twn:FlxTween){
						//removeOctaCut();
					}
				});
			}
		});

		new FlxTimer().start(0.3, function(tmr:FlxTimer){
			flash.alpha = 1;
			FlxFlicker.flicker(flash, 0.5, 0.25, false, false, function(flick:FlxFlicker){
				removeOctaCut();
			});
		});
	}

	function removeOctaCut():Void //end
	{
		octagonBG.kill();
		octagonBG2.kill();
		numbahEiti.kill();
		numbahEiti2.kill();
		numbahEiti3.kill();
		nikkuOctagon.kill();
		bubbleText.kill();
		textOctagon.kill();
		//octagon.
	}

	function sonicEZEMoment() // taporra o sonio ponto eze
	{
		// flash 8 coords lmao
		camHUD.alpha = 0;
		bgExe.alpha = 1;
		groundExe.alpha = 1;
		gostosa.alpha = 1;
		nicuEze.alpha = 1;
		eze.alpha = 1;
		bgExe.velocity.set(-155, 0);
		groundExe.velocity.set(-165, 0);
		gostosa.velocity.set(-260, 0);

		var flash:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		flash.cameras = [cutCam];
		flash.alpha = 0.00001;
		add(flash);

		FlxTween.tween(blackStart, {alpha:0}, 0.1, {
			onComplete: function(twn:FlxTween)
			{
				blackStart.kill();
				FlxTween.tween(eze, {x: nicuEze.x - 190}, 6.75);
			}
		});
		FlxTween.tween(nicuEze, {y: nicuEze.y + 5}, 0.1550, {ease:FlxEase.quadInOut, type:PINGPONG});
		FlxTween.tween(eze, {y: eze.y + 5}, 0.1550, {ease:FlxEase.quadInOut, type:PINGPONG});

		new FlxTimer().start(5.8, function(pussy:FlxTimer) // uhhhhhh
		{
			flash.alpha = 1;
			FlxFlicker.flicker(flash, 0.950/*pra formar 6.150 segundos*/, 0.025, false, false, function(flicker:FlxFlicker)
			{
				bgExe.kill();
				groundExe.kill();
				nicuEze.kill();
				eze.kill();
				gostosa.kill();
				camHUD.alpha = 1;
			});
		});
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							FlxG.camera.flash(FlxColor.WHITE, 0.15, null, true);
							FlxG.camera.zoom += 0.5;
							if(ClientPrefs.camZooms) camHUD.zoom += 0.1;

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							FlxG.camera.flash(FlxColor.WHITE, 0.15, null, true);
							FlxG.camera.zoom += 0.5;
							if(ClientPrefs.camZooms) camHUD.zoom += 0.1;

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.3;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						for (who in chars)
						{
							who.color = color;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						var colorDark:FlxColor = color;
						colorDark.brightness *= 0.5;
						phillyStreet.color = colorDark;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Astral Event':
				//if(!ClientPrefs.dontShowBG) {
					changeAstralBG();
				//}

			case 'Sugarcrush Octagon Cutscene':
				octaMoment();

			case 'Sonic.EXE Cutscene': // eita bixo o sonio ponto eze
				sonicEZEMoment();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					Reflect.setProperty(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					Reflect.setProperty(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function changeAstralBG():Void
	{
		if (curStage == 'astral') {
			FlxG.camera.flash(FlxColor.BLACK, 5, null, true);
			asPlantadaMinhaMae.kill();
			matzuBG.kill();
			matzuDESK.kill();
			matzuFudida1.alpha = 1;
			matzuFudida2.alpha = 1;
			matzuFudida3.alpha = 1;
			matzuFudida4.alpha = 1;
			matzuFudida5.alpha=1;
			matzuFudida6.alpha=1;
			matzuFudida7.alpha=1;
		}
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		score = scoreTarget;

		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		#if android
		androidc.visible = false;
		#end
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('nightlight'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			if (isCovers)
			{
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new CoversScreen());
				FlxG.sound.playMusic(Paths.music('nightlight'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.8);
				//changedDifficulty = false;
			}
			if (isExtras)
			{
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new ExtrasScreen());
				FlxG.sound.playMusic(Paths.music('nightlight'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.8);
				//changedDifficulty = false;
			}
			if (isCode) {
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new CodeScreen());
				FlxG.sound.playMusic(Paths.music('codemenu'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.8);
				//changedDifficulty = false;
			}
			if (isFreeplay)
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('nightlight'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.8);
				//changedDifficulty = false;
			}
			transitioning = true;
		}
	}
	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showRating:Bool = true;

	private function popUpScore(note:Note = null):Void
	{
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//var rating:FlxSprite = new FlxSprite();
	//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				note.ratingMod = 0;
				score = 50;
				rating = "SHIT!";
				if(!note.ratingDisabled) shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				note.ratingMod = 0.5;
				score = 100;
				rating = "BAD!";
				if(!note.ratingDisabled) bads++;
			case "good": // good
				totalNotesHit += 0.75;
				note.ratingMod = 0.75;
				score = 200;
				rating = "GOOD!";
				if(!note.ratingDisabled) goods++;
			case "sick": // sick
				totalNotesHit += 1;
				note.ratingMod = 1;
				score = 350;
				rating = "SICK!";
				if(!note.ratingDisabled) sicks++;
		}
		note.rating = daRating;

		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}
		
		if (!practiceMode && !cpuControlled) {
			comboScore += score;
			scoreTarget += score;
			//songScore += score;
		}
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}

			if(ClientPrefs.scoreZoom)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */
		var daCombo:Int = 0;
		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

			//add(comboGlow); esse add não precisa lol pq se não vai crashar SPOILER: NÃO FUNCIONOU VEI BUAAAA
			//add(combotxt1);
			//add(combotxt2);
			
			if (comboState == 1) {

			}
			if (comboTwn != null) {
					comboTwn.cancel();
			}
			combotxt1.scale.x += 0.0485;
			combotxt1.scale.y += 0.0485;
			comboTwn = FlxTween.tween(combotxt1.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
							comboTwn = null;
				}
			});
			if (comboTwn2 != null) {
					comboTwn2.cancel();
			}
			combotxt2.scale.x += 0.0485;
			combotxt2.scale.y += 0.0485;
			comboTwn2 = FlxTween.tween(combotxt2.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
						comboTwn2 = null;
				}
			});

		 /* 
			trace(combo);
			trace(seperatedScore);
		 */

		//coolText.text = Std.string(seperatedScore);
		// add(coolText);
	}

	/*function resetCombo():Void // combo thing not used for now
	{
		//scoreTarget = comboScore;
		var elapsed:Float = 0;
		comboScore = Math.floor(FlxMath.lerp(comboScore, lerpScore, CoolUtil.boundTo(1 - (elapsed * 30), 1, 0)));
		songScore = Math.floor(FlxMath.lerp(songScore, scoreTarget, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1)));
	}*/

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}

			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	//var startedC:Bool = false; its already declared
	function goodNoteHit(note:Note):Void
	{
		//comboTmr = new FlxTimer(); its already declared lol

		if (!note.wasGoodHit)
		{
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote) // combo moment 3
			{
				comboState = 0;
				spawnCombo();
				popUpScore(note);
				popUpCombo();
				if(combo > 9999) combo = 9999;
				//startedC = true;
				comboTmr.cancel();
				comboTmr.start(2, function(tmr:FlxTimer){
					//finishState = true;
					//startedC = true;
					//hasStart = false;
					finishCombo();
				});
				//startedC = true;
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote) 
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;
				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}
	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}
//	Math.sin(Math.PI / 180) * 75 + 400;

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	function flash() { // probably not used shit
		var huh:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE);
		huh.updateHitbox();
		huh.cameras = [cutCam];
		huh.visible = false;
		add(huh);

		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			huh.visible = true;
		});
		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			huh.visible = false;
		});
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		// step hit
		if (curSong == 'Killer Queen')
		{
			// TERMINAR
			//cuts1.visible = true; //Esse é o comando
			// eu sei mateusx9 - aly-ant
		}
		if (curSong == 'Broadcasting')
		{
			switch(curStep)
			{
				case 13:
					FlxTween.tween(cutsceneBG, {alpha:1}, 1);
					FlxTween.tween(cutsceneLogo, {alpha:1}, 1);
				case 45:
					FlxTween.tween(cutsceneLogo, {y: 1289}, 0.78, {
					ease: FlxEase.expoIn});
				case 49:
					FlxTween.tween(cutsceneBG, {alpha: 0}, 0.43);
					FlxTween.tween(cutsceneLogo, {alpha: 0}, 0.43);
				case 52: // eu podia fazer isso com flxflicker mas fds
					text1.visible = true;
				case 53:
					text1.visible = false;
				case 54:
					text1.visible = true;
				case 68:
					text2.visible = true;
				case 69:
					text2.visible = false;
				case 70:
					text2.visible = true;
				case 127:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					text1.visible = false;
					text2.visible = false;
					black.visible = false;
					cutsceneLogo.visible = false;
					cutsceneBG.visible = false;
					camHUD.visible = true;
					//camGame.visible = true;
			}
		}
		if (curSong == 'Fandomania')
		{
			switch(curStep)
			{
				case 446:
					FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
					fandomaniaCutscene.anim.play('cutscene');
					fandomaniaCutscene.alpha = 1;
					fandomaniaCutscene.anim.onComplete = function(){
						fandomaniaCutscene.destroy();
					}
				case 456:
					FlxTween.tween(camHUD, {alpha: 0}, 0.4);
				case 512:
					//SANESSS.visible = false;
					camHUD.alpha = 1;
			}
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015 * camZoomingMult;
			camHUD.zoom += 0.03 * camZoomingMult;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		// timing to play the animation lol
			if (curStage == 'mazin-mall')
			{
				if (curBeat % 1 == 0)
				{
					majinTVBG.animation.play('idle', true);
				}
			}

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}
	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
	for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end
	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
//done nothin' lmao