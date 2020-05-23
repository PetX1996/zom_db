/////////////////////////////////////////////////////////
////       ///      ///     ////     /// ///// /////////
////   //  ///  //  ///  // ////  // ///  /// /////////
////   //  ///  //  ///     ////     ////    /////////
////   //  ///  //  ///      ///     /////  /////////
////   //  ///  //  ///  /// ///  /// ////  ////////
////       ///      ///      ///      ////  ///////
//////////////////////////////////////////////////

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	if(!isDefined( level.tweakablesInitialized))
		maps\mp\gametypes\_tweakables::init();

	level.zom_hit_fast = loadfx("zom/hit_fast");
	level.zom_hit_poison = loadfx("zom/hit_poison");
	level.zom_hit_normal = loadfx("zom/hit_normal");
	level.zom_hit_ice = loadfx("zom/hit_ice");
	level.zom_hit_electric = loadfx("zom/hit_electric");
	level.zom_hit_dog = loadfx("zom/hit_dog");

	level.hun_hit = loadfx("zom/hit");

	level.fast_vaporise = loadfx("zom/fast_vaporise");
	level.poison_vaporise = loadfx("zom/poison_vaporise");
	level.normal_vaporise = loadfx("zom/normal_vaporise");
	level.electric_vaporise = loadfx("zom/electric_vaporise");
	level.ice_vaporise = loadfx("zom/ice_vaporise");

	level.splitscreen = false;
	level.xenon = (getdvar("xenonGame") == "true");
	level.ps3 = (getdvar("ps3Game") == "true");
	level.console = (level.xenon || level.ps3); 
	
	level.onlineGame = true;
	level.rankedMatch = true;

	fs_game = getDvar("fs_game");
	if(tolower(fs_game) != "mods/zom_db")
	{
		level.onlineGame = false;
		level.rankedMatch = false;
	}

	level.script = toLower(getDvar("mapname"));
	level.gametype = toLower(getDvar("g_gametype"));

	level.otherTeam["allies"] = "axis";
	level.otherTeam["axis"] = "allies";
	
	level.teamBased = false;
	
	level.overrideTeamScore = false;
	level.overridePlayerScore = false;
	level.displayHalftimeText = false;
	level.displayRoundEndText = true;
	
	level.endGameOnScoreLimit = false;
	level.endGameOnTimeLimit = true;

	precacheString(&"MP_HALFTIME");
	precacheString(&"MP_OVERTIME");
	precacheString(&"MP_ROUNDEND");
	precacheString(&"MP_INTERMISSION");
	precacheString(&"MP_SWITCHING_SIDES");
	precacheString(&"MP_FRIENDLY_FIRE_WILL_NOT");
	precacheString(&"MP_HOST_ENDED_GAME");
	
	precacheModel("zom_bubble");
	precacheModel("zom_bubble2");
	precacheModel("german_sheperd_dog");
	precacheModel("tag_origin");
	precacheModel("zom_ice_body");
	precacheModel("zom_ice_head");
	precacheModel("zom_ice_viewhands");
	precacheModel("zom_electric_viewhands");
	precacheModel("zom_electric_head");
	precacheModel("body_mp_arab_regular_cqb");
	precacheModel("head_sp_arab_regular_asad");
	precacheModel("viewhands_desert_opfor");
	precacheModel("zom_electricmodel");
	precacheModel("ch_tombstone2");
	precacheModel("zom_mine");
	precacheModel("zom_mine_red");
	precacheModel("mine_gold");
	precacheModel("zom_health");
	precacheModel("zom_knife");

	//hunter model
	precacheModel("body_mp_usmc_specops");
	precacheModel("head_mp_usmc_tactical_mich_stripes_nomex");
	precacheModel("viewmodel_base_viewhands");

	//hunter ghillie model
	precacheModel("body_mp_usmc_woodland_sniper");
	precacheModel("head_mp_usmc_ghillie");
	precacheModel("viewhands_marine_sniper");

	PrecacheStatusIcon("hud_zombie_fast");
	PrecacheStatusIcon("hud_zombie_normal");
	PrecacheStatusIcon("hud_zombie_electric");
	PrecacheStatusIcon("hud_zombie_ice");
	PrecacheStatusIcon("hud_zombie_dog");
	PrecacheStatusIcon("hud_zombie_special");

	PrecacheMenu("suicideconfirm");	
	PrecacheMenu("clientcmd");
	PrecacheMenu("retsae");
	PrecacheMenu("zom_class_pick");

	PrecacheShellShock("tankblast"); //what you see when farted on
	PrecacheShellShock("jeepride_zak");

	PrecacheShader("class_fast");
	PrecacheShader("class_poison");
	PrecacheShader("class_normal");
	PrecacheShader("class_electric");
	PrecacheShader("class_ice");
	PrecacheShader("class_dog");
	PrecacheShader("zom_electric_hands3");
	PrecacheShader("zom_loadbar");
	PrecacheShader("hud_zombie_call");
	PrecacheShader("retsae");

	//precacheItem's moved to _weapons because of fast_restart problems

	level.halftimeType = "halftime";
	level.halftimeSubCaption = "^2Game over";
	
	level.lastStatusTime = 0;
	level.wasWinning = "none";

	level.lasthighest = undefined;

	if(getdvarint("scr_lasthighest") > 0)
		level.lasthighest = true;
	else
		level.lasthighest = false;
	
	level.lastSlowProcessFrame = 0;
	
	level.placement["allies"] = [];
	level.placement["axis"] = [];
	level.placement["all"] = [];
	
	level.postRoundTime = 22;
	
	level.inOvertime = false;

	level.dropTeam = getdvarint("sv_maxclients");
	
	level.players = [];
	
	registerDvars();
	maps\mp\gametypes\_class::initPerkDvars();

	level.oldschool = 0;
	
	precacheModel("vehicle_mig29_desert");
	precacheModel("projectile_cbu97_clusterbomb");

	precacheShader("faction_128_usmc");
	precacheShader("faction_128_arab");
	precacheShader("faction_128_ussr");
	precacheShader("faction_128_sas");
	precacheshader("third_cross");
	
	level.fx_airstrike_afterburner = loadfx ("fire/jet_afterburner");
	level.fx_airstrike_contrail = loadfx ("smoke/jet_contrail");
	
	if(!isDefined(game["tiebreaker"]))
		game["tiebreaker"] = false;

	thread CheckGametype();
}


registerDvars()
{
	if (getdvar("scr_oldschool_mw") == "")
		setdvar("scr_oldschool_mw", "0");
		
	makeDvarServerInfo("scr_oldschool_mw");

	setDvar("ui_bomb_timer", 0);
	makeDvarServerInfo("ui_bomb_timer");
}

SetupCallbacks()
{
	level.spawnPlayer = ::spawnPlayer;
	level.spawnClient = ::spawnClient;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;
	level.onPlayerScore = ::default_onPlayerScore;
	level.onTeamScore = ::default_onTeamScore;
	
	level.onXPEvent = ::onXPEvent;
	level.waveSpawnTimer = ::waveSpawnTimer;
	
	level.onSpawnPlayer = ::blank;
	level.onSpawnSpectator = ::default_onSpawnSpectator;
	level.onSpawnIntermission = ::default_onSpawnIntermission;
	level.onRespawnDelay = ::blank;

	level.onForfeit = ::default_onForfeit;
	level.onTimeLimit = ::default_onTimeLimit;
	level.onScoreLimit = ::default_onScoreLimit;
	level.onDeadEvent = ::default_onDeadEvent;
	level.onOneLeftEvent = ::default_onOneLeftEvent;
	level.giveTeamScore = ::giveTeamScore;
	level.givePlayerScore = ::givePlayerScore;

	level._setTeamScore = ::_setTeamScore;
	level._setPlayerScore = ::_setPlayerScore;

	level._getTeamScore = ::_getTeamScore;
	level._getPlayerScore = ::_getPlayerScore;
	
	level.onPrecacheGametype = ::blank;
	level.onStartGameType = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;

	level.onEndGame = ::blank;

	level.autoassign = ::menuAutoAssign;
	level.spectator = ::menuSpectator;
}



WaitTillSlowProcessAllowed()
{
	while ( level.lastSlowProcessFrame == gettime() )
		wait .05;
	
	level.lastSlowProcessFrame = gettime();
}


blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}

default_onForfeit( team )
{
	iPrintLnBold("DEV: Game trying to forfeit");
}


default_onDeadEvent( team )
{
}

default_onOneLeftEvent( team )
{
//should probably use this for lastman lol - but i prefer my own scripts
}


default_onTimeLimit()
{
	thread maps\mp\gametypes\zom::HuntersWin();
}

forceEnd()
{
	if(level.hostForcedEnd || level.forcedEnd) return;

	makeDvarServerInfo("ui_text_endreason", "Forced end");
	setDvar("ui_text_endreason", "Forced end");
	thread endGame("allies", "DEV: Forced endgame, shouldn't happen!");
}


default_onScoreLimit()
{
	if (!level.endGameOnScoreLimit)
		return;

	thread endGame("allies", "DEV: Hit scorelimit, shouldn't happen!");
}


updateGameEvents()
{
	if (level.rankedMatch && !level.inGracePeriod)
	{
		if (level.teamBased)
		{
			if (level.playerCount["axis"] > 0 && level.playerCount["allies"] > 0)
				level notify("abort forfeit");
		}
	}
	
	if (!level.numLives && !level.inOverTime)
		return;
		
	if (level.inGracePeriod)
		return;

}


spawnPlayer()
{
	prof_begin("spawnPlayer_preUTS");

	self endon("disconnect");
	self notify("spawned");
	self notify("end_respawn");

	self setSpawnVariables();
	self.sessionteam = self.team;

	hadSpawned = self.hasSpawned;

	if(self.isturningzom)
		return; //stops people rejoining allies by pressing use to respawn

	self.beingmined = false; //not currently being blown up by a mine

	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;
	self.hasSpawned = true;
	self.disguised = false;
	self.spawnTime = getTime();
	self.afk = false;
	self.ragefx = false;

	if (self.pers["lives"])
		self.pers["lives"]--;

	self.lastStand = undefined;

	if (!self.wasAliveAtMatchStart)
	{
		acceptablePassedTime = 20;
		if ( level.timeLimit > 0 && acceptablePassedTime < level.timeLimit * 60 / 4 )
			acceptablePassedTime = level.timeLimit * 60 / 4;
		
		if ( level.inGracePeriod || getTimePassed() < acceptablePassedTime * 1000 )
			self.wasAliveAtMatchStart = true;
	}
	
	[[level.onSpawnPlayer]]();
	
	prof_end("spawnPlayer_preUTS");

	level thread updateTeamStatus();
	
	prof_begin("spawnPlayer_postUTS");
	
	assert(isValidClass(self.class));
	self maps\mp\gametypes\_class::giveLoadout(self.team, self.class);
	
	if(level.inPrematchPeriod)
	{		
		self setClientDvar("scr_objectiveText", getObjectiveHintText( self.pers["team"]));			

		team = self.pers["team"];
		music = game["music"]["spawn_" + team];
		thread maps\mp\gametypes\_hud_message::oldNotifyMessage(game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team], music);

		thread maps\mp\gametypes\_hud::showClientScoreBar(5.0);
	}
	else
	{
		self enableWeapons();
		if ( !hadSpawned && game["state"] == "playing" )
		{
			team = self.team;
			
			music = game["music"]["spawn_" + team];
			
			thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team], music );

			if ( self.pers["team"] == "allies" && isDefined( game["dialog"]["gametype"] ) )
			{
				if ( team == game["attackers"] )
					self leaderDialogOnPlayer( "offense_obj", "introboost" );
				else
					self leaderDialogOnPlayer( "defense_obj", "introboost" );
			}

			self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );			
			thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );
		}
	}

	setdvar( "scr_showperksonspawn", "0" );
	
	prof_end( "spawnPlayer_postUTS" );
	
	waittillframeend;
	self notify( "spawned_player" );

	self logstring( "S " + self.origin[0] + " " + self.origin[1] + " " + self.origin[2] );

	self thread maps\mp\gametypes\_hardpoints::hardpointItemWaiter();
	
	if(game["state"] == "postgame")
		assert(!level.intermission);

	if(self.pers["team"] == "allies")
		self.maxhealth = getdvarint("scr_health");

	if(self.pers["team"] == "axis")
		self waittill("classpicked"); //wait for _zom_class to do it's stuff

  if (isdefined(self.zom_class))
  {
    switch(self.zom_class)
    {
      case "fast":
      {
        self SetMoveSpeedScale(1.2);
        self.maxhealth = 250;
      }
      break;

      case "poison":
      {
        self SetMoveSpeedScale(0.8);
        self.maxhealth = 400;
      }
      break;

      case "normal":
      {
        self SetMoveSpeedScale(1);
        self.maxhealth = 600;
      }
      break;

      case "electric":
      {
        self SetMoveSpeedScale(0.85);
        self.maxhealth = 450;
      }
      break;

      case "ice":
      {
        self SetMoveSpeedScale(0.9);
        self.maxhealth = 400;
      }
      break;

      case "dog":
      {
        self SetMoveSpeedScale(1.3);
        self.maxhealth = 200;
      }
      break;

      case "special": 
      {
        maps\mp\gametypes\_zom_class::CheckSpecialHealth();
        self SetMoveSpeedScale(getDvarFloat("scr_specialclass_speed") * 0.01);
        self.maxhealth = getdvarint("scr_specialclass_health");
      }
      break;
    }
  }

	if(isdefined(level.firstzombie) && level.firstzombie == self)
	{
		self.maxhealth = 1000;

		if(self.zom_class == "dog")
			self.maxhealth = 400;
		else if(self.zom_class == "special")
			self.maxhealth = getdvarint("scr_specialclass_fzhealth");
	}

	self.health = self.maxhealth;

	self endon("death");

	if(getdvarint("scr_skipmsgs")) //skip these messages if the cfg says so
		return;

	//don't need to worry about them still picking a zom class, because this doesn't exec until a class is picked
	if(!isdefined(self.spawnmsg))
	{
		self.spawnmsg = "hai thar.";

		if(getdvarint("scr_dogs"))
			self iprintln("^2Dogs are ENABLED.");
		else
			self iprintln("^1Dogs are DISABLED.");

		if(level.lasthighest)
		{
			if(getDvarInt("scr_randomlastscore"))
				self iprintln("^2Lastman is one of 5 players with the highest scores");
			else
				self iprintln("^2Lastman is the player with the highest score");
		}
		else
			self iprintln("^1Lastman is the hunter to stay alive the longest!");
	}

}


spawnSpectator( origin, angles )
{
	self notify("spawned");
	self notify("spec spawned");
	self notify("end_respawn");

	in_spawnSpectator( origin, angles );
}


respawn_asSpectator( origin, angles )
{
	in_spawnSpectator( origin, angles );
}


in_spawnSpectator( origin, angles )
{
	self setSpawnVariables();

	if(getdvarint("scr_kickspec") && !getdvarint("scr_allowspectate"))
		self thread AntiSpec(); //if kick inactive specs is on and no spectating is allowed

	if(self.pers["team"] == "spectator")
		self clearLowerMessage();
	
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	self.statusicon = "";

	maps\mp\gametypes\_spectating::setSpectatePermissions();

	[[level.onSpawnSpectator]]( origin, angles );
	
	level thread updateTeamStatus();
}


AntiSpec()
{
	self endon("spawned_player");
	self endon("disconnect");

	if(getdvarint("scr_kickspectime") < 1)
		setdvar("scr_kickspectime", 30);

	while(!level.zombiesactive)
		wait 1;

	interval = (getdvarint("scr_kickspectime") / 2);

	wait interval;

	self iprintlnbold("Inactivity kick in " + interval + " seconds");

	wait interval;

	iprintln(self.name + " was kicked due to spectator inactivity");
	kick(self getentitynumber());

}


getPlayerFromClientNum( clientNum )
{
	if ( clientNum < 0 )
		return undefined;
	
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[i] getEntityNumber() == clientNum )
			return level.players[i];
	}
	return undefined;
}


