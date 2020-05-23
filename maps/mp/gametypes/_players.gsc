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

main()
{
	setdvar("scr_say", "");
	setdvar("scr_saysmall", "");
	setdvar("scr_pausegame", "0");
	setdvar("scr_timescale", 1);

	level.v2 = []; //var
	level.s2 = []; //setting

	addvar("scr_timetime", "0");

	for(i = 0; i < level.v2.size; i++)
	{
		if(getdvar(level.v2[i]) == "")
			setdvar(level.v2[i], level.s2[i]);
	}

	level.tchange = false;
	level.pausenotified = "0";

	thread RedefinePlayers();
	thread ServerMessages();
	thread KillPlayer();
	thread PauseGame();
	thread SpectatePlayer();
	thread extras();
}


addvar(dvarname, valuename)
{
	level.v2[level.v2.size] = dvarname;
	level.s2[level.s2.size] = valuename;
}

extras()
{
	say = undefined;
	says = undefined;
	arr = [];

	while(1)
	{
		wait 0.05;

		say = getdvar("scr_say");
		says = getdvar("scr_saysmall");

		if (say != "")
		{
			if(issubstr(say, "#"))
			{
				arr = strtok(say, "#");
				for(i = 0; i < arr.size; i++)
					iprintlnbold(arr[i]);
			}
			else
				iprintlnbold(say);

			setdvar("scr_say","");
		}

		if (says != "")
		{
			if(issubstr(says, "#"))
			{
				arr = strtok(says, "#");
				for(i = 0; i < arr.size; i++)
					iprintln(arr[i]);
			}
			else
				iprintln(says);

			setdvar("scr_saysmall","");
		}
	}
}


RedefinePlayers()
{
	while(1)
	{		
		level.pp = getentarray("player","classname");

		for(o = 0; o < level.pp.size; o++)
		{
			if(level.pp[o].pers["team"] == "allies" && level.pp[o].health > 0)
				level.pp[o].target = "yep";
			else
				level.pp[o].target = "nop";

			if(level.pp[o].pers["team"] == "allies")// && !level.pp[o].unspawned) causes some bugs
				level.pp[o].targetname = "allied";

			if(level.pp[o].pers["team"] == "axis" || level.pp[o].isturningzom)
				level.pp[o].targetname = "axis";

			if(level.pp[o].pers["team"] == "spectator")
				level.pp[o].targetname = "noteam";
		}

		level.xp = getentarray("axis", "targetname");
		level.lp = getentarray("allied", "targetname");
		level.alp = getentarray("yep", "target"); //used for quickly respawning last man

		hold = false;

		//spawning as the third hunter with no weps fix
		if(level.lp.size == 3)
		{
			for(i = 0; i < level.lp.size; i++)
			{
				if(level.lp[i].health < 1)
				{
					hold = true;
				}
			}
	
			if(hold)
				level.pausespawn = true;
			else
				level.pausespawn = undefined;
		}
		else
			level.pausespawn = undefined;

		currentscale = getdvarfloat("timescale");
		newscale = getdvarfloat("scr_timescale");
	
		if(currentscale != newscale && !level.tchange)
			thread gradualchange(currentscale, newscale);
	
		wait 0.05;
	}
}


gradualchange(currentscale, newscale)
{
	newint = 1;
	level.tchange = true;

	while(1)
	{
		wait getdvarfloat("scr_timetime"); //potential infinite loop much?

		if(getdvarfloat("timescale") < getdvarfloat("scr_timescale"))
			newint = (getdvarfloat("timescale") + (0.01));

		else if(getdvarfloat("timescale") >= getdvarfloat("scr_timescale"))
			newint = (getdvarfloat("timescale") - (0.01));

		if(isdefined(newint))
			setdvar("timescale",newint);

		if(getdvarfloat("scr_timescale") == getdvarfloat("timescale"))
		{
			level.tchange = false;
			return;
		}
	}
}


gcvsingle(dvar)
{
	if(getdvarint(dvar) >= 0)
		return true;
	else
		return false;
}


KillPlayer()
{
	setdvar("scr_killplayer", "-1");

	while(1)
	{
		wait 0.2;

		if(isdefined(level.pp))
		{
			scvar = "scr_killplayer";
			if(gcvsingle(scvar))
			{
				for(i = 0; i < level.pp.size; i++)
				{
					p = level.pp[i];
					if(p getEntityNumber() == getdvarint(scvar) && !p.picking) 
					{
						p suicide();
						iprintln(p.name + " was killed by an admin");
					}
				}
				setdvar(scvar, -1);
			}
		}
	}
}


PauseGame()
{
	while(1)
	{
		wait 0.2;

		if(getdvarint("scr_pausegame"))
		{
			level.pausegame = true;

			for(i = 0; i < level.pp.size; i++)
			{
				level.pp[i] freezecontrols(true);
				thread notifypause();
			}
		}
		else
		{
			level.pausegame = false;

			for(i = 0; i < level.pp.size; i++)
			{
				level.pp[i] freezecontrols(false);
				level notify("end pause");
				level.pausenotified = false;
			}
		}
	}
}


