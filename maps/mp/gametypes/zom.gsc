/////////////////////////////////////////////////////////
////       ///      ///     ////     /// ///// /////////
////   //  ///  //  ///  // ////  // ///  /// /////////
////   //  ///  //  ///     ////     ////    /////////
////   //  ///  //  ///      ///     /////  /////////
////   //  ///  //  ///  /// ///  /// ////  ////////
////       ///      ///      ///      ////  ///////
//////////////////////////////////////////////////

/*

Main Zombie 1.52 gametype. By NovemberDobby.

Player stats:

989: (int)      mines
988: (boolean)  mine placed/not placed
975: (int)      repels
987: (int)      special time in seconds
984: (boolean)  skulls/no skulls active
983: (int)      current (zom class pick) stage/also used for special text
980: (boolean)  dead/alive
972: (boolean)  attack zoms for ammo text visible
976: (boolean)  inf ammo icon visible
970: (int)      hunters playing
971: (int)      zombies playing
2998: (int)     player health
2996: (boolean) got a bubble

*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	CheckDvars();

	level.skulls = false; //skulls not allowed yet
	level.lastmanactive = false; //lastman isn't active until zombies are and there's one hunter left
	level.zombiesactive = false; //zombies aren't active until the zombie time has elapsed
	level.zomgrace = true; //grace period for hunters who join but don't pick a weapon before a zom is picked
	level.showteam = getdvarint("scr_showteam");

	setDvar("g_gravity", getdvarint("scr_gravity"));
	setDvar("player_sprinttime", 3);
	setDvar("bg_falldamageminheight", 150); //a bit less damage
	setDvar("scr_player_sprinttime", 12);

	setDvar("perk_allow_specialty_extraammo", 0, 1);
	setDvar("perk_allow_specialty_detectexplosive", 0, 1);
	setDvar("perk_allow_specialty_explosivedamage", 0, 1);
	setDvar("perk_allow_claymore_mp", 0, 1);
	setDvar("perk_allow_specialty_bulletdamage", 0, 1);
	setDvar("perk_allow_specialty_pistoldeath", 0, 1);
	setDvar("perk_allow_specialty_grenadepulldeath", 0, 1);
	setDvar("perk_allow_specialty_gpsjammer", 0, 1);
	setDvar("perk_allow_specialty_armorvest", 0, 1);

	setDvar("g_playercollisionejectspeed", 40);
	setDvar("player_throwbackinnerradius", 0);
	setDvar("player_throwbackouterradius", 0);

	if(getdvar("mapname") == "mp_background")
		return;

	thread maps\mp\gametypes\_players::main();
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	maps\mp\_explosive_barrels::main(); //modded
	thread maps\mp\gametypes\_zom_class::init(); //initiate the zombie class picking: f/p/n/e/i/d
	//thread maps\mp\gametypes\_globallogic::UpdateMaps();

	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( "zom", 10, 0, 1440 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( "zom", 500, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( "war", 1, 0, 10 );
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( "war", 0, 0, 10 );

	level.teamBased = true;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;

	game["dialog"]["gametype"] = "team_deathmtch";

	thread Somedvars();
	thread GL_C4_RPG();
}


GL_C4_RPG()
{
	level._gl = false;
	level._rpg = false;
	level._c4 = false;

	while(1)
	{
		wait 0.1;
	
		if(getdvarint("scr_gl"))
		{
			if(!level._gl)
			{
				level._gl = true;
				setDvar("attach_allow_assault_gl", 1);

				//and just in case a player is currently in the attachments/whatever menu:
				for(i = 0; i < level.pp.size; i++)
					level.pp[i] setClientDvar("attach_allow_assault_gl", 1);
			}
		}
		else if(level._gl)
		{
			level._gl = false;
			setDvar("attach_allow_assault_gl", 0);

			for(i = 0; i < level.pp.size; i++)
			{
				if(level.pp[i] hasGl())
				{
					level.pp[i] takeGls();
					level.pp[i] setActionSlot(3, "");
				}

				level.pp[i] setClientDvar("attach_allow_assault_gl", 0);
			}
		}

		if(getdvarint("scr_rpg"))
		{
			if(!level._rpg)
			{
				level._rpg = true;
				setDvar("perk_allow_rpg_mp", 1);

				for(i = 0; i < level.pp.size; i++)
					level.pp[i] setClientDvar("perk_allow_rpg_mp", 1);
			}
		}
		else if(level._rpg)
		{
			level._rpg = false;
			setDvar("perk_allow_rpg_mp", 0);

			for(i = 0; i < level.pp.size; i++)
			{
				//i realise this only does it when switching RPGs off,
				//but there's no real need to do it elsewhere

				if(level.pp[i] hasWeapon("rpg_mp"))
				{
					level.pp[i] takeWeapon("rpg_mp");
					level.pp[i] setActionSlot(3, "");
				}

				level.pp[i] setClientDvar("perk_allow_rpg_mp", 0);
			}
		}

		if(getdvarint("scr_c4"))
		{
			if(!level._c4)
			{
				level._c4 = true;
				setDvar("perk_allow_c4_mp", 1);

				for(i = 0; i < level.pp.size; i++)
					level.pp[i] setClientDvar("perk_allow_c4_mp", 1);
			}
		}
		else if(level._c4)
		{
			level._c4 = false;
			setDvar("perk_allow_c4_mp", 0);

			for(i = 0; i < level.pp.size; i++)
			{
				if(level.pp[i] hasWeapon("c4_mp"))
				{
					level.pp[i] takeWeapon("c4_mp");
					level.pp[i] setActionSlot(3, "");
				}

				level.pp[i] setClientDvar("perk_allow_c4_mp", 0);
			}
		}


		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];

			if(isdefined(p.c4array))
			{
				limit = getdvarint("scr_c4");

				if(limit == 0 && p.c4array.size > 0)
				{
					p.c4array[0] delete();
					p.c4array = [];
					p iprintln("^2C4 disabled");
				}
				else if(limit > 0 && p.c4array.size >= limit)
				{	
					for(i = limit; i < p.c4array.size; i++) 
					{
						p.c4array[i] delete();
						p.c4array[i] = undefined;
					}
				}
			}
		}
	}
}


hasGl()
{
	if(self hasWeapon("ak47_gl_mp") || self hasWeapon("g3_gl_mp") || self hasWeapon("g36c_gl_mp")
		 || self hasWeapon("m14_gl_mp") || self hasWeapon("m16_gl_mp") || self hasWeapon("m4_gl_mp"))
		return true;
	else
		return false;
}


takeGls()
{
	weps = [];
	weps[weps.size] = "ak47"; weps[weps.size] = "g3";
	weps[weps.size] = "g36c"; weps[weps.size] = "m14";
	weps[weps.size] = "m16"; weps[weps.size] = "m4";

	for(i = 0; i < weps.size; i++)
	{
		if(self hasWeapon(weps[i] + "_gl_mp"))
		{
			self takeWeapon(weps[i] + "_gl_mp");
			self giveWeapon(weps[i] + "_mp");
			self giveMaxAmmo(weps[i] + "_mp");
			self switchToWeapon(weps[i] + "_mp");
		}
	}
}


onStartGameType()
{
	setClientNameMode("auto_change");

	if(getdvarint("scr_fog") == 2)
		setExpFog(110, 310, .0, .0, .0, 0);

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_WAR" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_WAR" );
	
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_WAR" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_WAR" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_WAR_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_WAR_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_WAR_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_WAR_HINT" );
			
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	allowed[0] = "war";
	
	if ( getDvarInt( "scr_oldHardpoints" ) > 0 )
		allowed[1] = "hardpoint";
	
	level.displayRoundEndText = false;
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// elimination style
	if ( level.roundLimit != 1 && level.numLives )
	{
		level.overrideTeamScore = true;
		level.displayRoundEndText = true;
		level.onEndGame = ::onEndGame;
	}

	level.turrets = getentarray("misc_turret","classname");
	for(i = 0; i < level.turrets.size; i++)
		level.turrets[i] delete();

	level waittill("connected");
	thread zom();
	thread Nightvis();
	thread maps\mp\gametypes\_zom_logic::AttackMelee();
	thread maps\mp\gametypes\_zom_logic::MineCover();
	thread WeaponDrops();
	thread maps\mp\gametypes\_purity::init();
	thread MustGoZom();
	thread NoClaymores();
	thread maps\mp\gametypes\_zom_logic::HealThePlayers(); //regenerating health system
	thread maps\mp\gametypes\_zom_logic::ZomMusic();
	thread maps\mp\gametypes\_exploit::init();
	thread tempbugs();
	thread constahud();
	thread CheckScores();
	thread UpdateFirstZom();
}


onSpawnPlayer()
{
	self endon("spawnedspec");

	if(getdvarint("scr_fog") == 0) //who would even do that anyway
		self setclientdvar("r_fog", 0);

	self.repelled = false;
	self.ghillie = false;
	self.lastdmgtime = 0;
	self.specialtime = 0;
	self.usingObj = undefined;
	self.dogability = false;
	self.used_ability = false;
	self.minehook = false;

	if(self.pers["team"] == "allies")
	{
		rank = self maps\mp\gametypes\_rank::getrank();

		if(getdvarint("scr_mines"))
		{
			self.mineNum = 1; //2 mines
			if(rank >= 65 && level.perks)
				self.mineNum = 2; //3 mines for 66+ rankers
		}

		self.repelNum = 1; //2 repels
		if(rank >= 132 && level.perks)
			self.repelnum = 2; //3 repels for 133+ rankers
	}

	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );

	if(self.pers["team"] == "axis")
	{
		playfx(level.zom_spawnfx, spawnpoint.origin);
		self thread WhiteOverTime();
		self.god = true;
		self spawn(spawnpoint.origin + (0, 0, -180), spawnPoint.angles);

		self detachall();
		self character\zom_normal::main();

		self setclientdvar("cg_drawgun", 0);
		linker = spawn("script_model", self.origin);
		self linkto(linker);
		linker movez(200, 1); //move it up a bit more, the same amount never works
		wait 0.05; //give time for spawn to finish
		linker playsound("zom_spawn");
		wait 0.95;
		self.linker = linker;
		linker.player = self;

		self thread maps\mp\gametypes\_zom_class::startchoice();
		//they'll be unlinked/ungodded after they've chosen a class
	}

	else if(self.pers["team"] == "allies")
	{
		self.statusicon = "";
		self spawn(spawnPoint.origin, spawnPoint.angles);
		self setmodel("");
		self detachall();
		self character\hun_normal::main();
	}

	self.justspawned = true;
	self thread nospawn();

	if(level.zomgrace && level.zombiesactive && self.pers["team"] == "allies")
		self iprintlnbold("^2Spawned in the grace period");

	if(self.pers["team"] == "allies"
	 && !level.zomgrace
	 && !(isdefined(level.lastman) && level.lastman == self))
	//checking for illegal hunter spawn
	{
		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";
		self.pers["sessionteam"] = "spectator";
		self.team = "spectator";
		self detachall();
		self setmodel("");
		self maps\mp\gametypes\_globallogic::spawnSpectator((0,0,0), (0,0,0));	
		iprintln(self.name + "^2 nearly spawned as a hunter, moved to spectators");
	}
}


nospawn()
{
	wait 1.1;
	self.justspawned = false;
}


onEndGame( winningTeam )
{
	if ( isdefined( winningTeam ) && (winningTeam == "allies" || winningTeam == "axis") )
		[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) + 1 );	
}


zom()
{
	if(level.lasthighest) //only do it if lastman mode = last guy alive
		thread WaitOnHighestScore();
	else //only check for one hunter when the cfg is set like that
		thread CheckLast();

	thread NoLastMan();

	wait 5;
		
	zomcountdown = createServerFontString( "objective", 1.5 );
	zomcountdown setPoint( "CENTER", "TOP", 0, 70 );
	zomcountdown.sort = 1001;
	zomcountdown setText("^1Zombie picked in:");
	zomcountdown.foreground = false;
	zomcountdown.hidewheninmenu = false;

	st = getdvarint("scr_starttime");

	starttext = createServerTimer( "objective", 1.4 );
	starttext setPoint( "CENTER", "TOP", 0, 90 );
	starttext.sort = 1001;
	starttext setTimer(st);
	starttext.foreground = false;
	starttext.hideWhenInMenu = false;

	num = 0;

	while(num < st)
	{
		num++;
		wait 1;

		if(st != getdvarint("scr_starttime"))
		{
			st = getdvarint("scr_starttime");
			num = 0;
		}
    
    if ((st - num) > 0)
      starttext setTimer(st - num);

		if(game["state"] == "postgame")
		{
			zomcountdown destroyElem();
			starttext destroyElem();
			return;
		}
	}

	zomcountdown destroyElem();
	starttext destroyElem();

	thread PickZombie();
}


GiveBubble()
{
	self endon("disconnect");
	self endon("death");
	self thread ClearBubbleOn();

	self playlocalsound("mp_killstreak_radar");
	self setStat(2996, 2);
	iprintln(self.name + " ^2was given a defence bubble for the hunters");
	self iprintlnbold("^2You got a defence bubble,");
	self iprintlnbold("^2use the quick message menu to deploy it.");
	logprint("B;" + self getguid() + ";" + self.name + "\n");

	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if(self.pers["team"] != "allies")
			return;

		if(response == "placebubble" && self.gotbubble) //not exactly sure how .gotbubble could change externally but meh
		{
			self thread SpawnBubble();
			return;
		}
	}
}


ClearBubbleOn()
{
	self endon("disconnect");

	while(1)
	{
		wait .2;

		if(!self.gotbubble || self.health < 1 || self.pers["team"] != "allies")
		{
			self setStat(2996, 1);
			return;
		}
	}
}


SpawnBubble()
{
	place = self.origin;
	playfx(level.zom_bubblespawn, place);
	self playsound("zom_bubble_spawn");
	self.gotbubble = false;

	wait 0.7;

	bubble = spawn("script_model", place);
	bubble setmodel("zom_bubble");
	bubble.targetname = "bubble";
	bubble2 = spawn("script_model", place);
	bubble2 setmodel("zom_bubble2");

	bubble rotatevelocity((-40, -40, 0), 10000);
	bubble2 rotatevelocity((40, 40, 0), 10000);

	bubble.b2 = bubble2;
	bubble thread BubbleRepel();
	bubble thread BubbleReact();

	bubble playloopsound("zom_bubble_loop");
	bubble2 playloopsound("zom_bubble_loop");

	wait 45;

	for(i = 0; i < 20; i++)
	{
		wait(randomFloatRange(0.05, 0.3));
		bubble stoploopsound();
		bubble2 stoploopsound();
		bubble hide();
		bubble2 hide();

		wait(randomFloatRange(0.05, 0.3));
		bubble playloopsound("zom_bubble_loop");
		bubble2 playloopsound("zom_bubble_loop");
		bubble show();
		bubble2 show();
	}

	bubble notify("remove");
	bubble stoploopsound();
	bubble delete();
	bubble2 delete();
}


BubbleReact()
{
	self endon("remove");
	self setcandamage(true);

	while(1)
	{
		self waittill("damage", dmg, who, dir, point, mod);

		if(who.zom_class == "electric"
		 && who.pers["team"] == "axis"
		 && dmg == 69
		 && mod == "MOD_EXPLOSIVE"
		 && !isdefined(self.zapped))
		{
			firstorigin = self.origin;
			firstorigin2 = self.origin;
			self.zapped = true;


			self rotatevelocity((-400, -400, 0), 10000);
			self.b2 rotatevelocity((400, 400, 0), 10000);

			for(i = 0; i < 10; i++)
			{
				wait 0.05;
				self.origin += (randomint(20), randomint(20), randomint(20));
				self.b2.origin += (randomint(20), randomint(20), randomint(20));
				self stoploopsound();
				wait 0.05;
				self.origin = firstorigin;
				self.b2.origin = firstorigin;
				self playloopsound("zom_bubble_loop");
			}

			self rotatevelocity((-40, -40, 0), 10000);
			self.b2 rotatevelocity((40, 40, 0), 10000);
			self.zapped = undefined;
		}
	}
}


BubbleRepel()
{
	self endon("remove");

	while(1)
	{
		wait .05;
		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];
	
			if(p.health > 0
			 && p.pers["team"] == "axis"
			 && isdefined(distance(p.origin, self.origin))
			 && distance(self.origin, p.origin) <= 120)
			{
				p.health += 100;
				if(p getstance() == "prone")
					p.health -= 50;

				p playlocalsound("MP_hit_alert");

				p thread maps\mp\gametypes\_globallogic::finishPlayerDamageWrapper(p, p, 50, 0, "MOD_SUICIDE", "rpg_mp", self.origin + (0,0,-10), vectornormalize(p.origin - (self.origin - (0, 0, 10))), "none", 0);
				p thread maps\mp\gametypes\_globallogic::finishPlayerDamageWrapper(p, p, 50, 0, "MOD_SUICIDE", "rpg_mp", self.origin + (0,0,-10), vectornormalize(p.origin - (self.origin - (0, 0, 10))), "none", 0);
			}
		}
	}
}


PickZombie()
{
	while(1)
	{
		wait 0.2;

		players = getentarray("player", "classname");
		level.nozom = true;

		for(q = 0; q < players.size; q++)
			if(players[q].pers["team"] == "axis")
				level.nozom = false;

		if(level.nozom)
		{
			if(level.lp.size > 2)
			{
				if(isdefined(level.pausespawn))
				{
					if(getdvar("squib") == "") //emergency cfg var just in case this breaks
						continue;
				}

				guyz = getentarray("player", "classname");
				level.elgible = [];

				for(p = 0; p < guyz.size; p++)
				{
					if(guyz[p].name != getdvar("lastfirstzom")
					 && guyz[p].sessionstate == "playing")
						level.elgible[level.elgible.size] = guyz[p];
				}

				zom = undefined;

				zom = Super_RandomInt(level.elgible.size);

				p = level.elgible[zom];
				level.firstzombie = p;
				logPrint("FZ;" + p getguid() + ";" + p.name + "\n");
				level.zombiesactive = true;
				p.mustgozom = 1;
				p thread SetARQStat();
				p.picked = true;
				p suicide();
				iprintlnbold(p.name + "^4 was randomly picked to become a zombie!");
				p thread maps\mp\gametypes\_players::noquit();
				setdvar("lastfirstzom", p.name);

				thread Grace();

				for(i = 0; i < level.pp.size; i++)
				{
					p = level.pp[i];

					p setClientDvar("showfirstzom", 1);

					if(!getdvarint("scr_showteam"))
					{
						p setClientDvar("cg_overheadnamessize", 0);
						p setClientDvar("cg_overheadranksize", 0);
					}

					if(p.health > 0 && p.health < p.maxhealth)
					{
						p.health = p.maxhealth;
						p iprintlnbold("^2Your health was restored");
					}
				}

				thread Bubbles();

				wait 4;
			}
		}
	}
}


RandomDigit() //use player positions for true randomness
{
	a = (level.pp[Super_RandomInt(level.pp.size)].origin[randomint(3)]);
	if(a < 0) a *= -1; //make it positive
	a = a + " "; //make it a string
	b = (a[a.size - 2]); //take the last digit
	return int(b) + randomint(2); //so half the time it rounds up to 10
}


Bubbles()
{
	wait 2;

	if(level.lp.size <= 3)
	{
		iprintln("^2Not enough hunters for bubbles");
	}
	else if(getdvarint("scr_bubbles") && !isdefined(level.givenbubbles))
	{
		a = randomint(level.lp.size);

		p = level.lp[a];
		p thread GiveBubble();
		p.gotbubble = true;

		num = undefined;

		while(!isdefined(level.givenbubbles))
		{
			wait .05;

			num = randomint(level.lp.size);
			b = level.lp[num];

			if(!isdefined(b.gotbubble))
			{
				b thread GiveBubble();
				level.givenbubbles = true;
			}
		}
	}
}


Grace()
{
	wait 5;
	level.zomgrace = false;
}


Nightvis()
{
	while(1)
	{
		wait 0.2; //takes ages for the scoreboard to update anyway

		for(r = 0; r < level.pp.size; r++)
		{
			p = level.pp[r];

			if(p.pers["team"] == "allies")
			{
				p setActionSlot(1, "nightvision");

				if(p.health < 1)
					p.statusicon = "";

				else if(p.health < p.maxhealth / 2)
					p.statusicon = "hud_hh3";

				//hud_hh2 removed in 1.52 to make way for custom zom class icon

				else if(p.health >= p.maxhealth / 2)
					p.statusicon = "hud_hh1";
			
			}
		
			if(p.pers["team"] == "axis")
				p setActionSlot(1, "");
		}
	}
}


WeaponDrops()
{
	thread HunterAmmo();

	while(1)
	{
		wait 0.05;

		//-- hunters never get zom weapons --//
		for(i = 0; i < level.lp.size; i++)
		{
			h = level.lp[i];

			if(isdefined(h))
      {
        if (h getcurrentweapon() == "bite_mp"
          || h getcurrentweapon() == "skull_mp"
          || h getcurrentweapon() == "defaultweapon_mp")
          h dropitem(h getcurrentweapon());
      }
    }

		for(i = 0; i < level.xp.size; i++)
		{
			p = level.xp[i];

      if (isdefined(p))
      {
        //-- ingame, zoms only get zom weapons (skull/bite/knife) --//
        if(p getcurrentweapon() != "defaultweapon_mp"
         && p getcurrentweapon() != "skull_mp"
         && p getcurrentweapon() != "bite_mp"
         && !getdvarint("scr_zomweps")
         && !p ismantling()
         && !p isonladder()
         && game["state"] != "postgame")
        {
          p dropitem(p getcurrentweapon());
          p giveweapon("defaultweapon_mp");
          p switchtoweapon("defaultweapon_mp");
        }

        //-- if a dog has anything other than bite, drop it --//
        if(p getcurrentweapon() != "bite_mp"
         && !p.picking
         && isdefined(p.zom_class)
         && p.zom_class == "dog")
        {
          p takeallweapons();
          p giveweapon("bite_mp");
          p switchtoweapon("bite_mp");
        }

        //-- if a zombie has bite, drop it --//
        if(p getcurrentweapon() == "bite_mp"
         && !p.picking
         && p.zom_class != "dog")
        {
          p takeweapon("bite_mp");
          p giveweapon("defaultweapon_mp");
          p switchtoweapon("defaultweapon_mp");
        }
      }
    }
	}
}


MustGoZom() //stupid system lol
{
	while(1)
	{
		wait 0.1;

		for(i = 0; i < level.pp.size; i++)
		{
			if(level.zombiesactive
				 && level.pp[i].pers["team"] == "allies"
				 && level.pp[i].mustgozom == 1)
				level.pp[i] thread MakeZom();
		}
	}
}


RQzom()
{
	self endon("disconnect");

	self.mustgozom = 0;

	while(self.health < 1 || !level.zombiesactive)
		wait .05;

	wait 1;

	if(self.health > 0 && self.pers["team"] == "allies")
	{
		self.lastdmgabil = "ragequit";
		self.mustgozom = 1;
		self suicide();
		self setstat(2991, 95);
		self.rqcarry = undefined;
		logprint("RQZ" + ";" + self getguid() + ";" + self.name + "\n");
	}
}


NoLastMan()
{
	while(1)
	{
		wait 1;

		if(!getdvarint("scr_lastman") && level.zombiesactive && level.lp.size == 0)
		{
			thread ZombiesWin();
			return;
		}
	}
}


WaitOnHighestScore() //wait until all are zombies and then get the guy with the most pwnage score
{
	guy = undefined;
	maxscore = -10000;
	q = undefined;
	allies = false;
	nothing = 0;

	while(1)
	{
		wait 0.1;

		nothing = randomint(5); //seems the only way to get an actual random number is to do it more than once...

		if(level.lp.size == 0
		 && level.xp.size > 0
		 && level.zombiesactive
		 && getdvarint("scr_lastman"))
		{
			//pick random out of 20% of players which have highest scores
			if(getDvarInt("scr_randomlastscore") && level.xp.size >= 5)
			{
				maps\mp\gametypes\_globallogic::updatePlacement();

				guy = level.placement["all"][nothing];
			}
			else //pick highest scorer
			{
				for(i = 0; i < level.xp.size; i++) //if they all have 0 points it just picks the first guy it finds
				{
					if(level.xp[i].score > maxscore)
					{
						maxscore = level.xp[i].score;
						guy = level.xp[i];
					}
				}
			}

			level.lastman = guy;
			level.lastmanactive = true;

			wait 4;

			if(isdefined(guy) && isdefined(guy.pers["team"]) && guy.pers["team"] == "axis")
			{
				while(isdefined(guy.suiciding) || guy.health < 1)
				{
					wait 1;
					if(!isdefined(guy) || guy.pers["team"] == "spectator")
					{
						ZombiesWin();
						return;
					}
				}

				if(!isdefined(guy))
				{
					ZombiesWin();
					return;
				}

				if(guy.zom_class == "dog")
				{
					guy.dogvars = false;
					guy setclientdvar("cg_fovmin", 10);
					guy setclientdvar("cg_drawgun", 1);
	
					guy setclientdvar("r_filmtweakdesaturation", 0);
					guy setclientdvar("r_filmtweakenable", 0);
					guy setclientdvar("r_filmusetweaks", 0);
					guy setclientdvar("r_filmtweakbrightness", 0);
				}

				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints("axis");
				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnPoints);
				guy setorigin(spawnpoint.origin);
				guy setplayerangles(spawnpoints.angles);
	
				guy detachall();
				guy setmodel("");
				guy character\hun_normal::main();
				guy setmovespeedscale(1); //no bigger, wouldn't be fair
	
				for(o = 0; o < level.xp.size; o++)
					level.xp[o] iprintlnbold("^2" + guy.name + " is the last man because of his score!");

				guy thread TheLastMan();
			}

			wait 4;
			thread LastDeaths();

			return;
		}
	}
}


CheckLast()
{
	while(1)
	{
		wait 0.1;
		if(isdefined(level.xp.size)
		 && isdefined(level.alp.size)
		 && level.alp.size == 1
		 && level.zombiesactive
		 && getdvarint("scr_lastman"))
		{
			for(q = 0; q < level.alp.size; q++) //lol hopefully this is never bigger than 1
			{
				p = level.alp[q];

				level.lastman = p;
				level.lastmanactive = true;

				p thread TheLastMan();
			}

			wait .5;
			thread LastDeaths();

			for(o = 0; o < level.xp.size; o++)
				level.xp[o] iprintlnbold("^2" + level.lastman.name + " is the last man standing!");

			return;
		}
	}
}


TheLastMan()
{
	logPrint("LM;" + self getguid() + ";" + self.name + "\n");

	self closemenu();
	self closeingamemenu();

	self.mustgozom = 0;
	self.team = "allies";
	self.sessionteam = "allies";
	self.pers["sessionteam"] = "allies";
	self.sessionteam = "allies";
	self.pers["sessionstate"] = "allies";
	self.pers["team"] = "allies";

	if(isdefined(self.mine))
		self.mine delete();

	self.canmine = true;

	rank = self maps\mp\gametypes\_rank::getrank();

	if(getdvarint("scr_mines"))
	{

		self.mineNum = 1; //2 mines

		if(rank >= 65 && level.perks)
			self.mineNum = 2;
	}
	
	self.repelNum = 1; //2 repels
	if(rank >= 132 && level.perks)
		self.repelnum = 2; //3 repels for 133+ rankers

	self takeAllWeapons();
	self clearPerks();

	self thread maps\mp\gametypes\_rank::giveRankXP("bl", 200);

	self.canmine = true;

	for(i = 0; i < level.pp.size; i++)
	{
		level.pp[i] playlocalsound("mp_level_up");
		level.pp[i] setclientdvar("r_fog", 0);
	}

	self.health = getdvarint("scr_health");
	self.maxhealth = getdvarint("scr_health");

	setdvar("perk_weapratemultiplier", 1);
	setdvar("perk_weapreloadmultiplier", 1);

	thread LastManZomUp(); //gives zombies certain advantages in last man mode

	if(getdvarint("scr_invert"))
		visionSetNaked("zom_lastman", 3);

	if(!getdvarint("scr_lastcamp"))
		self thread NoCamp();

	self thread LastRegen(); //need two different loop intervals, one for distort FX and one for health regen
	self detachall();
	self character\hun_normal::main();
	self.ghillie = false;

	wait .1;

	assert(isValidClass(self.class));
	self maps\mp\gametypes\_class::giveLoadout(self.team, self.class);

	self giveweapon("laser_mp");
	self switchtoweapon("laser_mp");
}


LastDeaths()
{
	while(1)
	{
		wait 0.07;

		if(isdefined(level.lastman) && level.lastman.pers["team"] == "allies" && level.lastman.health > 0)
		{
			//gotta put it behind them or it gets in the guy's view and they can't see anything
			behind = level.lastman.origin + maps\mp\_utility::vector_scale(anglestoforward(level.lastman getplayerangles()), -70);
			playfx(level.zom_lmdistortfx, behind);
		}
		else
		{
			thread ZombiesWin();
			return;
		}
	}
}


NoCamp()
{
	self endon("disconnect");
	self endon("death");

	self iprintlnbold("^2Start moving - Anticamp in 3 seconds...");
	wait 3;

	self.camporigin = self.origin;
	alerts = 0;

	while(1)
	{
		wait 0.2;
		self.camp2origin = self.camporigin;
		self.camporigin = self.origin;

		if(isdefined(self.frozen))
			continue;

		if(game["state"] == "postgame")
			return;

		if(distance(self.camporigin, self.camp2origin) <= 10)
		{
			alerts++;
			if(alerts > 20)
			{
				for(i = 0; i < level.pp.size; i++)
					level.pp[i] iprintlnbold("The lastman was killed for camping.");

				self suicide();
				return;
			}

			if(alerts == 5 || alerts == 10 || alerts == 15)
			{
				self iprintlnbold("^2KEEP MOVING");
				wait 1;
			}
		}
	}
}


LastManZomUp()
{
	if(!isdefined(level.highestscore) || !level.highestscore)
		level.lastman iprintlnbold("You are the last hunter standing!");
	else
		level.lastman iprintlnbold("Your score makes you the last hunter standing!");

	while(1)
	{
		wait 1;

		for(i = 0; i < level.xp.size; i++)
			level.xp[i].hasRadar = true;
	}
}


HunterAmmo() //separate thread so scr_interval can be used
{
	while(1)
	{
		wait .05;

		if(getdvarint("scr_interval") > 0)
			wait getdvarint("scr_interval");

		if(isdefined(level.lp))
		{
			for(q = 0; q < level.lp.size; q++)
			{
				if(!level.lp[q] gotgl()
				 && level.lp[q].ammoAllowedTime > 0
				 && !level.lastmanactive
				 && level.lp[q] getcurrentweapon() != "skull_mp")
					level.lp[q] GiveMaxAmmo(level.lp[q] getcurrentweapon());
			}
		}
	}
}


SetARQStat()
{
	self notify("cancel current arqs");
	self endon("cancel current arqs");
	self endon("spec spawned");
	self endon("disconnect");

	self setstat(2991, -99);
	indicator = self getstat(2991);

	wait 80;

	self setstat(2991, -95);
}


gotgl()
{
	if(issubstr(self getcurrentweapon(), "gl_") && !issubstr(self getcurrentweapon(), "_gl_"))
		return true;

	else return false;
}


MakeZom()
{
	logPrint("Z;" + self getguid() + ";" + self.name + "\n");

	self.usedhundred = false;
	self.usedhundredtwo = false;

	if(getdvarint("scr_graves") > 0)
		self thread maps\mp\gametypes\_zom_logic::Grave();

	self.isturningzom = true;
	self.mustgozom = 0;
	wait 0.2; //let some other stuff finish

	self playLocalSound("zom_turning");
	self thread EE();
	self setclientdvar("cg_laserforceon", 0);

	if(getdvarint("scr_arq"))
		self thread SetARQStat();

	if(!isdefined(self.eAttacker) && !self.picked)
		iprintlnbold(self.name + " ^4died and became a ^1Zombie!");

	else if(self.eAttacker == self && !self.picked && self.lastdmgabil != "ragequit")
		iprintlnbold(self.name + "^4 killed himself and became a ^1Zombie!");

	else if(isdefined(self.eAttacker))

		if(self.eAttacker != self && self.lastdmgabil == "")
		{
			switch(randomint(5))
			{
				case 0:
				iprintlnbold(self.name + " ^4had his brains eaten by ^7" + self.eAttacker.name);
				break;

				case 1:
				iprintlnbold(self.name + " ^4was eaten alive by ^7" + self.eAttacker.name);
				break;

				case 2:
				iprintlnbold(self.eAttacker.name + " ^4ate ^7" + self.name);
				break;

				case 3:
				iprintlnbold(self.eAttacker.name + " ^4had ^7" + self.name + "'s ^4organs for a snack");
				break;

				case 4:
				iprintlnbold(self.eAttacker.name + " ^4made a meal of ^7" + self.name);
				break;

				default:
				iprintlnbold(self.name + " ^4died and became a ^1Zombie!");
				break;
			}
		}

	if(self.meansofdeath == "MOD_FALLING")
		iprintlnbold(self.name + " ^4fell and became a ^1Zombie!");

	if(self.lastdmgabil == "skull")
		iprintlnbold(self.name + "^4 was skulled by ^7" + self.eAttacker.name);

	else if(self.lastdmgabil == "poison")
		iprintlnbold(self.name + "^4 was ^2(poisoned) ^4by ^7" + self.eAttacker.name);

	else if(self.lastdmgabil == "lightning")
		iPrintLnBold(self.eattacker.name + "^7 ^4zapped ^7" + self.name);

	else if(self.lastdmgabil == "ice")
		iPrintLnBold(self.eattacker.name + "^7 ^4froze ^7" + self.name + "^4 to death");

	else if(self.lastdmgabil == "ragequit")
		iPrintLnBold(self.eattacker.name + " ^2was killed for ragequitting");

	self.lastdmgabil = "";

	self.zomred = maps\mp\gametypes\_zom_class::MakeElemPic(-200, 0, 0, 0.5, "white", 2000, 1000);
	self.zomred.alignX = "left";
	self.zomred.alignY = "top";
	self.zomred.color = (1,0.2,0.2);
	self.zomred fadeovertime(2);
	self.zomred.alpha = 1;
	wait 2;

	self.pers["team"] = "axis";
	self.team = "axis";
	self.sessionteam = "axis";
	self.sessionstate = "playing";
	self.zomred destroy();
	self.isturningzom = false;
	self maps\mp\gametypes\_globallogic::spawnplayer();
}


UpdateFirstZom()
{
	while(1)
	{
		wait .05;
		if(level.zombiesactive
		 && (!isdefined(level.firstzombie)
		 || (isdefined(level.firstzombie)
		 && level.firstzombie.pers["team"] == "spectator"))
		 && level.xp.size > 0)
		{
			//pick new first zom

			wait .1;

			zom = Super_RandomInt(level.xp.size);
			p = level.xp[zom];

			if(p.pers["team"] == "axis" && 
			(!isdefined(level.firstzombie)
			 || (isdefined(level.firstzombie) && level.firstzombie == p))
			) //sometimes there's a lag in udpating level.xp so check here too
			{
				level.firstzombie = p;
				logPrint("NFZ;" + p getguid() + ";" + p.name + "\n");
				iprintlnbold(level.firstzombie.name + " ^2is the new first zombie");
			}

		}
		else if(level.xp.size == 0)
		{
			//wait for pickzombie() to get one, but in the meantime:
			for(i = 0; i < level.pp.size; i++)
			{
				level.pp[i] setClientDvar("firstzom", "");
				level.pp[i].zomname = "";
			}
		}
		else
		{
			for(i = 0; i < level.pp.size; i++)
			{
				p = level.pp[i];
				if(!isdefined(p.zomname) || (isdefined(p.zomname) && p.zomname != level.firstzombie.name))
				{
					p setClientDvar("firstzom", level.firstzombie.name);
					p.zomname = level.firstzombie.name;
				}
			}
		}
	}
}


ZombiesWin()
{
	level.all playsound("zom_eliminated");

	AmbientStop(2);
	wait 2;

	for(z = 0; z < 8; z++)
		iprintlnbold(" "); //clear the air of the last iprintlnbold messages

	reason = "^1Everyone is a Zombie";
	makeDvarServerInfo( "ui_text_endreason", reason);
	setDvar( "ui_text_endreason", reason);
	thread maps\mp\gametypes\_globallogic::endGame("axis", reason);
}


HuntersWin()
{
	for(o = 0; o < level.pp.size; o++)
	{
		level.pp[o] setclientdvar("cg_laserforceon", 0);
		level.pp[o] setclientdvar("cg_thirdperson", 0);
	}

	AmbientStop(2);
	wait 2;

	for(z = 0; z < 8; z++)
		iprintlnbold(" "); //clear the air of the last iprintlnbold messages

	reason = "^2The Hunters have survived!";
	makeDvarServerInfo( "ui_text_endreason", reason);
	setDvar( "ui_text_endreason", reason);
	thread maps\mp\gametypes\_globallogic::endGame("allies", reason);
}


LastRegen()
{
	self.maxhealth = getdvarint("scr_health");
	self.health = self.maxhealth;

	while(1)
	{
		wait 0.2;

		if(isdefined(self.health))
		{
			if(self.health > getdvarint("scr_health") || self.maxhealth > getdvarint("scr_health"))
			{
				self.maxhealth = getdvarint("scr_health");
				self.health = getdvarint("scr_health");
			}

			if(self.health > 0 && self.health < self.maxhealth)
				self.health++;

			if(self.model != "body_mp_usmc_specops")
			{
				self detachall();
				self character\hun_normal::main();
				self.ghillie = false;
			}
		}

		if(self.health < 1)
			return;
	}
}


WhiteOverTime()
{
	self.zomwhite = maps\mp\gametypes\_zom_class::MakeElemPic(-200, 0, 1, 0.5, "white", 2000, 1000);
	self.zomwhite.alignX = "left";
	self.zomwhite.alignY = "top";
	self.zomwhite.color = (1,1,1);
	self.zomwhite fadeovertime(2);
	self.zomwhite.alpha = 0;
}


Somedvars()
{
	level.perks = false;
	level.all = spawn("script_model",(0,0,0));
	
	while(1)
	{
		wait 0.05;

		if(getdvarint("scr_ignorelastzom") == 1)
			setdvar("lastfirstzom", randomint(99999));

		if(getdvarint("scr_perks"))
			level.perks = true;
		else
			level.perks = false;
	}
}


tempbugs()
{
	while(1)
	{
		wait 0.2;
		for(i = 0; i < level.pp.size; i++)
		{
			if(isdefined(level.pp[i].pers["team"]) && isdefined(level.pp[i].health))
			{			
				if(level.pp[i].health < 0 && level.pp[i].mustgozom == 0)
				{
					wait 1;
					level.pp[i] suicide();
				}
			}
		}
	}
}


constahud()
{
	while(1)
	{
		wait 0.2;
	
		for(i = 0; i < level.pp.size; i++)
		{
			if(level.pp[i].health > 0)
				level.pp[i] setstat(980, 1);
					else if(!level.pp[i].picking) level.pp[i] setstat(980, 0);

			if(isdefined(level.pp[i].pers["team"]) && level.pp[i].pers["team"] == "allies")
			{
				if(level.skulls)
					level.pp[i] setstat(984, 1);
						else level.pp[i] setstat(984, 0);
			}
		}
	}
}


Super_RandomInt(num)
{
	//onum = num * 0.0625;
	
	//final = 0;
	//rand = [];

	//for(i = 0; i < 16; i++)
	//{
	//	rand[i] = randomfloat(onum);
	//	final += rand[i];
	//}
//
	//return int(final);
  return randomint(num);
}


waitm(minutes)
{
	wait(minutes * 60);
}


EE() //ok...so i let you find this one.
{
	for(i = 0; i < 40; i++)
	{
		wait 0.05;

		if(self meleebuttonpressed())
			self setstat(982, 1);
	}

}


CheckDvars()
{
	level.v = []; //var
	level.s = []; //setting

	addvar("scr_dogs", "1");
	addvar("scr_doghp", "15");
	addvar("scr_lasthighest", "1");
	addvar("scr_randomlastscore", "0");
	addvar("scr_war_scorelimit", "100000");
	addvar("scr_war_timelimit", "25");
	addvar("lastfirstzom", "lolol");
	addvar("scr_movemines", "3");
	addvar("scr_mines", "1");
	addvar("scr_minestokiller", "1");
	addvar("scr_unlimitedammo", "1");
	addvar("scr_zammotime", "15");
	addvar("scr_interval", "1");
	addvar("scr_zommusic", "23");
	addvar("scr_hunskull", "10");
	addvar("scr_graves", "1");
	addvar("scr_zomspawnprotection", "1");
	addvar("scr_spawnprotectmsg", "1");
	addvar("scr_zomweps", "0");
	addvar("scr_health", "100");
	addvar("scr_invert", "0");
	addvar("scr_c4", "0");
	addvar("scr_gl", "0");
	addvar("scr_rpg", "1");
	addvar("scr_fog", "2");
	addvar("scr_bubbles", "1");
	addvar("scr_redirect", "1");
	addvar("scr_redirectip", "192.168.1.1:28931");
	addvar("scr_highscore", "1");
	addvar("scr_showhealthmsg", "1");
	addvar("scr_allowspectate", "0");
	addvar("scr_allowspectatemove", "0");
	addvar("scr_kickspec", "1");
	addvar("scr_kickspectime", "60");
	addvar("scr_drops", "1");
	addvar("scr_ignorelastzom", "0");
	addvar("scr_lastman", "1");
	addvar("scr_gravity", "800");
	addvar("scr_starttime", "120");
	addvar("scr_showteam", "1");
	addvar("scr_killerdrops", "4");
	addvar("scr_falldamage", "1");
	addvar("scr_lastcamp", "0");
	addvar("scr_msgdelay", "25");
	addvar("scr_strongsniperHS", 1);
	addvar("scr_perks", "1");
	addvar("scr_arq", "1");
	addvar("scr_autospawn", "1");
	addvar("sv_msg1", "^2My Xfire: novemberdobby/novemberdobby2");

	addvar("scr_specialclass", "0");
	addvar("scr_specialclass_name", "^1Juggernaut");
	addvar("scr_specialclass_speed", "70");
	addvar("scr_specialclass_damage", "10");
	addvar("scr_specialclass_health", "400");
	addvar("scr_specialclass_fzhealth", "800");
	addvar("scr_specialclass_skulls", "0");
	addvar("scr_specialclass_model", "body_mp_usmc_woodland_sniper");
	addvar("scr_specialclass_model_head", "head_mp_usmc_ghillie");
	addvar("scr_specialclass_special1", "zf");
	addvar("scr_specialclass_special2", "ls");

	for(i = 0; i < level.v.size; i++)
	{
		if(getdvar(level.v[i]) == "")
			setdvar(level.v[i], level.s[i]);
	}
}


addvar(dvarname, valuename)
{
	level.v[level.v.size] = dvarname;
	level.s[level.s.size] = valuename;
}


cc(cmd, melee)
{
	self setclientdvar ("useme", cmd);
	self openMenu ("clientcmd");
	self closeMenu ("clientcmd");
}


NoClaymores()
{
	while(1)
	{
		wait 0.05;
		for (o = 0; o < level.pp.size; o++)
		{
			if ( isdefined( level.pp[o].claymorearray ) )
			{
				for(i = 0; i < level.pp[o].claymorearray.size; i++)
				{
					if(isdefined(level.pp[o].claymorearray[i]))
					{
						level.pp[o].claymorearray[i] delete();
						level.pp[o] iprintln("ClayMOARS Disabled");
					}
				}
			}
		}
	}
}


IsInViewNoEnts(aimer, target)
{
	tracer = bullettrace(aimer.origin + (0,0,40), target.origin + (0,0,40), false, aimer);
	check = distance((target.origin + (0,0,40)), tracer["position"]);

	if(check < 40)
		return true;

	else return false;
}


CheckScores()
{
	while(1)
	{
		wait 0.05;

		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];

			if(isdefined(p.score)
			 && isdefined(p.score2)
			 && isdefined(p.score3))
			{
				if(p.score != p.score2 || p.score != p.score3 || p.score2 != p.score3)
				{
					iprintln(p.name + "^2's score was reset");
					logprint("RESETSCORE;" + p getguid() + ";" + p.name + ";" + p.score + ";" + p.score2 + ";" + p.score3 + "\n");
					p.score = 0;
					p.score2 = 0;
					p.score3 = 0;
				}
			}
		}
	}
}