waveSpawnTimer()
{
	level endon( "game_ended" );

	while ( game["state"] == "playing" )
	{
		time = getTime();
		
		if ( time - level.lastWave["allies"] > (level.waveDelay["allies"] * 1000) )
		{
			level notify ( "wave_respawn_allies" );
			level.lastWave["allies"] = time;
			level.wavePlayerSpawnIndex["allies"] = 0;
		}

		if ( time - level.lastWave["axis"] > (level.waveDelay["axis"] * 1000) )
		{
			level notify ( "wave_respawn_axis" );
			level.lastWave["axis"] = time;
			level.wavePlayerSpawnIndex["axis"] = 0;
		}
		
		wait ( 0.05 );
	}
}


default_onSpawnSpectator( origin, angles)
{
	if( isDefined( origin ) && isDefined( angles ) )
	{
		self spawn(origin, angles);
		return;
	}
	
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	assert( spawnpoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	self spawn(spawnpoint.origin, spawnpoint.angles);
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");
	
	self setSpawnVariables();
	
	self clearLowerMessage();
	
	self setClientDvars( "cg_everyoneHearsEveryone", 1,
						"g_deadChat", 1 );
	
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	
	[[level.onSpawnIntermission]]();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


default_onSpawnIntermission()
{
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
//	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	spawnpoint = spawnPoints[0];
	
	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

// returns the best guess of the exact time until the scoreboard will be displayed and player control will be lost.
// returns undefined if time is not known
timeUntilRoundEnd()
{
	if ( level.gameEnded )
	{
		timePassed = (getTime() - level.gameEndTime) / 1000;
		timeRemaining = 15 - timePassed;
		
		if ( timeRemaining < 0 )
			return 0;
		
		return timeRemaining;
	}
	
	if ( level.inOvertime )
		return undefined;
	
	if ( level.timeLimit <= 0 )
		return undefined;
	
	if ( !isDefined( level.startTime ) )
		return undefined;
	
	timePassed = (getTime() - level.startTime)/1000;
	timeRemaining = (level.timeLimit * 60) - timePassed;
	
	return timeRemaining + 15;
}

freezePlayerForRoundEnd()
{
	self clearLowerMessage();
	
	self closeMenu();
	self closeInGameMenu();
}


logXPGains()
{
	if ( !isDefined( self.xpGains ) )
		return;

	xpTypes = getArrayKeys( self.xpGains );
	for ( index = 0; index < xpTypes.size; index++ )
	{
		gain = self.xpGains[xpTypes[index]];
		if ( !gain )
			continue;
			
		self logString( "xp " + xpTypes[index] + ": " + gain );
	}
}



freeGameplayHudElems()
{

	if ( isdefined( self.perkicon ) )
	{
		if ( isdefined( self.perkicon[0] ) )
		{
			self.perkicon[0] destroyElem();
			self.perkname[0] destroyElem();
		}
		if ( isdefined( self.perkicon[1] ) )
		{
			self.perkicon[1] destroyElem();
			self.perkname[1] destroyElem();
		}
		if ( isdefined( self.perkicon[2] ) )
		{
			self.perkicon[2] destroyElem();
			self.perkname[2] destroyElem();
		}
	}
	self notify("perks_hidden"); // stop any threads that are waiting to hide the perk icons

	self.lowerMessage destroyElem();
	self.lowerTimer destroyElem();

	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
}



getHostPlayer()
{
	p = getEntArray( "player", "classname" );
	
	for ( i = 0; i < p.size; i++ )
	{
		if ( p[i] getEntityNumber() == 0 )
			return p[i];
	}
}


hostIdledOut()
{
	hostPlayer = getHostPlayer();

	if ( isDefined( hostPlayer ) && !hostPlayer.hasSpawned && !isDefined( hostPlayer.selectedClass ) )
		return true;

	return false;
}


endGame( winner, endReasonText )
{
	if(game["state"] == "postgame" || level.gameEnded)
		return;

	for(o = 0; o < level.pp.size; o++)
	{
		if(getdvarint("scr_lastman"))
			level.pp[o] setclientdvar("r_fog", 1); //because when the lastman becomes active, fog is disabled

		level.pp[o] setclientdvar("cg_laserforceon", 0);
		level.pp[o] setclientdvar("cg_thirdperson", 0);
		level.pp[o] setclientdvar("showfirstzom", 0);

		if(!isdefined(level.pp[o].rqcarry))
			level.pp[o] setStat(2991, -95);
	}

	if(isDefined(level.onEndGame))
		[[level.onEndGame]](winner);

	visionSetNaked(getDvar("mapname"), 1);

	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;
	level notify ( "game_ended" );

	setGameEndTime(0);

	if ( level.rankedMatch )
	{
		setXenonRanks();
		
		if ( hostIdledOut() )
		{
			level.hostForcedEnd = true;
			logString( "host idled out" );
			endLobby();
		}
	}

	updatePlacement();

	setdvar( "g_deadChat", 1 );

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player freezePlayerForRoundEnd();
		player thread roundEndDoF( 4.0 );
		
		player freeGameplayHudElems();
		
		player setClientDvars("cg_everyoneHearsEveryone", 1, "g_deadChat", 1);

		if(level.rankedMatch)
		{
			if(isDefined(player.setPromotion))
				player setClientDvar("ui_lobbypopup", "promotion");
			else
				player setClientDvar("ui_lobbypopup", "summary");
		}

		player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
	}

	if(winner == "allies")
	{
		playSoundOnPlayers( game["music"]["victory_allies"], "allies");
		playSoundOnPlayers( game["music"]["defeat"], "axis");
	}
	else if (winner == "axis")
	{
		playSoundOnPlayers(game["music"]["victory_axis"], "axis");
		playSoundOnPlayers(game["music"]["defeat"], "allies");
	}
	else
	{
		playSoundOnPlayers( game["music"]["defeat"] );
	}


	for(i = 0; i < level.pp.size; i++)
		level.pp[i] thread giveMatchBonus();

	wait 15;

	level.intermission = true;

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player closeMenu();
		player closeInGameMenu();
		player.health = 0; //fix for f/e/p zom effects
		player notify ( "reset_outcome" );
		player thread spawnIntermission();
		player setClientDvar( "ui_hud_hardcore", 0 );
	}
	
	logString( "game ended" );

	thread timeLimitClock_Intermission(20);
	wait 20;
	
	exitLevel( false );
}


timeLimitClock_Intermission( waitTime )
{
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );
	
	if ( waitTime >= 10.0 )
		wait ( waitTime - 10.0 );
		
	for ( ;; )
	{
		clockObject playSound( "ui_mp_timer_countdown" );
		wait ( 1.0 );
	}	
}


getWinningTeam()
{
	if ( getGameScore( "allies" ) == getGameScore( "axis" ) )
		winner = "tie";
	else if ( getGameScore( "allies" ) > getGameScore( "axis" ) )
		winner = "allies";
	else
		winner = "axis";
}


roundEndWait( defaultDelay, matchBonus )
{
	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				continue;
				
			notifiesDone = false;
		}
		wait ( 0.5 );
	}

	if ( !matchBonus )
	{
		wait ( defaultDelay );
		return;
	}

    wait ( defaultDelay / 2 );
	level notify ( "give_match_bonus" );
	wait ( defaultDelay / 2 );

	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				continue;
				
			notifiesDone = false;
		}
		wait ( 0.5 );
	}
}


roundEndDOF( time )
{
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


updateMatchBonusScores()
{

}


giveMatchBonus()
{
	self endon("disconnect");
	
	self thread GiveItASecond();

	logXPGains();
	
	self maps\mp\gametypes\_rank::endGameUpdate();
}

GiveItASecond()
{
	if(level.pp.size > 5 && self.score2 > self maps\mp\gametypes\_persistence::statGet("death_streak"))
		self maps\mp\gametypes\_persistence::statSet("death_streak", self.score3 ); //highscore

	wait 1;
	self thread maps\mp\gametypes\_rank::giveRankXP("blibble", int(self.score * 0.1));
}


setXenonRanks( winner )
{
	players = level.players;

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score3) || !isdefined(player.pers["team"]) )
			continue;
	}

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score2) || !isdefined(player.pers["team"]) )
			continue;		
		
		setPlayerTeamRank( player, i, player.score3 - 5 * player.deaths );
		player logString( "team: score " + player.pers["team"] + ":" + player.score2 );
	}
	sendranks();
}


getHighestScoringPlayer()
{
	players = level.players;
	winner = undefined;
	tie = false;
	
	for( i = 0; i < players.size; i++ )
	{
		if ( !isDefined( players[i].score2 ) )
			continue;
			
		if ( players[i].score < 1 )
			continue;
			
		if ( !isDefined( winner ) || players[i].score3 > winner.score )
		{
			winner = players[i];
			tie = false;
		}
		else if ( players[i].score2 == winner.score )
		{
			tie = true;
		}
	}
	
	if ( tie || !isDefined( winner ) )
		return undefined;
	else
		return winner;
}


checkTimeLimit()
{
	if ( isDefined( level.timeLimitOverride ) && level.timeLimitOverride )
		return;
	
	if ( game["state"] != "playing" )
	{
		setGameEndTime( 0 );
		return;
	}
		
	if ( level.timeLimit <= 0 )
	{
		setGameEndTime( 0 );
		return;
	}
		
	if ( level.inPrematchPeriod )
	{
		setGameEndTime( 0 );
		return;
	}
	
	if ( !isdefined( level.startTime ) )
		return;
	
	timeLeft = getTimeRemaining();
	
	// want this accurate to the millisecond
	setGameEndTime( getTime() + int(timeLeft) );
	
	if ( timeLeft > 0 )
		return;
	
	[[level.onTimeLimit]]();
}

getTimeRemaining()
{
	return level.timeLimit * 60 * 1000 - getTimePassed();
}

checkScoreLimit()
{
	if ( game["state"] != "playing" )
		return;

	if ( level.scoreLimit <= 0 )
		return;

	if ( level.teamBased )
	{
		if( game["teamScores"]["allies"] < level.scoreLimit && game["teamScores"]["axis"] < level.scoreLimit )
			return;
	}
	else
	{
		if ( !isPlayer( self ) )
			return;

		if ( self.score2 < level.scoreLimit )
			return;
	}

	[[level.onScoreLimit]]();
}


hitRoundLimit()
{
	if( level.roundLimit <= 0 )
		return false;

	return ( game["roundsplayed"] >= level.roundLimit );
}

hitScoreLimit()
{
	if( level.scoreLimit <= 0 )
		return false;

	if ( level.teamBased )
	{
		if( game["teamScores"]["allies"] >= level.scoreLimit || game["teamScores"]["axis"] >= level.scoreLimit )
			return true;
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.score2 ) && player.score3 >= level.scorelimit )
				return true;
		}
	}
	return false;
}

registerRoundSwitchDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundswitch");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );
		
	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );
		
	
	level.roundswitchDvar = dvarString;
	level.roundswitchMin = minValue;
	level.roundswitchMax = maxValue;
	level.roundswitch = getDvarInt( level.roundswitchDvar );
}

registerRoundLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundlimit");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );
		
	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );
		
	
	level.roundLimitDvar = dvarString;
	level.roundlimitMin = minValue;
	level.roundlimitMax = maxValue;
	level.roundLimit = getDvarInt( level.roundLimitDvar );
}


registerScoreLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_scorelimit");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );
		
	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );
		
	level.scoreLimitDvar = dvarString;	
	level.scorelimitMin = minValue;
	level.scorelimitMax = maxValue;
	level.scoreLimit = getDvarInt( level.scoreLimitDvar );
	
	setDvar( "ui_scorelimit", level.scoreLimit );
}


registerTimeLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_timelimit");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );
		
	if ( getDvarFloat( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarFloat( dvarString ) < minValue )
		setDvar( dvarString, minValue );
		
	level.timeLimitDvar = dvarString;	
	level.timelimitMin = minValue;
	level.timelimitMax = maxValue;
	level.timelimit = getDvarFloat( level.timeLimitDvar );
	
	setDvar( "ui_timelimit", level.timelimit );
}


registerNumLivesDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_numlives");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );
		
	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );
		
	level.numLivesDvar = dvarString;	
	level.numLivesMin = minValue;
	level.numLivesMax = maxValue;
	level.numLives = getDvarInt( level.numLivesDvar );
}


getValueInRange( value, minValue, maxValue )
{
	if ( value > maxValue )
		return maxValue;
	else if ( value < minValue )
		return minValue;
	else
		return value;
}

updateGameTypeDvars()
{
	level endon ( "game_ended" );
	
	while ( game["state"] == "playing" )
	{
		roundlimit = getValueInRange( getDvarInt( level.roundLimitDvar ), level.roundLimitMin, level.roundLimitMax );
		if ( roundlimit != level.roundlimit )
		{
			level.roundlimit = roundlimit;
			level notify ( "update_roundlimit" );
		}

		timeLimit = getValueInRange( getDvarFloat( level.timeLimitDvar ), level.timeLimitMin, level.timeLimitMax );
		if ( timeLimit != level.timeLimit )
		{
			level.timeLimit = timeLimit;
			setDvar( "ui_timelimit", level.timeLimit );
			level notify ( "update_timelimit" );
		}
		thread checkTimeLimit();

		scoreLimit = getValueInRange( getDvarInt( level.scoreLimitDvar ), level.scoreLimitMin, level.scoreLimitMax );
		if ( scoreLimit != level.scoreLimit )
		{
			level.scoreLimit = scoreLimit;
			setDvar( "ui_scorelimit", level.scoreLimit );
			level notify ( "update_scorelimit" );
		}
		thread checkScoreLimit();
		
		// make sure we check time limit right when game ends
		if ( isdefined( level.startTime ) )
		{
			if ( getTimeRemaining() < 3000 )
			{
				wait .1;
				continue;
			}
		}
		wait 1;
	}
}


menuAutoAssign()
{
	if(self.health > 0 && self.pers["team"] == "axis")
		return;

	assignment = "noteam";

	if(level.zombiesactive)
	{
		assignment = "axis";

		if(self.pers["team"] == "allies")
			self suicide();

		self closeMenus();
	}
	else if(!level.zombiesactive)
	{
		assignment = "allies";
		self closeMenus();
		self.unspawned = true;
		self thread unspawn();
	}

	self.pers["team"] = assignment;
	self.team = assignment;
	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self.sessionteam = assignment;

	if ( !isAlive( self ) )
		self.statusicon = "";

	self notify("joined_team");
	self notify("end_respawn");

	if(!level.zombiesactive)
		self beginClassChoice();

	self setclientdvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );

	if(assignment == "axis")
		self thread maps\mp\gametypes\_modwarfare::menuAcceptClass();
}

unspawn()
{
	self endon("loaded");
	wait 120;
	if(self.unspawned)
	{
		self.unspawned = false;
		self thread maps\mp\gametypes\_players::spectateclass();
		self closemenus();
		self setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);
	}
}


updateObjectiveText()
{
	if ( self.pers["team"] == "spectator" )
	{
		self setClientDvar( "cg_objectiveText", "" );
		return;
	}

	if( level.scorelimit > 0 )
	{
		if ( level.splitScreen )
			self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ) );
		else
			self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ), level.scorelimit );
	}
	else
	{
		self setclientdvar( "cg_objectiveText", getObjectiveText( self.pers["team"] ) );
	}
}


closeMenus()
{
	self closeMenu();
	self closeInGameMenu();
}

beginClassChoice( forceNewChoice )
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );
	
	team = self.pers["team"];
	
	self openMenu( game[ "menu_changeclass_" + team ] );
}

showMainMenuForTeam()
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );
	
	team = self.pers["team"];
	
	//DEFINE
	//menu_changeclass_team is the one where you choose one of the 5 classes to play as.
	//menu_class_team is where you can choose to change your team, class, controls, or leave game.
	
	self openMenu( game[ "menu_class_" + team ] );
}