notifypause()
{
	if(getdvarint("scr_pausegame") && !level.pausenotified)
	{
		level.pausenotified = true;
		level thread maps\mp\gametypes\_hud_message::make_permanent_announcement("Game paused", "end pause", 220, (1.0,0.0,0.0));
	}
}


SpectatePlayer()
{
	setdvar("scr_spectateplayer", "-1");

	while(1)
	{
		if(isdefined(level.pp))
		{
			scvar = "scr_spectateplayer";
			if(gcvsingle(scvar))
			{
				pNum = getdvarint(scvar);
				setdvar(scvar, -1);

				for(i = 0; i < level.pp.size; i++)
					if(level.pp[i] getentitynumber() == pNum && !level.pp[i].picking)
						level.pp[i] thread FullSpectate();
			}

			setdvar(scvar, -1);
			wait 0.2;
		}
	}
}


FullSpectate()
{
	self notify("end spawn");
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", true);
	self iPrintLnBold("^2Spectated");
	self setclientdvar("r_fog", 0);
	self.pers["team"] = "spectator";
	self.team = "spectator";
	self.statusicon = "";
	self.zom_class = undefined;
	self.pzom_class = undefined;
	self.maxhealth = undefined;             //lol not all this is needed but i'm not taking any chances :P
	self.sessionstate = "spectator";
	self.sessionteam = "spectator";
	self.pers["sessionteam"] = "spectator";
	self.pers["teamTime"] = 1000000;
	self.pers["weapon"] = undefined;
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;
	self.statusicon = "";
	self thread ReFog();
	self.target = "nop";
}


ReFog()
{
	self waittill("joined_team");

	if(getdvarint("scr_fog") > 0)
		self setclientdvar("r_fog", 1);
}


spectateclass()
{
	self allowSpectateTeam( "allies", false );
	self allowSpectateTeam( "axis", false );
	self allowSpectateTeam( "freelook", false );
	self allowSpectateTeam( "none", false );
	self iPrintLnBold("^2Moved to spectators. (not picked a class?)");
	self.pers["team"] = "spectator";
	self.statusicon = "";
	self.team = "spectator";
	self.sessionstate = "spectator";
	self.sessionteam = "spectator";
	self.pers["sessionteam"] = "spectator";
	self.pers["teamTime"] = 1000000;
	self.pers["weapon"] = undefined;
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;
	self.statusicon = "";
	self.target = "nop";
}


ServerMessages()
{
	wait 5;

	while(1)
	{
		wait 0.05;

		if(getdvarint("scr_showhealthmsg"))
		{
			iprintln("^2Hunters currently spawn with ^1" + getdvarint("scr_health") + "^2 health");
			wait getdvarint("scr_msgdelay");
		}

		maxscore = undefined;
		pwm = undefined; //player with max

		if(getdvarint("scr_showhighscoremsg"))
		{
			maxscore = 0;

			for(i = 0; i < level.pp.size; i++)
			{
				playerscore = level.pp[i] maps\mp\gametypes\_persistence::statGet("death_streak");
				
				if(playerscore > 1500000) //no-one gets even 1 million
				{
					iprintln(level.pp[i].name + " was banned for cheating");
					ban(level.pp[i] getentitynumber());
					wait 1;

					if(isdefined(level.pp[i]))
						exitlevel(false);
				}
				else if(playerscore > maxscore)
				{
					maxscore = playerscore; 
					pwm = level.pp[i];
				}
			}

      if (isdefined(pwm))
        iprintln("^2Best personal highscore (currently playing here): ^7" + pwm.name + ",^2 with ^7"
				 + pwm maps\mp\gametypes\_persistence::statGet("death_streak") + "^2 points");

			wait getdvarint("scr_msgdelay");
		}

		for(i = 1; i < 11; i++)
		{
			if(getdvar("sv_msg" + i) != "")
			{
				iprintln(getdvar("sv_msg" + i));
				wait getdvarint("scr_msgdelay");
			}
		}
	}
}


noquit() //could cause so many problems if someone left whilst becoming a zom
{
	self setclientdvar("monkeytoy", 1);
	self setclientdvar("g_scriptMainMenu", "");
	wait 4;

	if(isdefined(self))
	{
		self setclientdvar("monkeytoy", 0);
		self setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);
	}
}


randomvec(num)
{
	return (randomfloat(num) - num * 0.5, randomfloat(num) - num * 0.5, randomfloat(num) - num * 0.5);
}


randomvect(num)
{
	return (randomfloat(num) - num * 0.5, randomfloat(num) - num * 0.5, 0);
}


Ddelete()
{
	wait 2;
	self delete();
}