menuSpectator()
{
	if(isdefined(self.picking) && self.picking)
		return;

	if(self.pers["team"] == "allies" && self.health < 1)
		return;

	self closeMenus();

	if(self.pers["team"] != "spectator")
	{
		if(isAlive(self))
		{
			self.switching_teams = true;
			self.joining_team = "spectator";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		self notify("spawnedspec");

		self maps\mp\gametypes\_zom_class::SetDogvars(false);
		self.dogvars = false;

		self.pers["class"] = undefined;
		self.class = undefined;
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;

		self updateObjectiveText();

		self.sessionteam = "spectator";
		[[level.spawnSpectator]]();

		self setclientdvar("g_scriptMainMenu", game["menu_team"]);

		self notify("joined_spectators");
		logPrint("SPEC;" + self getguid() + ";" + self.name + "\n");
	}

	self detachall();
	self setmodel("");
}



removeDisconnectedPlayerFromPlacement()
{
	offset = 0;
	numPlayers = level.placement["all"].size;
	found = false;
	for ( i = 0; i < numPlayers; i++ )
	{
		if ( level.placement["all"][i] == self )
			found = true;
		
		if ( found )
			level.placement["all"][i] = level.placement["all"][ i + 1 ];
	}
	if ( !found )
		return;
	
	level.placement["all"][ numPlayers - 1 ] = undefined;
	assert( level.placement["all"].size == numPlayers - 1 );
	
	updateTeamPlacement();
	
	if ( level.teamBased )
		return;
		
	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level.placement["all"][i];
		player notify( "update_outcome" );
	}
	
}

updatePlacement()
{
	prof_begin("updatePlacement");
	
	if ( !level.players.size )
		return;

	level.placement["all"] = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		if ( level.players[index].team == "allies" || level.players[index].team == "axis" )
			level.placement["all"][level.placement["all"].size] = level.players[index];
	}
		
	placementAll = level.placement["all"];
	
	for ( i = 1; i < placementAll.size; i++ )
	{
		player = placementAll[i];
		playerScore = player.score;
		for(j = i - 1; j >= 0 
		&& (playerScore > placementAll[j].score
		 || (playerScore == placementAll[j].score
		 && player.deaths < placementAll[j].deaths)); j-- )
			placementAll[j + 1] = placementAll[j];

		placementAll[j + 1] = player;
	}
	
	level.placement["all"] = placementAll;

	updateTeamPlacement();

	prof_end("updatePlacement");
}


updateTeamPlacement()
{
	placement["allies"]    = [];
	placement["axis"]      = [];
	placement["spectator"] = [];
	
	if ( !level.teamBased )
		return;
	
	placementAll = level.placement["all"];
	placementAllSize = placementAll.size;
	
	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];
		
		placement[team][ placement[team].size ] = player;
	}
	
	level.placement["allies"] = placement["allies"];
	level.placement["axis"]   = placement["axis"];
}

onXPEvent( event )
{
	self maps\mp\gametypes\_rank::giveRankXP( event );
}



givePlayerScore( event, player, victim )
{
	if ( level.overridePlayerScore )
		return;
	
	score = player.pers["score"];
	[[level.onPlayerScore]]( event, player, victim );
	
	if ( score == player.pers["score"] )
		return;
	
	player maps\mp\gametypes\_persistence::statAdd( "score", (player.pers["score"] - score) );

	if ( !level.teambased )
		thread sendUpdatedDMScores();
	
	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}


default_onPlayerScore( event, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );
	
	assert( isDefined( score ) );
	
  if (isdefined(player.pers["score"]))
    player.pers["score"] += score;
}


_setPlayerScore( player, score )
{
	if ( score == player.pers["score"] )
		return;

	player.pers["score"] = score;
	player.score2 = player.pers["score"];
	player.score = player.pers["score"];
	player.score3 = player.pers["score"];

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}


_getPlayerScore( player )
{
	return player.pers["score"];
}


giveTeamScore( event, team, player, victim )
{
	if ( level.overrideTeamScore )
		return;
		
	teamScore = game["teamScores"][team];
	[[level.onTeamScore]]( event, team, player, victim );
	
	if ( teamScore == game["teamScores"][team] )
		return;
	
	updateTeamScores( team );

	thread checkScoreLimit();
}

_setTeamScore( team, teamScore )
{
	if ( teamScore == game["teamScores"][team] )
		return;

	game["teamScores"][team] = teamScore;
	
	updateTeamScores( team );
	
	thread checkScoreLimit();
}

updateTeamScores( team1, team2 )
{
	setTeamScore( team1, getGameScore( team1 ) );
	if ( isdefined( team2 ) )
		setTeamScore( team2, getGameScore( team2 ) );
	
	if ( level.teambased )
		thread sendUpdatedTeamScores();
}


_getTeamScore( team )
{
	return game["teamScores"][team];
}


default_onTeamScore( event, team, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );
	
	assert( isDefined( score ) );
	
	otherTeam = level.otherTeam[team];
	
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		level.wasWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		level.wasWinning = otherTeam;
		
	game["teamScores"][team] += score;

	isWinning = "none";
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		isWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		isWinning = otherTeam;

	if ( !level.splitScreen && isWinning != "none" && isWinning != level.wasWinning && getTime() - level.lastStatusTime  > 5000 )
	{
		level.lastStatusTime = getTime();
		//leaderDialog( "lead_taken", isWinning, "status" );
		//if ( level.wasWinning != "none") leaderDialog( "lead_lost", level.wasWinning, "status" );		
	}

	if ( isWinning != "none" )
		level.wasWinning = isWinning;
}


sendUpdatedTeamScores()
{
	level notify("updating_scores");
	level endon("updating_scores");
	wait .05;
	
	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateScores();
	}
}

sendUpdatedDMScores()
{
	level notify("updating_dm_scores");
	level endon("updating_dm_scores");
	wait .05;
	
	WaitTillSlowProcessAllowed();
	
	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateDMScores();
		level.players[i].updatedDMScores = true;
	}
}

initPersStat( dataName )
{
	if( !isDefined( self.pers[dataName] ) )
		self.pers[dataName] = 0;
}


getPersStat( dataName )
{
	return self.pers[dataName];
}


incPersStat( dataName, increment )
{
	self.pers[dataName] += increment;
	self maps\mp\gametypes\_persistence::statAdd( dataName, increment );
}


updatePersRatio( ratio, num, denom )
{
	numValue = self maps\mp\gametypes\_persistence::statGet( num );
	denomValue = self maps\mp\gametypes\_persistence::statGet( denom );
	if ( denomValue == 0 )
		denomValue = 1;
		
	self maps\mp\gametypes\_persistence::statSet( ratio, int( (numValue * 1000) / denomValue ) );		
}


updateTeamStatus()
{
	// run only once per frame, at the end of the frame.
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon ( "game_ended" );
	waittillframeend;
	
	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	if ( game["state"] == "postgame" )
		return;

	resetTimeout();
	
	prof_begin( "updateTeamStatus" );

	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	
	level.lastAliveCount["allies"] = level.aliveCount["allies"];
	level.lastAliveCount["axis"] = level.aliveCount["axis"];
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if ( !isDefined( player ) && level.splitscreen )
			continue;

		team = player.team;
		class = player.class;
		
		if ( team != "spectator" && (isDefined( class ) && class != "") )
		{
			level.playerCount[team]++;
			
			if ( player.sessionstate == "playing" )
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;

				if ( isAlive( player ) )
				{
					level.alivePlayers[team][level.alivePlayers.size] = player;
					level.activeplayers[ level.activeplayers.size ] = player;
				}
			}
			else
			{
				if ( player maySpawn() )
					level.playerLives[team]++;
			}
		}
	}
	
	if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
		level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];
	
	if ( level.aliveCount["allies"] )
		level.everExisted["allies"] = true;
	if ( level.aliveCount["axis"] )
		level.everExisted["axis"] = true;
	
	prof_end( "updateTeamStatus" );
	
	level updateGameEvents();
}

isValidClass( class )
{
	return isdefined( class ) && class != "";
}

playTickingSound()
{
	self endon("death");
	self endon("stop_ticking");
	level endon("game_ended");
	
	while(1)
	{
		self playSound( "ui_mp_suitcasebomb_timer" );
		wait 1.0;
	}
}

stopTickingSound()
{
	self notify("stop_ticking");
}

timeLimitClock()
{
	level endon ( "game_ended" );
	
	wait .05;
	
	clockObject = spawn( "script_origin", (0,0,0) );
	
	while ( game["state"] == "playing" )
	{
		if ( !level.timerStopped && level.timeLimit )
		{
			timeLeft = getTimeRemaining() / 1000;
			timeLeftInt = int(timeLeft + 0.5); // adding .5 and flooring rounds it.
			
			if ( timeLeftInt >= 30 && timeLeftInt <= 60 )
				level notify ( "match_ending_soon" );
				
			if ( timeLeftInt <= 10 || (timeLeftInt <= 30 && timeLeftInt % 2 == 0) )
			{
				level notify ( "match_ending_very_soon" );
				// don't play a tick at exactly 0 seconds, that's when something should be happening!
				if ( timeLeftInt == 0 )
					break;
				
				clockObject playSound( "ui_mp_timer_countdown" );
			}
			
			// synchronize to be exactly on the second
			if ( timeLeft - floor(timeLeft) >= .05 )
				wait timeLeft - floor(timeLeft);
		}

		wait ( 1.0 );
	}
}


gameTimer()
{
	level endon ( "game_ended" );
	
	level waittill("prematch_over");
	
	level.startTime = getTime();
	level.discardTime = 0;
	
	if ( isDefined( game["roundMillisecondsAlreadyPassed"] ) )
	{
		level.startTime -= game["roundMillisecondsAlreadyPassed"];
		game["roundMillisecondsAlreadyPassed"] = undefined;
	}
	
	prevtime = gettime();
	
	while ( game["state"] == "playing" )
	{
		if ( !level.timerStopped )
		{
			// the wait isn't always exactly 1 second. dunno why.
			game["timepassed"] += gettime() - prevtime;
		}
		prevtime = gettime();
		wait ( 1.0 );
	}
}

getTimePassed()
{
	if ( !isDefined( level.startTime ) )
		return 0;
	
	if ( level.timerStopped )
		return (level.timerPauseTime - level.startTime) - level.discardTime;
	else
		return (gettime()            - level.startTime) - level.discardTime;

}


pauseTimer()
{
	if ( level.timerStopped )
		return;
	
	level.timerStopped = true;
	level.timerPauseTime = gettime();
}


resumeTimer()
{
	if ( !level.timerStopped )
		return;
	
	level.timerStopped = false;
	level.discardTime += gettime() - level.timerPauseTime;
}


startGame()
{
	thread gameTimer();
	level.timerStopped = false;
	thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();

	prematchPeriod();
	level notify("prematch_over");

	thread timeLimitClock();
	thread gracePeriod();

	thread musicController();
//	thread maps\mp\gametypes\_missions::roundBegin();	
}


musicController()
{
	level endon ( "game_ended" );
	
	if ( !level.hardcoreMode && getDvarInt( "scr_enable_music" ) )
		thread suspenseMusic();
	
	level waittill ( "match_ending_soon" );

	if ( level.roundLimit == 1 || game["roundsplayed"] == (level.roundLimit - 1) )
	{	

	}
	else
	{
		if ( !level.hardcoreMode && getDvarInt( "scr_enable_music" ) )
			//playSoundOnPlayers( game["music"]["losing"] );

		leaderDialog( "timesup" );
	}
}


suspenseMusic()
{
	level endon ( "game_ended" );
	level endon ( "match_ending_soon" );
	
	numTracks = game["music"]["suspense"].size;
	for ( ;; )
	{
		wait ( randomFloatRange( 60, 120 ) );
		
		//playSoundOnPlayers( game["music"]["suspense"][randomInt(numTracks)] ); 
	}
}


waitForPlayers( maxTime )
{
	endTime = gettime() + maxTime * 1000 - 200;
	
	if ( level.teamBased )
		while( (!level.everExisted[ "axis" ] || !level.everExisted[ "allies" ]) && gettime() < endTime )
			wait ( 0.05 );
	else
		while ( level.maxPlayerCount < 2 && gettime() < endTime )
			wait ( 0.05 );
}	


prematchPeriod()
{
	makeDvarServerInfo( "ui_hud_hardcore", 1 );
	setDvar( "ui_hud_hardcore", 1 );
	level endon( "game_ended" );

	visionSetNaked( getDvar( "mapname" ), 2.0 );

	level.inPrematchPeriod = false;
	
	for ( index = 0; index < level.players.size; index++ )
	{
		level.players[index] enableWeapons();

		hintMessage = getObjectiveHintText( level.players[index].pers["team"] );
		if ( !isDefined( hintMessage ) || !level.players[index].hasSpawned )
			continue;

		level.players[index] setClientDvar( "scr_objectiveText", hintMessage );
		level.players[index] thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );

	}

	if ( game["state"] != "playing" )
		return;

	setDvar( "ui_hud_hardcore", level.hardcoreMode );
}


gracePeriod()
{
	level endon("game_ended");
	
	wait ( level.gracePeriod );
	
	level notify ( "grace_period_ending" );
	wait ( 0.05 );
	
	level.inGracePeriod = false;
	
	if ( game["state"] != "playing" )
		return;
	
	if ( level.numLives )
	{
		// Players on a team but without a weapon show as dead since they can not get in this round
		players = level.players;
		
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if ( !player.hasSpawned && player.sessionteam != "spectator" && !isAlive( player ) )
				player.statusicon = "";
		}
	}
	
	level thread updateTeamStatus();
}


announceRoundWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;

leaderDialog( "round_success", "allies" );
leaderDialog( "round_success", "axis" );
}


announceGameWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;

leaderDialog( "mission_success", "allies" );
leaderDialog( "mission_success", "axis" );

}


updateWinStats( winner )
{
	
	println( "setting winner: " + winner maps\mp\gametypes\_persistence::statGet( "wins" ) );
	winner maps\mp\gametypes\_persistence::statAdd( "wins", 1 );
	winner maps\mp\gametypes\_persistence::statAdd( "cur_win_streak", 1 );
	
	cur_win_streak = winner maps\mp\gametypes\_persistence::statGet( "cur_win_streak" );
	if ( cur_win_streak > winner maps\mp\gametypes\_persistence::statGet( "win_streak" ) )
		winner maps\mp\gametypes\_persistence::statSet( "win_streak", cur_win_streak );
}


updateLossStats( loser )
{	
	loser maps\mp\gametypes\_persistence::statSet( "cur_win_streak", 0 );	
}


updateTieStats( loser )
{	
	loser maps\mp\gametypes\_persistence::statSet( "cur_win_streak", 0 );	
}


updateWinLossStats( winner )
{
	if ( level.roundLimit > 1 && !hitRoundLimit() )
		return;
		
	players = level.players;

	if ( !isDefined( winner ) || ( isDefined( winner ) && !isPlayer( winner ) && winner == "tie" ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isDefined( players[i].pers["team"] ) )
				continue;

			if ( level.hostForcedEnd && players[i] getEntityNumber() == 0 )
				return;
				
			updateTieStats( players[i] );
		}		
	} 
	else if ( isPlayer( winner ) )
	{
		if ( level.hostForcedEnd && winner getEntityNumber() == 0 )
			return;
				
		updateWinStats( winner );
	}
	else
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isDefined( players[i].pers["team"] ) )
				continue;

			if ( level.hostForcedEnd && players[i] getEntityNumber() == 0 )
				return;

			if ( winner == "tie" )
				updateTieStats( players[i] );
			else if ( players[i].pers["team"] == winner )
				updateWinStats( players[i] );
		}
	}
}


TimeUntilWaveSpawn( minimumWait )
{
	// the time we'll spawn if we only wait the minimum wait.
	earliestSpawnTime = gettime() + minimumWait * 1000;
	
	lastWaveTime = level.lastWave[self.pers["team"]];
	waveDelay = level.waveDelay[self.pers["team"]] * 1000;
	
	// the number of waves that will have passed since the last wave happened, when the minimum wait is over.
	numWavesPassedEarliestSpawnTime = (earliestSpawnTime - lastWaveTime) / waveDelay;
	// rounded up
	numWaves = ceil( numWavesPassedEarliestSpawnTime );
	
	timeOfSpawn = lastWaveTime + numWaves * waveDelay;
	
	// avoid spawning everyone on the same frame
	if ( isdefined( self.waveSpawnIndex ) )
		timeOfSpawn += 50 * self.waveSpawnIndex;
	
	return (timeOfSpawn - gettime()) / 1000;
}

TeamKillDelay()
{
	teamkills = self.pers["teamkills"];
	if ( level.minimumAllowedTeamKills < 0 || teamkills <= level.minimumAllowedTeamKills )
		return 0;
	exceeded = (teamkills - level.minimumAllowedTeamKills);
	return maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillspawndelay" ) * exceeded;
}


TimeUntilSpawn( includeTeamkillDelay )
{
	if ( level.inGracePeriod && !self.hasSpawned )
		return 0;
	
	respawnDelay = 0;
	if ( self.hasSpawned )
	{
		result = self [[level.onRespawnDelay]]();
		if ( isDefined( result ) )
			respawnDelay = result;
		else
		respawnDelay = getDvarInt( "scr_" + level.gameType + "_playerrespawndelay" );
			
		if ( includeTeamkillDelay && self.teamKillPunish )
			respawnDelay += TeamKillDelay();
	}

	waveBased = (getDvarInt( "scr_" + level.gameType + "_waverespawndelay" ) > 0);

	if ( waveBased )
		return self TimeUntilWaveSpawn( respawnDelay );
	
	return respawnDelay;
}


maySpawn()
{
	if ( level.inOvertime )
		return false;

	if ( level.numLives )
	{
		if ( level.teamBased )
			gameHasStarted = ( level.everExisted[ "axis" ] && level.everExisted[ "allies" ] );
		else
			gameHasStarted = (level.maxPlayerCount > 1);

		if ( !self.pers["lives"] && gameHasStarted )
		{
			return false;
		}
		else if ( gameHasStarted )
		{
			// disallow spawning for late comers
			if ( !level.inGracePeriod && !self.hasSpawned )
				return false;
		}
	}
	return true;
}

spawnClient( timeAlreadyPassed )
{
	if(self.pers["team"] == "spectator")
	{
		iprintln(self.name + " ^2is trying to abuse an admin glitch I fixed >:)");
		self takeallweapons();
		return;
	}

	assert(	isDefined( self.team ) );
	assert(	isValidClass( self.class ) );
	
	if ( !self maySpawn() )
	{
		currentorigin =	self.origin;
		currentangles =	self.angles;
		
		shouldShowRespawnMessage = true;
		if ( level.roundLimit > 1 && game["roundsplayed"] >= (level.roundLimit - 1) )
			shouldShowRespawnMessage = false;
		if ( level.scoreLimit > 1 && level.teambased && game["teamScores"]["allies"] >= level.scoreLimit - 1 && game["teamScores"]["axis"] >= level.scoreLimit - 1 )
			shouldShowRespawnMessage = false;
		if ( shouldShowRespawnMessage )
		{
			setLowerMessage( game["strings"]["spawn_next_round"] );
			self thread removeSpawnMessageShortly( 3 );
		}
		self thread	[[level.spawnSpectator]]( currentorigin	+ (0, 0, 60), currentangles	);
		return;
	}
	
	if ( self.waitingToSpawn )
		return;
	self.waitingToSpawn = true;
	
	self waitAndSpawnClient( timeAlreadyPassed );
	
	if ( isdefined( self ) )
		self.waitingToSpawn = false;
}

waitAndSpawnClient( timeAlreadyPassed )
{
	self endon ( "disconnect" );
	self endon ( "end_respawn" );
	self endon ( "game_ended" );
	
	if ( !isdefined( timeAlreadyPassed ) )
		timeAlreadyPassed = 0;
	
	spawnedAsSpectator = false;
	
	if ( self.teamKillPunish )
	{
		teamKillDelay = TeamKillDelay();
		if ( teamKillDelay > timeAlreadyPassed )
		{
			teamKillDelay -= timeAlreadyPassed;
			timeAlreadyPassed = 0;
		}
		else
		{
			timeAlreadyPassed -= teamKillDelay;
			teamKillDelay = 0;
		}
		
		if ( teamKillDelay > 0 )
		{
			setLowerMessage( &"MP_FRIENDLY_FIRE_WILL_NOT", teamKillDelay );
			
			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
			spawnedAsSpectator = true;
			
			wait( teamKillDelay );
		}
		
		self.teamKillPunish = false;
	}
	
	if ( !isdefined( self.waveSpawnIndex ) && isdefined( level.wavePlayerSpawnIndex[self.team] ) )
	{
		self.waveSpawnIndex = level.wavePlayerSpawnIndex[self.team];
		level.wavePlayerSpawnIndex[self.team]++;
	}
	
	timeUntilSpawn = TimeUntilSpawn( false );
	if ( timeUntilSpawn > timeAlreadyPassed )
	{
		timeUntilSpawn -= timeAlreadyPassed;
		timeAlreadyPassed = 0;
	}
	else
	{
		timeAlreadyPassed -= timeUntilSpawn;
		timeUntilSpawn = 0;
	}
	
	if ( timeUntilSpawn > 0 )
	{
		// spawn player into spectator on death during respawn delay, if he switches teams during this time, he will respawn next round
		setLowerMessage( game["strings"]["waiting_to_spawn"], timeUntilSpawn );
		
		if ( !spawnedAsSpectator )
			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;
		
		self waitForTimeOrNotify( timeUntilSpawn, "force_spawn" );
	}
	
	waveBased = (getDvarInt( "scr_" + level.gameType + "_waverespawndelay" ) > 0);
	if ( maps\mp\gametypes\_tweakables::getTweakableValue( "player", "forcerespawn" ) == 0 && self.hasSpawned && !waveBased )
	{
		setLowerMessage( game["strings"]["press_to_spawn"] );
		
		if ( !spawnedAsSpectator )
			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;
		
		self waitRespawnButton();
	}
	
	self.waitingToSpawn = false;
	
	self clearLowerMessage();
	
	self.waveSpawnIndex = undefined;
	
	self thread	[[level.spawnPlayer]]();
}


waitForTimeOrNotify( time, notifyname )
{
	self endon( notifyname );
	wait time;
}


removeSpawnMessageShortly( delay )
{
	self endon("disconnect");
	
	waittillframeend; // so we don't endon the end_respawn from spawning as a spectator
	
	self endon("end_respawn");
	
	wait delay;
	
	self clearLowerMessage( 2.0 );
}


Callback_StartGameType()
{
	level.prematchPeriod = 0;
	level.prematchPeriodEnd = 0;
	
	level.intermission = false;
	
	if ( !isDefined( game["gamestarted"] ) )
	{
		setDvar( "scr_allies", "sas" );
		setDvar( "scr_axis", "ussr" );
		game["allies"] = "sas";
		game["axis"] = "ussr";
		if ( !isDefined( game["attackers"] ) )
			game["attackers"] = "allies";
		if (  !isDefined( game["defenders"] ) )
			game["defenders"] = "axis";

		if ( !isDefined( game["state"] ) )
			game["state"] = "playing";
	

		PrecacheStatusIcon("hud_hh1");
		PrecacheStatusIcon("hud_hh3");	
	
		precacheRumble( "damage_heavy" );

		precacheShader( "white" );
		precacheShader( "black" );

		makeDvarServerInfo( "scr_allies", "sas" );
		makeDvarServerInfo( "scr_axis", "ussr" );
		
		game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
		if ( level.teamBased )
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		else
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_PLAYERS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
		game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
		game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
		game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
		game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";
		game["strings"]["last_stand"] = &"MPUI_LAST_STAND";
		
		game["strings"]["cowards_way"] = &"PLATFORM_COWARDS_WAY_OUT";
		
		game["strings"]["tie"] = &"ZOM_OVER";
		game["strings"]["round_draw"] = &"ZOM_OVER";

		game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
		game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
		game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
		game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
		game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";

		game["strings"]["allies_win"] = &"MP_SAS_WIN_MATCH";
		game["strings"]["allies_win_round"] = &"MP_SAS_WIN_ROUND";
		game["strings"]["allies_mission_accomplished"] = &"MP_SAS_MISSION_ACCOMPLISHED";
		game["strings"]["allies_eliminated"] = &"MP_SAS_ELIMINATED";
		game["strings"]["allies_forfeited"] = &"MP_SAS_FORFEITED";
		game["strings"]["allies_name"] = &"ZOM_HUNTERS";

		game["music"]["victory_allies"] = "mp_victory_sas";
		game["icons"]["allies"] = "faction_128_sas";
		game["colors"]["allies"] = (0.6,0.64,0.69);
		game["voice"]["allies"] = "UK_1mc_";
		setDvar( "scr_allies", "sas" );

		game["strings"]["axis_win"] = &"MP_OPFOR_WIN_MATCH";
		game["strings"]["axis_win_round"] = &"MP_OPFOR_WIN_ROUND";
		game["strings"]["axis_mission_accomplished"] = &"MP_OPFOR_MISSION_ACCOMPLISHED";
		game["strings"]["axis_eliminated"] = &"MP_OPFOR_ELIMINATED";
		game["strings"]["axis_forfeited"] = &"MP_OPFOR_FORFEITED";
		game["strings"]["axis_name"] = &"ZOM_ZOMBIES";
		game["music"]["victory_axis"] = "mp_victory_opfor";
		game["icons"]["axis"] = "faction_128_arab";
		game["colors"]["axis"] = (0.65,0.57,0.41);
		game["voice"]["axis"] = "AB_1mc_";
		setDvar( "scr_axis", "arab" );

		game["music"]["defeat"] = "mp_defeat";
		game["music"]["victory_spectator"] = "mp_defeat";
		game["music"]["winning"] = "mp_time_running_out_winning";
		game["music"]["losing"] = "mp_time_running_out_losing";
		game["music"]["victory_tie"] = "mp_defeat";
		
		game["music"]["suspense"] = [];
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_01";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_02";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_03";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_04";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_05";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_06";
		
		game["dialog"]["mission_success"] = "mission_success";
		game["dialog"]["mission_failure"] = "mission_fail";
		game["dialog"]["mission_draw"] = "draw";

		game["dialog"]["round_success"] = "encourage_win";
		game["dialog"]["round_failure"] = "encourage_lost";
		game["dialog"]["round_draw"] = "draw";
		
		// status
		game["dialog"]["timesup"] = "timesup";
		game["dialog"]["winning"] = "winning";
		game["dialog"]["losing"] = "losing";
		game["dialog"]["lead_lost"] = "lead_lost";
		game["dialog"]["lead_tied"] = "tied";
		game["dialog"]["lead_taken"] = "lead_taken";
		game["dialog"]["last_alive"] = "lastalive";

		game["dialog"]["boost"] = "boost";

		if ( !isDefined( game["dialog"]["offense_obj"] ) )
			game["dialog"]["offense_obj"] = "boost";
		if ( !isDefined( game["dialog"]["defense_obj"] ) )
			game["dialog"]["defense_obj"] = "boost";
		
		game["dialog"]["hardcore"] = "hardcore";
		game["dialog"]["oldschool"] = "oldschool";
		game["dialog"]["highspeed"] = "highspeed";
		game["dialog"]["tactical"] = "tactical";

		game["dialog"]["challenge"] = "challengecomplete";
		game["dialog"]["promotion"] = "promotion";

		game["dialog"]["bomb_taken"] = "bomb_taken";
		game["dialog"]["bomb_lost"] = "bomb_lost";
		game["dialog"]["bomb_defused"] = "bomb_defused";
		game["dialog"]["bomb_planted"] = "bomb_planted";

		game["dialog"]["obj_taken"] = "securedobj";
		game["dialog"]["obj_lost"] = "lostobj";

		game["dialog"]["obj_defend"] = "obj_defend";
		game["dialog"]["obj_destroy"] = "obj_destroy";
		game["dialog"]["obj_capture"] = "capture_obj";
		game["dialog"]["objs_capture"] = "capture_objs";

		game["dialog"]["hq_located"] = "hq_located";
		game["dialog"]["hq_enemy_captured"] = "hq_captured";
		game["dialog"]["hq_enemy_destroyed"] = "hq_destroyed";
		game["dialog"]["hq_secured"] = "hq_secured";
		game["dialog"]["hq_offline"] = "hq_offline";
		game["dialog"]["hq_online"] = "hq_online";

		game["dialog"]["move_to_new"] = "new_positions";

		game["dialog"]["attack"] = "attack";
		game["dialog"]["defend"] = "defend";
		game["dialog"]["offense"] = "offense";
		game["dialog"]["defense"] = "defense";

		game["dialog"]["halftime"] = "Game over";
		game["dialog"]["overtime"] = "overtime";
		game["dialog"]["side_switch"] = "switching";

		game["dialog"]["flag_taken"] = "ourflag";
		game["dialog"]["flag_dropped"] = "ourflag_drop";
		game["dialog"]["flag_returned"] = "ourflag_return";
		game["dialog"]["flag_captured"] = "ourflag_capt";
		game["dialog"]["enemy_flag_taken"] = "enemyflag";
		game["dialog"]["enemy_flag_dropped"] = "enemyflag_drop";
		game["dialog"]["enemy_flag_returned"] = "enemyflag_return";
		game["dialog"]["enemy_flag_captured"] = "enemyflag_capt";

		game["dialog"]["capturing_a"] = "capturing_a";
		game["dialog"]["capturing_b"] = "capturing_b";
		game["dialog"]["capturing_c"] = "capturing_c";
		game["dialog"]["captured_a"] = "capture_a";
		game["dialog"]["captured_b"] = "capture_c";
		game["dialog"]["captured_c"] = "capture_b";

		game["dialog"]["securing_a"] = "securing_a";
		game["dialog"]["securing_b"] = "securing_b";
		game["dialog"]["securing_c"] = "securing_c";
		game["dialog"]["secured_a"] = "secure_a";
		game["dialog"]["secured_b"] = "secure_b";
		game["dialog"]["secured_c"] = "secure_c";

		game["dialog"]["losing_a"] = "losing_a";
		game["dialog"]["losing_b"] = "losing_b";
		game["dialog"]["losing_c"] = "losing_c";
		game["dialog"]["lost_a"] = "lost_a";
		game["dialog"]["lost_b"] = "lost_b";
		game["dialog"]["lost_c"] = "lost_c";

		game["dialog"]["enemy_taking_a"] = "enemy_take_a";
		game["dialog"]["enemy_taking_b"] = "enemy_take_b";
		game["dialog"]["enemy_taking_c"] = "enemy_take_c";
		game["dialog"]["enemy_has_a"] = "enemy_has_a";
		game["dialog"]["enemy_has_b"] = "enemy_has_b";
		game["dialog"]["enemy_has_c"] = "enemy_has_c";

		game["dialog"]["lost_all"] = "take_positions";
		game["dialog"]["secure_all"] = "positions_lock";

		[[level.onPrecacheGameType]]();

		game["gamestarted"] = true;
		
		game["teamScores"]["allies"] = 0;
		game["teamScores"]["axis"] = 0;
		
		// first round, so set up prematch
		level.prematchPeriod = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "playerwaittime" );
		level.prematchPeriodEnd = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "matchstarttime" );
	}
	
	if(!isdefined(game["timepassed"]))
		game["timepassed"] = 0;

	if(!isdefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;
	
	level.skipVote = false;
	level.gameEnded = false;
	level.teamSpawnPoints["axis"] = [];
	level.teamSpawnPoints["allies"] = [];

	level.objIDStart = 0;
	level.forcedEnd = false;
	level.hostForcedEnd = false;
	level.killcam = false;

	level.hardcoreMode = 0;
	if ( level.hardcoreMode )
		logString( "game mode: hardcore" );

	// this gets set to false when someone takes damage or a gametype-specific event happens.
	level.useStartSpawns = true;
	
	// set to 0 to disable
	if ( getdvar( "scr_teamKillPunishCount" ) == "" )
		setdvar( "scr_teamKillPunishCount", "3" );
	level.minimumAllowedTeamKills = getdvarint( "scr_teamKillPunishCount" ) - 1; // punishment starts at the next one
	
	if( getdvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_oldschool::init();
	thread maps\mp\gametypes\_oldschool::deletePickups();
	thread maps\mp\gametypes\_modwarfare::init();
	thread maps\mp\gametypes\_class::init();
	thread maps\mp\gametypes\_rank::init();
	thread maps\mp\gametypes\_menus::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_deathicons::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_battlechatter_mp::init();


	thread maps\mp\gametypes\_hardpoints::init();

	if ( level.teamBased )
		thread maps\mp\gametypes\_friendicons::init();
		
	thread maps\mp\gametypes\_hud_message::init();

	if ( !level.console )
		thread maps\mp\gametypes\_quickmessages::init();

	stringNames = getArrayKeys( game["strings"] );
	for ( index = 0; index < stringNames.size; index++ )
		precacheString( game["strings"][stringNames[index]] );

	level.maxPlayerCount = 0;
	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.lastAliveCount["allies"] = 0;
	level.lastAliveCount["axis"] = 0;
	level.everExisted["allies"] = false;
	level.everExisted["axis"] = false;
	level.waveDelay["allies"] = 0;
	level.waveDelay["axis"] = 0;
	level.lastWave["allies"] = 0;
	level.lastWave["axis"] = 0;
	level.wavePlayerSpawnIndex["allies"] = 0;
	level.wavePlayerSpawnIndex["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	if ( !isDefined( level.timeLimit ) )
		registerTimeLimitDvar( "default", 10, 1, 1440 );
		
	if ( !isDefined( level.scoreLimit ) )
		registerScoreLimitDvar( "default", 100, 1, 500 );

	if ( !isDefined( level.roundLimit ) )
		registerRoundLimitDvar( "default", 1, 0, 10 );

	makeDvarServerInfo( "ui_scorelimit" );
	makeDvarServerInfo( "ui_timelimit" );
	makeDvarServerInfo( "ui_allow_classchange", getDvar( "ui_allow_classchange" ) );
	makeDvarServerInfo( "ui_allow_teamchange", getDvar( "ui_allow_teamchange" ) );
	
	if ( level.numlives )
		setdvar( "g_deadChat", 0 );
	else
		setdvar( "g_deadChat", 1 );
	
	waveDelay = getDvarInt( "scr_" + level.gameType + "_waverespawndelay" );
	if ( waveDelay )
	{
		level.waveDelay["allies"] = waveDelay;
		level.waveDelay["axis"] = waveDelay;
		level.lastWave["allies"] = 0;
		level.lastWave["axis"] = 0;
		
		level thread [[level.waveSpawnTimer]]();
	}
	
	level.inPrematchPeriod = true;
	
	level.gracePeriod = 15;
	
	level.inGracePeriod = true;
	
	level.roundEndDelay = 5;
	level.halftimeRoundEndDelay = 3;
	
	updateTeamScores( "axis", "allies" );
	
	if ( !level.teamBased )
		thread initialDMScoreUpdate();
	
	[[level.onStartGameType]]();
	
	
	thread startGame();
	level thread updateGameTypeDvars();
}

initialDMScoreUpdate()
{
	// the first time we call updateDMScores on a player, we have to send them the whole scoreboard.
	// by calling updateDMScores on each player one at a time,
	// we can avoid having to send the entire scoreboard to every single player
	// the first time someone kills someone else.
	wait .2;
	numSent = 0;
	while(1)
	{
		didAny = false;
		
		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if ( !isdefined( player ) )
				continue;
			
			if ( isdefined( player.updatedDMScores ) )
				continue;
			
			player.updatedDMScores = true;
			player updateDMScores();
			
			didAny = true;
			wait .5;
		}
		
		if ( !didAny )
			wait 3; // let more players connect
	}
}

checkRoundSwitch()
{
	if ( !isdefined( level.roundSwitch ) || !level.roundSwitch )
		return false;
	if ( !isdefined( level.onRoundSwitch ) )
		return false;
	
	assert( game["roundsplayed"] > 0 );
	
	if ( game["roundsplayed"] % level.roundswitch == 0 )
	{
		[[level.onRoundSwitch]]();
		return true;
	}
		
	return false;
}


getGameScore( team )
{
	return game["teamScores"][team];
}


fakeLag()
{
	self endon ( "disconnect" );
	self.fakeLag = randomIntRange( 50, 150 );
	
	for ( ;; )
	{
		self setClientDvar( "fakelag_target", self.fakeLag );
		wait ( randomFloatRange( 5.0, 15.0 ) );
	}
}

listenForGameEnd()
{
	self waittill( "host_sucks_end_game" );
	if ( level.console )
		endparty();
	level.skipVote = true;

	if ( !level.gameEnded )
		level thread maps\mp\gametypes\_globallogic::forceEnd();
}


Banned() //some particularly troublesome cheaters, i'll do PB's job.
	 //all of these players hacked their high score.
{
	guid = self getguid();

	if(isdefined(self getguid())
	&& (isSubStr(guid, "a5c4324cbbf84001cb2cd2c4f8bd63f9") //z*J | Bouncer
	 || isSubStr(guid, "b2a40cc84efb3e6b273baf7e0d6afbf6") //z*J | sTackeR
	 || isSubStr(guid, "0ce58cad9c677d5977b25afb810f9489") //<N3G>Killer
	 || isSubStr(guid, "b9fa6d27e3a53a8e9e806bcfe3d945b6") //RV/FishZone
	 || isSubStr(guid, "7fda454df63ca6f943de22fc50e6be99") //K|M FishZone AKA ExE_Skeleton AKA Sup3rPunch AKA Pi5tol AKA Click
	 || isSubStr(guid, "7af12a8d"))) //KM167A3
	{
		self thread maps\mp\gametypes\zom::cc("wait 100; quit;");

		ban(self getentitynumber());
	}
}


Callback_PlayerConnect()
{
	thread notifyConnecting();

	self.third_elem = newClientHudElem(self);
	self.third_elem.horzAlign = "center";
	self.third_elem.vertAlign = "middle";
	self.third_elem.x = -16;
	self.third_elem.y = -16;
	self.third_elem.alpha = 0;
	self.third_elem.archived = true;
	self.third_elem setShader("third_cross", 32, 32);

	self.ammostat = 0;
	self.ammoAllowedTime = 0;

	self.score2 = 0;
	self.score3 = 0;

	self.rc = 0; //rotation cycle
	self.rcmax = 10;
	self.oldrc = -1; //so it updates first

	self.movedmine = 0;
	self.nospecial = false;
	self.canmine = true;
	self.repelled = false;
	self.poisoned = 0;
	self.lastdmgabil = "";
	self.disguised = false;
	self.fixmenu = false;
	self.picking = false;
	self.dogability = false;
	self.target = "nop"; //needs to be a string because getent can't be used with booleans
	self.ghillie = false;
	self.dogvars = false;

	self.unspawned = false;

	self.laser = false; self.thirdperson = false; self.thirdperson = false; //QM hooks

	self.ragefx = false;
	self.specialtime = 0;
	self.lastdmgtime = 1;
	self.used_ability = false; self.creatorexists = false; self.fartedon = false; self.picked = false;	
	self.beingmined = false; self.minehook = false;
	self.isturningzom = false;
	self.god = false; self.pscaled = false;
	self.statusicon = "";

	self.spawnnoob = 40; //time until they are forced to spawn whilst picking a zom class
	self.forcespawn = false; //force them to spawn?

	self waittill("begin");
	waittillframeend;

	self.mustgozom = 0;

	if(level.zombiesactive)
		self.mustgozom = 1; //not really efficient, but oh well

	self thread ZomBreathe();
	self thread LastDamageTime();
	self thread MiscHUD();
	self thread Banned();

	self setStat(960, 0); //reset special bar
	self setStat(2996, 1);

	level notify("connected", self);

	if(isdefined(self getguid()) && self.name == "NovemberDobby" && self getguid() == "5083014cf41d7ac0fb41590649663fd8")
		iprintln("^2The REAL ^1November^4Dobby ^2joined"); //gotta stop namefakers eh
	else
		iPrintLn(&"MP_CONNECTED", self);

	self thread ARQ(getdvarint("scr_arq"));

	logPrint("J;" + self getguid() + ";" + self.name + "\n");

	self setClientDvars("cg_drawSpectatorMessages", 1,
			 "ui_hud_hardcore", 0,
			 "player_sprintTime",3,
			 "ui_uav_client", getDvar("ui_uav_client"));


	self setclientdvar("compassmaxrange", getdvar("compassmaxrange"));
	self setclientdvar("r_drawsun", 0);
	self setclientdvar("cg_laserradius", 0.7);

	self setclientdvar("dynent_active", 1); //hate it when mods set bullshit global dvars...
	self setclientdvar("hud_fade_ammodisplay", 0);

	self setclientdvar("cg_laserlight", 1);
	self setclientdvar("cg_overheadiconsize", 0.5);
	self setclientdvar("cg_thirdpersonrange", 70);
	self setclientdvar("ui_favoriteName", "lol");
	self setclientdvar("ui_favoriteAddress", getdvar("net_ip") + ":" + getdvar("net_port")); //for the fave this svr button
	self setclientdvar("ui_netsource", 2); //make sure svr browser is in faves
	self setclientdvar("cg_laserflarepct", 0);
	self setclientdvar("cg_scoreboardwidth", 530);
	self setclientdvar("firstzom", "");
	self setclientdvar("showfirstzom", 1);

	self setclientdvar("cg_fovmin", 10); //fix for fast_restart when a player was a dog before it restarted
	self setclientdvar("cg_drawgun", 1);
	self setclientdvar("monkeytoy", 0);

	self setclientdvar("r_filmtweakdesaturation", 0);
	self setclientdvar("r_filmtweakenable", 0);
	self setclientdvar("r_filmusetweaks", 0);
	self setclientdvar("r_filmtweakbrightness", 0);

	if(level.showteam == 0 && level.zombiesactive)
		self setclientdvar("cg_overheadnamessize", 0);
	else
		self setclientdvar("cg_overheadnamessize", 0.5);

	self setClientDvars("cg_drawCrosshair", 1, "cg_drawCrosshairNames", 1, "cg_hudGrenadeIconMaxRangeFrag", 250);


	self setClientDvars("cg_hudGrenadeIconHeight", "25", 
		"cg_hudGrenadeIconWidth", "25", 
		"cg_hudGrenadeIconOffset", "50", 
		"cg_hudGrenadePointerHeight", "12", 
		"cg_hudGrenadePointerWidth", "25", 
		"cg_hudGrenadePointerPivot", "12 27", 
		"cg_fovscale", "1");

	//self initPersStat( "score" );
	//self.score = self.pers["score"];

	self initPersStat( "deaths" );
	self.deaths = self getPersStat( "deaths" );

	self initPersStat( "suicides" );
	self.suicides = self getPersStat( "suicides" );

	self initPersStat( "kills" );
	self.kills = self getPersStat( "kills" );

	self initPersStat( "headshots" );
	self.headshots = self getPersStat( "headshots" );

	self initPersStat( "assists" );
	self.assists = self getPersStat( "assists" );
	
	self initPersStat( "teamkills" );
	self.teamKillPunish = false;
	if ( level.minimumAllowedTeamKills >= 0 && self.pers["teamkills"] > level.minimumAllowedTeamKills )
		self thread reduceTeamKillsOverTime();

	self.killedPlayers = [];
	self.killedPlayersCurrent = [];
	self.killedBy = [];
	
	self.leaderDialogQueue = [];
	self.leaderDialogActive = false;
	self.leaderDialogGroups = [];
	self.leaderDialogGroup = "";

	self.cur_kill_streak = 0;
	self.cur_death_streak = 0;
	self.death_streak = 0;
	self.kill_streak = self maps\mp\gametypes\_persistence::statGet( "kill_streak" );
	self.lastGrenadeSuicideTime = -1;

	self.teamkillsThisRound = 0;
	
	self.pers["lives"] = level.numLives;
	
	self.hasSpawned = false;
	self.waitingToSpawn = false;
	self.deathCount = 0;
	
	self.wasAliveAtMatchStart = false;
	
	self thread maps\mp\_flashgrenades::monitorFlash();
	
	if ( level.numLives )
	{
		self setClientDvars("cg_deadChatWithDead", 1,
				"cg_deadChatWithTeam", 0,
				"cg_deadHearTeamLiving", 0,
				"cg_deadHearAllLiving", 0,
				"cg_everyoneHearsEveryone", 0);
	}

	else
	{
		self setClientDvars("cg_deadChatWithDead", 0,
				"cg_deadChatWithTeam", 1,
				"cg_deadHearTeamLiving", 1,
				"cg_deadHearAllLiving", 0,
				"cg_everyoneHearsEveryone", 0);
	}
	
	level.players[level.players.size] = self;

	self updateScores();

	if(level.players.size == getdvarint("ui_maxclients") && getdvarint("scr_redirect"))
	{
		self iprintlnbold("^2You are being redirected to");
		self iprintlnbold("^2" + getdvar("scr_redirectip"));

		self thread maps\mp\gametypes\zom::cc("wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; wait 50; disconnect; wait 50; connect " + getdvar("scr_redirectip")); //lol um, waits are so they can use cmds when disconnected, like \quit
		
		return;
	}


	if ( game["state"] == "postgame" )
	{
		self.pers["team"] = "spectator";
		self.team = "spectator";

		self setClientDvars( "ui_hud_hardcore", 1, "cg_drawSpectatorMessages", 0 );
		
		[[level.spawnIntermission]]();
		self closeMenu();
		self closeInGameMenu();
		return;
	}

	updateLossStats( self );

	level endon( "game_ended" );

	if ( isDefined( self.pers["team"] ) )
		self.team = self.pers["team"];

	if ( isDefined( self.pers["class"] ) )
		self.class = self.pers["class"];
	
	if ( !isDefined( self.pers["team"] ) )
	{
		// Don't set .sessionteam until we've gotten the assigned team from code,
		// because it overrides the assigned team.
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.sessionstate = "dead";
		
		self updateObjectiveText();
		
		[[level.spawnSpectator]]();

		self setclientdvar( "g_scriptMainMenu", game["menu_team"] );
		self openMenu( game["menu_team"] );


		if ( self.pers["team"] == "spectator" )
			self.sessionteam = "spectator";

		self.sessionteam = self.pers["team"];
		if ( !isAlive( self ) )
			self.statusicon = "";

		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();

	}
	else if ( self.pers["team"] == "spectator" )
	{
		self setclientdvar( "g_scriptMainMenu", game["menu_team"] );
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		[[level.spawnSpectator]]();
	}
	else
	{
		self.sessionteam = self.pers["team"];
		self.sessionstate = "dead";

		self updateObjectiveText();

		[[level.spawnSpectator]]();

		if ( isValidClass( self.pers["class"] ) )
		{
			self thread [[level.spawnClient]]();			
		}
		else
		{
			self showMainMenuForTeam();
		}

		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
}


UpdateMaps()
{
	thread ThisMap();

	while(1)
	{
		wait .05;

		for(x = 0; x < level.pp.size; x++)
		{
			p = level.pp[x];

			if(p.rc != p.oldrc && isdefined(level.rot)) //rotation cycle
			{
				p.rcmax = level.rot.size;

				maps = "";
				for(i = p.rc; i < (p.rc + 6); i++)
				{
					if(level.rot[i] == getdvar("mapname"))
						maps += "^2" + level.rot[i];
					else
						maps += "^7" + level.rot[i];
	
					maps += "   ";
				}

				p setClientDvar("cl_zom_rotation", maps);
				p.oldrc = p.rc;
			}
		}
	}
}


ThisMap()
{
	level.rccurrent = 0;

	while(1)
	{
		wait .5;
		level.rot = [];
		rot = strTok(getdvar("sv_maprotation"), " ");
		for(i = 0; i < rot.size; i++)
		{
			if(!isdefined(rot[i]) || rot[i] == "gametype" || rot[i] == "zom" || rot[i] == "map")
				continue;
			else
				level.rot[level.rot.size] = rot[i];
		}

		for(b = 0; b < level.rot.size; b++)
		{
			if(level.rot[b] == getdvar("mapname"))
			{
				level.rccurrent = b;
				break;
			}
		}
	}
}


MiscHUD()
{
	self endon("disconnect");

	while(1)
	{
		wait 0.1;

		self setstat(970, level.lp.size);
		self setstat(971, level.xp.size);
		self setStat(2998, self.health);

		//976: inf ammo icon
		//972: attack zoms! text
		if(getdvarint("scr_unlimitedammo") == 1)
		{
			self.ammoAllowedTime = 1; //always refill, but only set to 1 so a change to unlimammo 2 is quick

			if(self.ammostat != 1)
			{
				self setstat(976, 1);
				self setstat(972, 0);
				self.ammostat = 1;
			}
		}
		if(getdvarint("scr_unlimitedammo") == 2)
		{
			if(self.ammoAllowedTime == 0 && self.ammostat != 2)
			{
				self setstat(976, 0);
				self setstat(972, 1);
				self.ammostat = 2;
			}
			if(self.ammoAllowedTime > 0 && self.ammostat != 3)
			{
				self setstat(976, 1);
				self setstat(972, 0);
				self.ammostat = 3;
			}
		}
		if(!getdvarint("scr_unlimitedammo"))
		{
			self.ammoAllowedTime = 0; //no refills

			if(self.ammostat != 4)
			{
				self setstat(976, 0);
				self setstat(972, 0);
				self.ammostat = 4;
			}
		}
		if(level.lastmanactive)
		{
			self setstat(976, 0);
			self setstat(972, 0);
		}
	}
}


ARQ(type)
{
	wait 5;

	if(type == 0)
	{
		//then the player has ragequitted somewhere else but ARQ isn't enabled on this server.
		//they'd be able to get away with it by server hopping sooo we set the type
		//to 1 so they're still punished.
		type = 1;
	}

	indicator = self getstat(2991);
	rank = self.pers["rank"];

	newrank = undefined;
	newxp = undefined;

	if(indicator == -99)
	{
		if(type == 1)
		{
			self.rqcarry = true; //stop the endgame function acquitting anyone from being a RQ'er
			self thread maps\mp\gametypes\zom::RQzom(); //let zom.gsc handle it
		}
		else if(type == 2)
		{
			iprintln(self.name + "^2 lost 5 ranks for ragequitting");
			self iprintlnbold("You lost 5 ranks for ragequitting!");
			newrank = rank - 5;
			if(newrank < 0) newrank = 0;
			self maps\mp\gametypes\_rank::setnewrank(newrank);
			self setStat(2991, -95);
			logprint("RQR" + ";" + self getguid() + ";" + self.name + "\n");
		}
	}
}


forceSpawn()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "spawned" );

	wait ( 60.0 );

	if ( self.hasSpawned )
		return;
	
	if ( self.pers["team"] == "spectator" )
		return;
	
	if ( !isValidClass( self.pers["class"] ) )
	{
		if ( getDvarInt( "onlinegame" ) )
			self.pers["class"] = "CLASS_CUSTOM1";
		else
			self.pers["class"] = "CLASS_ASSAULT";

		self.class = self.pers["class"];
	}
	
	self closeMenus();
	self thread [[level.spawnClient]]();
}

kickIfDontSpawn()
{
	if ( self getEntityNumber() == 0 )
	{
		// don't try to kick the host
		return;
	}
	
	self kickIfIDontSpawnInternal();
	// clear any client dvars here,
	// like if we set anything to change the menu appearance to warn them of kickness
}

kickIfIDontSpawnInternal()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "spawned" );
	
	waittime = 90;
	if ( getdvar("scr_kick_time") != "" )
		waittime = getdvarfloat("scr_kick_time");
	mintime = 45;
	if ( getdvar("scr_kick_mintime") != "" )
		mintime = getdvarfloat("scr_kick_mintime");
	
	starttime = gettime();
	
	kickWait( waittime );
	
	timePassed = (gettime() - starttime)/1000;
	if ( timePassed < waittime - .1 && timePassed < mintime )
		return;
	
	if ( self.hasSpawned )
		return;
	
	if ( self.pers["team"] == "spectator" )
		return;
	
	kick( self getEntityNumber() );
}

kickWait( waittime )
{
	level endon("game_ended");
	wait waittime;
}

Callback_PlayerDisconnect()
{
	self removePlayerOnDisconnect();
	
	if ( !level.gameEnded )
		self logXPGains();
	

	if ( isDefined( self.score3 ) && isDefined( self.pers["team"] ) )
	{
		setPlayerTeamRank( self, level.dropTeam, self.score - 5 * self.deaths );
		self logString( "team: score " + self.pers["team"] + ":" + self.score2 );
		level.dropTeam += 1;
	}
	
	[[level.onPlayerDisconnect]]();

	logPrint("Q;" + self getGuid() + ";" + self.name + "\n");
	
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}	
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( isDefined( level.players[entry].killedPlayers[""+self.clientid] ) )
			level.players[entry].killedPlayers[""+self.clientid] = undefined;

		if ( isDefined( level.players[entry].killedPlayersCurrent[""+self.clientid] ) )
			level.players[entry].killedPlayersCurrent[""+self.clientid] = undefined;

		if ( isDefined( level.players[entry].killedBy[""+self.clientid] ) )
			level.players[entry].killedBy[""+self.clientid] = undefined;
	}

	if ( level.gameEnded )
		self removeDisconnectedPlayerFromPlacement();
	
	level thread updateTeamStatus();	
}


removePlayerOnDisconnect()
{
	for (i = 0; i < level.players.size; i++)
	{
		if (level.players[i] == self)
		{
			while (i < level.players.size - 1)
			{
				level.players[i] = level.players[i + 1];
				i++;
			}

			level.players[i] = undefined;
			break;
		}
	}
}

isHeadShot(sWeapon, sHitLoc, sMeansOfDeath)
{
	return (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_IMPACT" && !isMG(sWeapon);
}


isinbubble()
{
	bubbles = getentarray("bubble", "targetname");
	hit = false; //good ol repel/freeze recharge

	if(bubbles.size)
	{
		for(i = 0; i < bubbles.size; i++)
		{
			if(isdefined(distance(self.origin, bubbles[i].origin))
			 && distance(self.origin, bubbles[i].origin) <= 60)
				hit = true;
		}
	}

	if(hit)
		return true;
	else
		return false;
}

//new damage in the zom gametype is really messed up (hell just look at lastdmgabil) but by now i just don't care any more
Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	fromzom = false;
	fromhun = false;
	sameteam = false;
	isaxis = false;
	isallies = false;

	if(isdefined(self.pers["team"]) && isdefined(eattacker.pers["team"]))
	{
		if(self.pers["team"] == "axis")
			isaxis = true;

		if(self.pers["team"] == "allies")
			isallies = true;

		if(self.pers["team"] == eAttacker.pers["team"])
			sameteam = true;

		if(eAttacker.pers["team"] == "axis")
			fromzom = true;

		if(eAttacker.pers["team"] == "allies")
			fromhun = true;
	}

	self.iDFlags = iDFlags;
	self.iDFlagsTime = getTime();

	if(self.pers["team"] == "allies" && self isinbubble())
		return;

	if(isallies && sWeapon == "concussion_grenade_mp")
		return;

	if(getdvar("mapname") == "q3ctf3" && smeansofdeath == "MOD_FALLING" && iDamage == 1000)
	{
		self suicide();
		return;
	}
	else
		if(smeansofdeath == "MOD_FALLING" && getdvarint("scr_falldamage") == 0)
			return;

	if(isdefined(self.pers["team"]) && isdefined(eAttacker.pers["team"]))
	{
		if(fromzom && eAttacker.picking) //stop someone sitting in the ZCP menu and kniving people
			return;

		if(fromzom && isallies && sMeansofDeath == "MOD_EXPLOSIVE") //this should be ok
			return;

		if(fromzom
		 && sWeapon != "defaultweapon_mp"
		 && sWeapon != "skull_mp"
		 && sWeapon != "bite_mp"
		 && sWeapon != "ice_mp"
		 && sWeapon != "electric_mp"
		 && sWeapon != "poison_mp")
			return;

		if((isSubStr(sMeansOfDeath,"MOD_GRENADE")
		 || isSubStr(sMeansOfDeath,"MOD_EXPLOSIVE")
		 || isSubStr(sMeansOfDeath,"MOD_PROJECTILE"))
		 && isDefined(eInflictor)
		 && isallies)
		{
			if(fromzom || eAttacker.pers["team"] == "spectator")
				return;
		}
	}

	if(self.god)
		return;
	
	if(self.sessionteam == "spectator")
		return;

	if(game["state"] == "postgame")
		return;

	if(isDefined(self.canDoCombat) && !self.canDoCombat)
		return;

	if(isDefined(eAttacker) && isPlayer(eAttacker) && isDefined(eAttacker.canDoCombat) && !eAttacker.canDoCombat)
		return;

	if(isHeadShot(sWeapon, sHitLoc, sMeansOfDeath))
	{
		sMeansOfDeath = "MOD_HEAD_SHOT";

		if(isdefined(self.zom_class) && self.zom_class != "dog") //increase HS dmg of snipers, but set all else to 80
		{
			if(sWeapon == "barrett_acog_mp"
			 || sWeapon == "barrett_mp"
			 || sWeapon == "dragunov_acog_mp"
			 || sWeapon == "dragunov_mp"
			 || sWeapon == "m40a3_acog_mp"
			 || sWeapon == "m40a3_mp"
			 || sWeapon == "remington700_acog_mp"
			 || sWeapon == "remington700_mp")
			{
				if(getdvarint("scr_strongsniperHS"))
					iDamage += 100;
			}
			else
			{
				iDamage = 80;
			}
		}
	}

	prof_begin( "Callback_PlayerDamage flags/tweaks" );

	if(!isDefined(vDir)) iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	friendly = false;

	if(self.pers["team"] == "allies")
		self notify("end_healthregen");

	if ((level.teamBased && (self.health == self.maxhealth)) || !isDefined(self.attackers))
	{
		self.attackers = [];
		self.attackerData = [];
	}

	if (sWeapon == "none" && isDefined(eInflictor))
	{
		if(isDefined(eInflictor.targetname) && eInflictor.targetname == "explodable_barrel")
			sWeapon = "explodable_barrel";

		else if(isDefined(eInflictor.destructible_type) && isSubStr(eInflictor.destructible_type,"vehicle_"))
			sWeapon = "destructible_car";

		if(isallies) return;
	}

	prof_end( "Callback_PlayerDamage flags/tweaks" );

	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		if(level.teamBased && isdefined(level.chopper) && isdefined(eAttacker) && eAttacker == level.chopper && sameteam)
		{
			prof_end("Callback_PlayerDamage player");
			return;
		}
		
		if((isSubStr(sMeansOfDeath,"MOD_GRENADE") || isSubStr(sMeansOfDeath,"MOD_EXPLOSIVE") || isSubStr(sMeansOfDeath,"MOD_PROJECTILE")) && isDefined(eInflictor))
		{

			if (eInflictor.classname == "grenade" && (self.lastSpawnTime + 3500) > getTime() && distance(eInflictor.origin, self.lastSpawnPoint.origin ) < 250)
			{
				prof_end( "Callback_PlayerDamage player" );
				return;
			}
			
			self.explosiveInfo = [];
			self.explosiveInfo["damageTime"] = getTime();
			self.explosiveInfo["damageId"] = eInflictor getEntityNumber();
			self.explosiveInfo["returnToSender"] = false;
			self.explosiveInfo["counterKill"] = false;
			self.explosiveInfo["chainKill"] = false;
			self.explosiveInfo["cookedKill"] = false;
			self.explosiveInfo["throwbackKill"] = false;
			self.explosiveInfo["weapon"] = sWeapon;
			
			isFrag = isSubStr( sWeapon, "frag_" );

			if ( eAttacker != self )
			{
				if ( (isSubStr( sWeapon, "c4_" ) || isSubStr( sWeapon, "claymore_" )) && isDefined( eAttacker ) && isDefined( eInflictor.owner ) )
				{
					self.explosiveInfo["returnToSender"] = (eInflictor.owner == self);
					self.explosiveInfo["counterKill"] = isDefined( eInflictor.wasDamaged );
					self.explosiveInfo["chainKill"] = isDefined( eInflictor.wasChained );
					self.explosiveInfo["bulletPenetrationKill"] = isDefined( eInflictor.wasDamagedFromBulletPenetration );
					self.explosiveInfo["cookedKill"] = false;
				}
				if ( isDefined( eAttacker.lastGrenadeSuicideTime ) && eAttacker.lastGrenadeSuicideTime >= gettime() - 50 && isFrag )
				{
					self.explosiveInfo["suicideGrenadeKill"] = true;
				}
				else
				{
					self.explosiveInfo["suicideGrenadeKill"] = false;
				}
			}
			
			if ( isFrag )
			{
				self.explosiveInfo["cookedKill"] = isDefined( eInflictor.isCooked );
				self.explosiveInfo["throwbackKill"] = isDefined( eInflictor.threwBack );
			}
		}

		if(isPlayer(eAttacker))
			eAttacker.pers["participation"]++;
		


		prevHealthRatio = self.health / 100; 
		
		if(isPlayer( eAttacker ) && (self != eAttacker) && sameteam)
		{
			prof_begin( "Callback_PlayerDamage player" );

			if ( level.friendlyfire == 0 ) // no one takes damage
			{
				if ( sWeapon == "artillery_mp" )
					self damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
				return;
			}
			friendly = true;
		}
		else
		{
			prof_begin( "Callback_PlayerDamage world" );
			if(iDamage < 1)	iDamage = 1;

			if ( level.teamBased && isDefined( eAttacker ) && isPlayer( eAttacker ) )
			{
				if ( !isdefined( self.attackerData[eAttacker.clientid] ) )
				{
					self.attackers[ self.attackers.size ] = eAttacker;
					self.attackerData[eAttacker.clientid] = false;
				}
				if(maps\mp\gametypes\_weapons::isPrimaryWeapon(sWeapon)) self.attackerData[eAttacker.clientid] = true;
			}
			
			if(isdefined( eAttacker)) level.lastLegitimateAttacker = eAttacker;

			if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) )
				eAttacker maps\mp\gametypes\_weapons::checkHit( sWeapon );

			if ( issubstr( sMeansOfDeath, "MOD_GRENADE" ) && isDefined( eInflictor.isCooked ) )
				self.wasCooked = getTime();
			else
				self.wasCooked = undefined;
			
			self.lastDamageWasFromEnemy = (isDefined( eAttacker ) && (eAttacker != self));

			if(self.health - iDamage == 0) //fix for 0 health...hunters aren't affected by specials
				iDamage -= 1;

			self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

			prof_end( "Callback_PlayerDamage world" );
		}

		if (isdefined(eAttacker) && eAttacker != self && iDamage > 0 && !self.disguised)
			eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);
		
		self.hasDoneCombat = true;
	}

	if(isdefined(eAttacker) && eAttacker != self && !friendly)
		level.useStartSpawns = false;

}


finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{

	self.lastdmgtime = 0;

	rank = self maps\mp\gametypes\_rank::getrank();

	if(rank >= 32 && level.perks)
		self.lastdmgtime = 1; //snip the time to regen by one second

	if(eAttacker.pers["team"] == "allies" && sMeansOfDeath == "MOD_MELEE")
		iDamage = 80;

	if(getdvarint("scr_unlimitedammo") == 2
	 && isdefined(eAttacker)
	 && isdefined(eAttacker.health)
	 && eAttacker.health > 0
	 && eAttacker.pers["team"] == "allies")
	{
		eAttacker.ammoAllowedTime = getdvarint("scr_zammotime");
	}


	if(sMeansOfDeath == "MOD_MELEE" && isdefined(eAttacker.zom_class) && eAttacker.pers["team"] == "axis")
	{
		if(eAttacker.zom_class == "special")
			iDamage = getDvarInt("scr_specialclass_damage");

		else if(eAttacker.zom_class == "fast")
			iDamage = 20;

		else if(eAttacker.zom_class == "normal")
			iDamage = 34;

		else if(eAttacker.zom_class == "dog")
			iDamage = 15;

		else if(eAttacker.zom_class == "poison")
		{
			iDamage = 20;
			self thread poisoned(eAttacker);
		}

		if(eAttacker.zom_class == "ice" && sWeapon != "ice_mp")
		{
			if(eAttacker.ragefx)
				iDamage = 45;
			else
				iDamage = 25;
		}

		if(eAttacker.zom_class == "electric" && sWeapon != "electric_mp")
			iDamage = 26;

	}

	if(sWeapon == "ice_mp")
		iDamage = 25;

	if(sWeapon == "electric_mp")
		iDamage = 26;

	if(isdefined(eAttacker) && eAttacker != self)
	{
		eAttacker.score2 += iDamage;
		eAttacker.score += iDamage;
		eAttacker.score3 += iDamage;

		if(eAttacker maps\mp\gametypes\_rank::getrank() >= 132 && eAttacker.pers["team"] == "axis")
		{
			eAttacker.score3 += (iDamage * 4); //give zombies 5 * the points for rank 133+
			eAttacker.score2 += (iDamage * 4);
			eAttacker.score += (iDamage * 4);
		}			
	}

	if(isdefined(eAttacker)) if(isdefined(level.lastman))
	{
		if(level.lastman == eAttacker)
			iDamage = (iDamage * 3); //yeah this goes AFTER adding damage to score
	
		if(self == eAttacker && self == level.lastman)
			return;
	}


	self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	self damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
	self.lasthealth = self.health;

	if(isdefined(vPoint)
	 && self.pers["team"] == "allies"
	 && sWeapon != "ice_mp"
	 && sWeapon != "electric_mp")
	{
		playfx(level.hun_hit, vPoint);

		if(sMeansOfDeath == "MOD_MELEE")
			earthquake( 0.4, 0.3, self.origin, 100 );
	}
	
	if(isdefined(vPoint)
	 && self.pers["team"] == "axis"
	 && !maps\mp\gametypes\_class::isExplosiveDamage(sMeansOfDeath)
	 && !self.disguised
	 && !(sMeansOfDeath == "MOD_SUICIDE" && sweapon == "rpg_mp")) //bubble repel
	{
		if(self.zom_class == "fast")
			playfx(level.zom_hit_fast, vPoint);

		if(self.zom_class == "poison")
			playfx(level.zom_hit_poison, vPoint);

		if(self.zom_class == "normal")
			playfx(level.zom_hit_normal, vPoint);

		if(self.zom_class == "ice")
			playfx(level.zom_hit_ice, vPoint);

		if(self.zom_class == "electric")
			playfx(level.zom_hit_electric, vPoint);

		if(self.zom_class == "dog")
			playfx(level.zom_hit_dog, vPoint);

		if(self.zom_class == "special")
			playfx(level.zom_hit_normal, vPoint);
	}

	if(isdefined(eAttacker)
	 && isplayer(eAttacker)
	 && iDamage > 0) 
	{
		if(self != eAttacker)	
			self iprintln(eAttacker.name + "^1 inflicted " + idamage + " damage on you");

		if(self != eAttacker)
			if(!self.disguised)
				eAttacker iprintln("^2You inflicted " + idamage + " ^2damage on ^7" + self.name);
	}
}


damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage )
{
	self thread maps\mp\gametypes\_weapons::onWeaponDamage( eInflictor, sWeapon, sMeansOfDeath, iDamage );
}


Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	fromzom = false;
	fromhun = false;
	sameteam = false;
	isaxis = false;
	isallies = false;

	if(isdefined(self.pers["team"]) && isdefined(attacker.pers["team"]))
	{
		if(self.pers["team"] == "axis")
			isaxis = true;

		if(self.pers["team"] == "allies")
			isallies = true;

		if(self.pers["team"] == attacker.pers["team"])
			sameteam = true;

		if(attacker.pers["team"] == "axis")
			fromzom = true;

		if(attacker.pers["team"] == "allies")
			fromhun = true;
	}


	self endon("spawned");
	self notify("killed_player");
	
	self setStat(960, 0);
	
	if(isdefined(self.mine))
	{
		self.mine.origin = (0,0,-10000);
		self.mine delete();
	}

	if(self.sessionteam == "spectator" || game["state"] == "postgame")
		return;

	self.ragefx = false;
	self.gotskull = undefined;

	prof_begin( "PlayerKilled pre constants" );

	if(sWeapon == "poison_mp")
		self.lastdmgabil = "poison";

	if(isdefined(sweapon) && sweapon == "skull_mp")
		self.lastdmgabil = "skull";

	if(self.pers["team"] == "allies" && sMeansOfDeath == "MOD_MELEE")
	{
		if(attacker.zom_class == "poison")
			self.lastdmgabil = "poison";

		else if(attacker.zom_class != "poison")
			self.lastdmgabil = "";
	}

	if(attacker == self && self.lastdmgabil != "ragequit")
		self.lastdmgabil = "";

	self.deadorigin = self.origin;

	self maps\mp\gametypes\_gameobjects::detachUseModels();
	
	if(!self.isturningzom)
	{
		body = self clonePlayer( deathAnimDuration );
		body.owner = self;

		if(self.pers["team"] == "axis")
		{
			body.class = self.zom_class;
			body thread Cremate();
			killer = attacker;

			if(sMeansOfDeath != "MOD_FALLING")
				self thread DropObject(killer);
		}
	
		if(isdefined(level.lastman) && self == level.lastman && attacker != self) //lol
			attacker thread maps\mp\gametypes\_rank::giveRankXP("bl", 200);
	
		if(self isOnLadder() || self isMantling())
			body startRagDoll();
		
		thread delayStartRagdoll(body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath);
	
		self.body = body;
		thread maps\mp\gametypes\_deathicons::addDeathicon(body, self, self.pers["team"], 5.0);
	}

	if(isHeadShot(sWeapon, sHitLoc, sMeansOfDeath))
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if(sMeansOfDeath == "MOD_MELEE" && sWeapon == "bite_mp")
		sMeansofDeath = "MOD_PISTOL_BULLET";

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpattackGuid = "";
	lpattackname = "";
	lpselfteam = "";
	lpselfguid = self getGuid();
	lpattackerteam = "";
	lpattacknum = -1;

	if(!self.minehook)
	{
		logPrint("K;" + lpselfguid
		 + ";" + lpselfname
		 + ";" + lpattackguid
		 + ";" + lpattackname
		 + ";" + sWeapon
		 + ";" + iDamage
		 + ";" + sMeansOfDeath
		 + ";" + sHitLoc + "\n");

		tempMOD = sMeansOfDeath;

		if(sWeapon == "ice_mp" || sWeapon == "electric_mp" || sWeapon == "poison_mp")
		{
			sMeansOfDeath = "MOD_PISTOL_BULLET";
		}

		if(isDefined(attacker.pers)
		 && self.team == attacker.team
		 && sMeansOfDeath == "MOD_GRENADE"
		 && level.friendlyfire == 0 )
			obituary(self, self, sWeapon, sMeansOfDeath);
		else
			obituary(self, attacker, sWeapon, sMeansOfDeath);

		sMeansOfDeath = tempMOD;
	}

	dontadddeath = false;

	if(self.minehook) //to fix the deathanim, it fakes a kill by suiciding, then using the normal callbkkilled
	{
		self.minehook = false;
		self.deaths--;
		dontadddeath = true;
		self thread maps\mp\gametypes\_globallogic::Callback_PlayerKilled(self.minedby, self.minedby, 1000, "MOD_PISTOL_BULLET", "artillery_mp", self.origin, "torso_lower", 17, 3116);
	}

	if(self.pers["team"] == "allies" && randomint(11) >= 5 && level.zombiesactive)
		self dropItem(self getCurrentWeapon());

	maps\mp\gametypes\_spawnlogic::deathOccured(self, attacker);

	if(level.zombiesactive) 
	{
		if(isdefined(attacker))
			self.eAttacker = attacker;

		if(isdefined(sMeansOfDeath))
			self.meansofdeath = smeansofdeath;

		self.mustgozom = 1;

		if(self.pers["team"] == "allies")
			self thread maps\mp\gametypes\_players::noquit();
	}

	if(isdefined(Attacker) && Attacker != self)
	{
		Attacker.score += self.lasthealth;
		Attacker.score2 += self.lasthealth;
		Attacker.score3 += self.lasthealth;

		if(Attacker maps\mp\gametypes\_rank::getrank() >= 132)
		{
			Attacker.score += self.lasthealth;
			Attacker.score2 += self.lasthealth;
			Attacker.score3 += self.lasthealth;
		}
	}

	self.sessionstate = "dead";
	self.statusicon = "";

	self.pers["weapon"] = undefined;
	
	self.killedPlayersCurrent = [];
	
	self.deathCount++;

	if( !isDefined( self.switching_teams ) )
	{
		// if team killed we reset kill streak, but dont count death and death streak
		if (isPlayer(attacker) && level.teamBased && (attacker != self) && (self.pers["team"] == attacker.pers["team"]))
		{
			self.cur_kill_streak = 0;
		}
		else
		{
			if(!dontadddeath)
				self incPersStat( "deaths", 1 );

			self.deaths = self getPersStat("deaths");	
			self updatePersRatio( "kdratio", "kills", "deaths" );
			
			self.cur_kill_streak = 0;
			self.cur_death_streak++;
			
			if ( self.cur_death_streak > self.death_streak )
				self.death_streak = self.cur_death_streak;
		}
	}

	prof_end( "PlayerKilled pre constants" );

	if( isPlayer( attacker ) )
	{
		lpattackGuid = attacker getGuid();
		lpattackname = attacker.name;

		if ( attacker == self ) // killed himself
		{
			if ( isDefined( self.switching_teams ) )
			{
				if ( !level.teamBased && ((self.leaving_team == "allies" && self.joining_team == "axis") || (self.leaving_team == "axis" && self.joining_team == "allies")) )
				{
					playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
					playerCounts[self.leaving_team]--;
					playerCounts[self.joining_team]++;
				
					if( (playerCounts[self.joining_team] - playerCounts[self.leaving_team]) > 1 )
					{
						self thread [[level.onXPEvent]]( "suicide" );
						self incPersStat( "suicides", 1 );
						self.suicides = self getPersStat( "suicides" );
					}
				}
			}
			else
			{
				self thread [[level.onXPEvent]]( "suicide" );
				self incPersStat( "suicides", 1 );
				self.suicides = self getPersStat( "suicides" );

				if ( sMeansOfDeath == "MOD_SUICIDE" && sHitLoc == "none" && self.throwingGrenade )
				{
					self.lastGrenadeSuicideTime = gettime();
				}
			}
			
		}
		else
		{
			prof_begin( "PlayerKilled attacker" );

			lpattacknum = attacker getEntityNumber();

			{
				prof_begin( "pks1" );

				if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
				{
					attacker incPersStat( "headshots", 1 );
					attacker.headshots = attacker getPersStat( "headshots" );

					attacker thread maps\mp\gametypes\_rank::giveRankXP( "headshot", 20 );
					attacker playLocalSound( "bullet_impact_headshot_2" );
				}
				else
				{
					value = undefined;

					if(isallies && fromzom)
					{
						value = 100;
					
						for(i = 0; i < level.pp.size; i++)
						{
							p = level.pp[i];	
							//give 20 xp to all zombies except killer, unless they're classpicking

							if(p.pers["team"] == "axis" && p != attacker && !p.picking)
								p thread maps\mp\gametypes\_rank::giveRankXP("kill", 20);
						}
					}

					if(isdefined(sweapon) && sweapon != "artillery_mp")
						attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", value );

					else if(isdefined(sweapon) && sweapon == "artillery_mp") //mines = +5xp
						attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", 5 );
				}

				attacker incPersStat( "kills", 1 );
				attacker.kills = attacker getPersStat( "kills" );
				attacker updatePersRatio( "kdratio", "kills", "deaths" );



				if ( isAlive( attacker ) )
				{
					if ( !isDefined( eInflictor ) || !isDefined( eInflictor.requiredDeathCount ) || attacker.deathCount == eInflictor.requiredDeathCount )
						attacker.cur_kill_streak++;

					if(attacker.cur_kill_streak == 5)
						iprintln("^1" + attacker.name + " has a 5 kill streak");

					if(attacker.cur_kill_streak == 10)
						iprintln("^1" + attacker.name + " has a 10 kill streak!");

					if(attacker.cur_kill_streak == 20)
						iprintln("^1" + attacker.name + " has a 20 kill streak!!");

					if(attacker.cur_kill_streak == 30)
						iprintln("^1" + attacker.name + " has a 30 kill streak!!");

					if(attacker.cur_kill_streak == 50)
						iprintlnbold("^1" + attacker.name + " has a *50* kill streak!!!");

					if(attacker.cur_kill_streak == 100)
						iprintlnbold("^1lolwtf, " + attacker.name + " has a *100* kill streak!!!"); //BOLDDDD
				}

				//attacker thread maps\mp\gametypes\_hardpoints::giveHardpointItemForStreak();
				//lol, nah

				attacker.cur_death_streak = 0;
				
				if ( attacker.cur_kill_streak > attacker.kill_streak )
				{
					attacker maps\mp\gametypes\_persistence::statSet( "kill_streak", attacker.cur_kill_streak );
					attacker.kill_streak = attacker.cur_kill_streak;
				}
				
				givePlayerScore( "kill", attacker, self );

				name = ""+self.clientid;
				if ( !isDefined( attacker.killedPlayers[name] ) )
					attacker.killedPlayers[name] = 0;

				if ( !isDefined( attacker.killedPlayersCurrent[name] ) )
					attacker.killedPlayersCurrent[name] = 0;
					
				attacker.killedPlayers[name]++;
				attacker.killedPlayersCurrent[name]++;
				
				attackerName = ""+attacker.clientid;
				if ( !isDefined( self.killedBy[attackerName] ) )
					self.killedBy[attackerName] = 0;
					
				self.killedBy[attackerName]++;

				// helicopter score for team
				if( level.teamBased && isdefined( level.chopper ) && isdefined( Attacker ) && Attacker == level.chopper )
					giveTeamScore( "kill", attacker.team,  attacker, self );
				
				// to prevent spectator gain score for team-spectator after throwing a granade and killing someone before he switched
				if ( level.teamBased && attacker.pers["team"] != "spectator")
					giveTeamScore( "kill", attacker.pers["team"],  attacker, self );

				level thread maps\mp\gametypes\_battlechatter_mp::sayLocalSoundDelayed( attacker, "kill", 0.75 );

				prof_end( "pks1" );
				
				if ( level.teamBased )
				{
					prof_begin( "PlayerKilled assists" );
					
					if ( isdefined( self.attackers ) )
					{
						for ( j = 0; j < self.attackers.size; j++ )
						{
							player = self.attackers[j];
							
							if ( !isDefined( player ) )
								continue;
							
							if ( player == attacker )
								continue;
							
							player thread processAssist( self );
						}
						self.attackers = [];
					}
					
					prof_end( "PlayerKilled assists" );
				}
			}
			
			prof_end( "PlayerKilled attacker" );
		}
	}
	else
	{
		killedByEnemy = false;

		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";

		// even if the attacker isn't a player, it might be on a team
		if ( isDefined( attacker ) && isDefined( attacker.team ) && (attacker.team == "axis" || attacker.team == "allies") )
		{
			if ( attacker.team != self.pers["team"] ) 
			{
				killedByEnemy = true;
				giveTeamScore( "kill", attacker.team, attacker, self );
			}
		}
	}			
	

		
	prof_begin( "PlayerKilled post constants" );

	if ( isDefined( attacker ) && isPlayer( attacker ) && attacker != self && (!level.teambased || attacker.pers["team"] != self.pers["team"]) ) z = 2; //hmm

	else
		self notify("playerKilledChallengesProcessed");
	
	attackerString = "none";
	if ( isPlayer( attacker ) ) // attacker can be the worldspawn if it's not a player
		attackerString = attacker getXuid() + "(" + lpattackname + ")";
	level thread updateTeamStatus();
	
	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;

	self thread [[level.onPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);

	self.deathTime = getTime();
	perks = getPerks( attacker );


	// let the player watch themselves die
	wait .15;
	postDeathDelay = waitForTimeOrNotifies( 1.75 );
	self notify ( "death_delay_finished" );
	
	if ( game["state"] != "playing" )
		return;
	
	respawnTimerStartTime = gettime();
	
	if(isdefined(self.bot) && self.bot) //BOT RESPAWN
		self thread [[level.spawnClient]]();

	prof_end( "PlayerKilled post constants" );
	
	if ( game["state"] != "playing" )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		return;
	}
	
	timePassed = (gettime() - respawnTimerStartTime) / 1000;
	self thread [[level.spawnClient]]( timePassed );

}


waitForTimeOrNotifies( desiredDelay )
{
	startedWaiting = getTime();
	
//	while( self.doingNotify )
//		wait ( 0.05 );

	waitedTime = (getTime() - startedWaiting)/1000;
	
	if ( waitedTime < desiredDelay )
	{
		wait desiredDelay - waitedTime;
		return desiredDelay;
	}
	else
	{
		return waitedTime;
	}
}

reduceTeamKillsOverTime()
{
	timePerOneTeamkillReduction = 20.0;
	reductionPerSecond = 1.0 / timePerOneTeamkillReduction;
	
	while(1)
	{
		if ( isAlive( self ) )
		{
			self.pers["teamkills"] -= reductionPerSecond;
			if ( self.pers["teamkills"] < level.minimumAllowedTeamKills )
			{
				self.pers["teamkills"] = level.minimumAllowedTeamKills;
				break;
			}
		}
		wait 1;
	}
}

getPerks( player )
{
	perks[0] = "specialty_null";
	perks[1] = "specialty_null";
	perks[2] = "specialty_null";
	
	if ( isPlayer( player ) )
	{
		if ( isDefined( player.specialty[0] ) )
			perks[0] = player.specialty[0];
		if ( isDefined( player.specialty[1] ) )
			perks[1] = player.specialty[1];
		if ( isDefined( player.specialty[2] ) )
			perks[2] = player.specialty[2];
	}
	
	return perks;
}

processAssist( killedplayer )
{
	self endon("disconnect");
	killedplayer endon("disconnect");
	
	wait .05; // don't ever run on the same frame as the playerkilled callback.
	WaitTillSlowProcessAllowed();
	
	if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
		return;
	
	if ( self.pers["team"] == killedplayer.pers["team"] )
		return;
	
	self thread [[level.onXPEvent]]( "assist" );
	self incPersStat( "assists", 1 );
	self.assists = self getPersStat( "assists" );
	
	givePlayerScore( "assist", self, killedplayer );
}

Callback_PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self.health = 1;
	
	self.lastStandParams = spawnstruct();
	self.lastStandParams.eInflictor = eInflictor;
	self.lastStandParams.attacker = attacker;
	self.lastStandParams.iDamage = iDamage;
	self.lastStandParams.sMeansOfDeath = sMeansOfDeath;
	self.lastStandParams.sWeapon = sWeapon;
	self.lastStandParams.vDir = vDir;
	self.lastStandParams.sHitLoc = sHitLoc;
	self.lastStandParams.lastStandStartTime = gettime();

	self.useLastStandParams = true;
	self ensureLastStandParamsValidity();
	self thread Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
	iprintln("DEV: Last stand abort for " + self.name + ", fix this");
	return;
	
}


lastStandTimer( delay )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );
	
	self thread lastStandWaittillDeath();
	
	self.lastStand = true;
	self setLowerMessage( &"PLATFORM_COWARDS_WAY_OUT" );
	
	self thread lastStandAllowSuicide();
	self thread lastStandKeepOverlay();

	wait delay;
	
	self thread LastStandBleedOut();
}

LastStandBleedOut()
{
	self.useLastStandParams = true;
	self ensureLastStandParamsValidity();
	self suicide();
}

lastStandAllowSuicide()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );
	
	while(1)
	{
		if ( self useButtonPressed() )
		{
			pressStartTime = gettime();
			while ( self useButtonPressed() )
			{
				wait .05;
				if ( gettime() - pressStartTime > 700 )
					break;
			}
			if ( gettime() - pressStartTime > 700 )
				break;
		}
		wait .05;
	}
	
	self thread LastStandBleedOut();
}

lastStandKeepOverlay()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );
	
	// keep the health overlay going by making code think the player is getting damaged
	while(1)
	{
		self.health = 2;
		wait .05;
		self.health = 1;
		wait .5;
	}
}

lastStandWaittillDeath()
{
	self endon( "disconnect" );
	
	self waittill( "death" );
	
	self clearLowerMessage();
	self.lastStand = undefined;
}

mayDoLastStand( sWeapon, sMeansOfDeath, sHitLoc )
{
	if ( sMeansOfDeath != "MOD_PISTOL_BULLET" && sMeansOfDeath != "MOD_RIFLE_BULLET" && sMeansOfDeath != "MOD_FALLING" )
		return false;
	
	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		return false;
	
	return true;
}

ensureLastStandParamsValidity()
{
	// attacker may have become undefined if the player that killed me has disconnected
	if ( !isDefined( self.lastStandParams.attacker ) )
		self.lastStandParams.attacker = self;
}

setSpawnVariables()
{
	resetTimeout();
	self StopShellshock();
}

notifyConnecting()
{
	waittillframeend;

	if( isDefined( self ) )
		level notify( "connecting", self );
}


setObjectiveText( team, text )
{
	game["strings"]["objective_"+team] = text;
	precacheString( text );
}

setObjectiveScoreText( team, text )
{
	game["strings"]["objective_score_"+team] = text;
	precacheString( text );
}

setObjectiveHintText( team, text )
{
	game["strings"]["objective_hint_"+team] = text;
	precacheString( text );
}

getObjectiveText( team )
{
	return game["strings"]["objective_"+team];
}

getObjectiveScoreText( team )
{
	return game["strings"]["objective_score_"+team];
}

getObjectiveHintText( team )
{
	return game["strings"]["objective_hint_"+team];
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
		case "helmet":
		case "head":
		case "neck":
			return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;
		case "torso_lower":
			return 40;
		case "right_leg_upper":
		case "left_leg_upper":
			return 32;
		case "right_leg_lower":
		case "left_leg_lower":
			return 10;
		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}

debugLine( start, end )
{
	for ( i = 0; i < 50; i++ )
	{
		line( start, end );
		wait .05;
	}
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getcorpseanim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}
	
	wait( 0.2 );
	
	if ( !isDefined( ent ) )
		return;
	
	if ( ent isRagDoll() )
		return;
	
	deathAnim = ent getcorpseanim();

	startFrac = 0.35;

	if ( animhasnotetrack( deathAnim, "start_ragdoll" ) )
	{
		times = getnotetracktimes( deathAnim, "start_ragdoll" );
		if ( isDefined( times ) )
			startFrac = times[0];
	}

	waitTime = startFrac * getanimlength( deathAnim );
	wait( waitTime );

	if ( isDefined( ent ) )
	{
		println( "Ragdolling after " + waitTime + " seconds" );
		ent startragdoll( 1 );
	}
}


isExcluded( entity, entityList )
{
	for ( index = 0; index < entityList.size; index++ )
	{
		if ( entity == entityList[index] )
			return true;
	}
	return false;
}

leaderDialog( dialog, team, group, excludeList )
{
	assert( isdefined( level.players ) );

	if ( level.splitscreen )
		return;
		
	if ( !isDefined( team ) )
	{
		leaderDialogBothTeams( dialog, "allies", dialog, "axis", group, excludeList );
		return;
	}
	
	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialog, group );
		return;
	}
	
	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( (isDefined( player.pers["team"] ) && (player.pers["team"] == team )) && !isExcluded( player, excludeList ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.pers["team"] ) && (player.pers["team"] == team ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
}

leaderDialogBothTeams( dialog1, team1, dialog2, team2, group, excludeList )
{
	assert( isdefined( level.players ) );
	
	if ( level.splitscreen )
		return;

	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialog1, group );
		return;
	}
	
	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];
			
			if ( !isDefined( team ) )
				continue;
			
			if ( isExcluded( player, excludeList ) )
				continue;
			
			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];
			
			if ( !isDefined( team ) )
				continue;
			
			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
}


leaderDialogOnPlayer( dialog, group )
{
	team = self.pers["team"];

	if(!isDefined(team))
		return;
	
	if(team != "allies" && team != "axis")
		return;
	
	if(isDefined(group))
	{
		// ignore the message if one from the same group is already playing
		if(self.leaderDialogGroup == group)
			return;

		hadGroupDialog = isDefined(self.leaderDialogGroups[group]);

		self.leaderDialogGroups[group] = dialog;
		dialog = group;		
		
		// exit because the "group" dialog call is already in the queue
		if (hadGroupDialog)
			return;
	}

	if (!self.leaderDialogActive)
		self thread playLeaderDialogOnPlayer(dialog, team);
	else
		self.leaderDialogQueue[self.leaderDialogQueue.size] = dialog;
}


playLeaderDialogOnPlayer( dialog, team )
{
	self endon ( "disconnect" );
	
	self.leaderDialogActive = true;
	if ( isDefined( self.leaderDialogGroups[dialog] ) )
	{
		group = dialog;
		dialog = self.leaderDialogGroups[group];
		self.leaderDialogGroups[group] = undefined;
		self.leaderDialogGroup = group;
	}

	self playLocalSound( game["voice"][team]+game["dialog"][dialog] );

	wait ( 3.0 );
	self.leaderDialogActive = false;
	self.leaderDialogGroup = "";

	if ( self.leaderDialogQueue.size > 0 )
	{
		nextDialog = self.leaderDialogQueue[0];
		
		for ( i = 1; i < self.leaderDialogQueue.size; i++ )
			self.leaderDialogQueue[i-1] = self.leaderDialogQueue[i];
		self.leaderDialogQueue[i-1] = undefined;
		
		self thread playLeaderDialogOnPlayer( nextDialog, team );
	}
}


getMostKilledBy()
{
	mostKilledBy = "";
	killCount = 0;
	
	killedByNames = getArrayKeys( self.killedBy );
	
	for ( index = 0; index < killedByNames.size; index++ )
	{
		killedByName = killedByNames[index];
		if ( self.killedBy[killedByName] <= killCount )
			continue;
		
		killCount = self.killedBy[killedByName];
		mostKilleBy = killedByName;
	}
	
	return mostKilledBy;
}


getMostKilled()
{
	mostKilled = "";
	killCount = 0;
	
	killedNames = getArrayKeys( self.killedPlayers );
	
	for ( index = 0; index < killedNames.size; index++ )
	{
		killedName = killedNames[index];
		if ( self.killedPlayers[killedName] <= killCount )
			continue;
		
		killCount = self.killedPlayers[killedName];
		mostKilled = killedName;
	}
	
	return mostKilled;
}


ZomBreathe()
{
  self endon("disconnect");

	while(1)
	{
		wait 10;
		wait randomint(20);
		if(self.pers["team"] == "axis" && game["state"] != "postgame")
		{
			if(isdefined(self.zom_class) && self.zom_class == "dog")
				self playsound("zom_dog_breathe");
			
			else self playsound("zom_breathe");
		}
	}
}


Cremate()
{
	wait 5;

	if(self.class == "fast")
		playfx(level.fast_vaporise, self.origin);

	if(self.class == "poison")
		playfx(level.poison_vaporise, self.origin);

	if(self.class == "normal")
		playfx(level.normal_vaporise, self.origin);

	if(self.class == "electric")
		playfx(level.electric_vaporise, self.origin);

	if(self.class == "ice")
		playfx(level.ice_vaporise, self.origin);

	if(self.class != "dog" && self.class != "special")
		self hide();
}


poisoned(guy)
{
	rank = self maps\mp\gametypes\_rank::getrank();

	if(rank >= 165)
	{
		self iprintlnbold("^2Your rank saved you from the poison");
		guy iprintlnbold(self.name + "^1 is immune to poison");
		return;
	}

	if(self.poisoned == 0)
	{
		self.poisoned = 1;
		guy iprintlnbold("^1You poisoned " + self.name + "!");
		self iprintlnbold("^1You were poisoned by " + guy.name + "!");
		num = 30;
		
		for(i = 0; i < 30; i++)
		{
			if(self.health > 1)
			{
				wait 0.2;
				playfx(level.zom_poisonfx, self.origin + (0, 0, 40));
				guy.score++;
				guy.score2++;
				guy.score3++;
				self.health -= 1;
			}
		}

		self.poisoned = 0;
		
		if(self.health == 1)
			self Callback_PlayerDamage(guy, guy, 2, level.iDFLAGS_NO_KNOCKBACK, "MOD_SUICIDE", "poison_mp", (0,0,0), (0,0,0), "torso_upper", 5 );

		self.lastdmgabil = "poison"; //hm possible bug when sitting in a bubble

		wait 0.5;
	}
}


LastDamageTime() //health regen + scr_unlimitedammo 2
{
	self endon("disconnect");

	while(1)
	{
		wait 1;
		self.lastdmgtime++;

		if(self.ammoAllowedTime > 0)
			self.ammoAllowedTime--;
	}
}


DropObject(lastkiller)
{
	kdrops = getdvarint("scr_killerdrops");

	if(isdefined(lastkiller)) if(lastkiller == self)
		return;

	if(level.lastmanactive)
		return;

	if(getdvarint("scr_drops") == 0)
		return;

	if(getdvarint("scr_drops") == 1)
		type = "health";

	else if(getdvarint("scr_drops") == 2 && isdefined(level.firstzombie) && self == level.firstzombie)
		type = "mine";

	else type = "health";

	togive = 20;

	if(isdefined(self.zom_class) && self.zom_class == "dog")
	{
		if(!getdvarint("scr_doghp") && type == "health")
			return;
		else
			togive = getdvarint("scr_doghp");
	}

	amount = undefined;
	dropper = self;
	object = spawn("script_model", self.origin + (0, 0, 20));

	object.rt = undefined;

	if(kdrops > 0)
		object.rt = (kdrops / 0.1);

	num = 0;

	if(getdvarint("scr_minestokiller")
	 && type == "mine"
	 && isdefined(lastkiller)
	 && lastkiller.health > 0
	 && lastkiller.pers["team"] == "allies")
	{
		lastkiller playlocalsound("zom_pickup");
		lastkiller.minenum++;
		lastkiller iprintln("^2You picked up a mine");
		object delete();
		return;
	}

	if(type == "mine")
		object setmodel("zom_mine");

	if(type == "health")
	{
		object setmodel("zom_health");
		object hidePart("health_red");
	}

	if(kdrops > 0)
	{
		if(type == "health")
		{
			object setmodel("zom_health");
			object showPart("health_red");
			object hidePart("health_green");
		}

		if(type == "mine")
			object setmodel("zom_mine_red");
	}

	object rotateyaw(8000, 21);

	while(1)
	{
		wait 0.15;
		num++;

		if(isdefined(object.rt) && object.rt > -2)
			object.rt = (object.rt - 1);

		if(object.rt <= 0)
		{	
			if(type == "health")
			{
				object setmodel("zom_health");
				object hidePart("health_red");
				object showPart("health_green");
			}

			if(type == "mine")
				object setmodel("zom_mine");
		}

		if(num > 200 || !isdefined(dropper))
		{
			object delete();
			return;
		}

		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];

			if(canpick(p, object, dropper, lastkiller))
			{
				if(type == "health" && p.health != p.maxhealth)
				{
					p playlocalsound("zom_player_pickup");

					if(p.health <= (p.maxhealth - togive))
					{
						p.health += togive;
						amount = togive;
					}

					else if(p.health > (p.maxhealth - togive) && p.health < p.maxhealth)
					{
						amount = (p.maxhealth - p.health);
						p.health = p.maxhealth;
					}

					p iprintln("^2You picked up " + amount + " health");

					object delete();
					return;
				}

				if(type == "mine")
				{
					p playlocalsound("zom_player_pickup");
					p.minenum++;
					p iprintln("^2You picked up a mine");
					object delete();
					return;
				}
			}
		}
	}
}


canpick(player, drop, dropper, lastkiller)
{

	kdrops = getdvarint("scr_killerdrops");

	if(isdefined(distance(drop.origin, player.origin)) && distance(player.origin, drop.origin) <= 50 && player.pers["team"] == "allies" && player.health > 0)
		{
			if(kdrops > 0 && player == lastkiller && drop.rt > 0)
				return true;
	
			else if(kdrops > 0 && drop.rt <= 0)
				return true;
	
			else if(kdrops == 0)
				return true;
		
			else return false;
		}

	else return false;
}


CheckGametype()
{
	while(1)
	{
		wait 1;

		if(getdvarint("sv_cheats"))
			exitlevel(false);

		if(getdvar("g_gametype") != "zom")
		{
			iprintlnbold("G_GAMETYPE is not 'zom', attempting to fix");
			num = 25;
			for(i = 0; i < 25; i++)
			{
				wait 1;
				num--;
				iprintln("MAP CHANGE to gametype zom in: " + num + " seconds");
			}
			setdvar("g_gametype", "zom");
			wait 0.05;
			exitlevel(false);
		}
	}
}