#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;


ZomMusic()
{
	musiketa = getent ("musiketa", "targetname"); //for mp_zombieprison_v*
	if(isdefined(musiketa))
		musiketa delete();

	ambientstop();
	musicstop();

	level.music = getdvarint("scr_zommusic");
	ambientplay("ambient_zom_" + level.music);

	while(1)
	{
		wait 0.2;

		var = getdvarint("scr_zommusic");

		if(var == -1)
		{
			level.music = -1;
			thread LoopMusic();
			return;
		}
	
		if(var == 0)
		{
			level.music = 0;
			ambientstop(1);
		}
	
		if(level.music != var && var > 0)
		{
			ambientstop(1);
			{
				wait 1.1;
				ambientplay("ambient_zom_" + var);
				level.music = var;
			}
		}
	}
}


LoopMusic()
{
	while(1)
	{
		musicstop();

		ambientstop(1);
		ambientplay("ambient_zom_1", 1);
		wait 143.5;

		ambientstop(1);
		ambientplay("ambient_zom_4", 1);
		wait 131;

		ambientstop(1);
		ambientplay("ambient_zom_23", 1);
		wait 119;

		ambientstop(1);
		ambientplay("ambient_zom_15", 1);
		wait 135;

		ambientstop(1);
		ambientplay("ambient_zom_8", 1);
		wait 40;
	}
}


HealThePlayers()
{
	while (1)
	{
		wait 0.05;
		
		players = getentarray ("player", "classname");
		
		for(i = 0; i < players.size; i++)
		{
			p = players[i];
			
			if(p.lastdmgtime > 4
			 && p.pers["team"] == "axis"
			 && p.sessionstate == "playing"
			 && isalive(p))
			{
				if(p.health < (p.maxhealth - 15))
					p.health += 15;
				else if(p.health < p.maxhealth)
					p.health = p.maxhealth;
			}
		}
	}
}


Grave()
{
	wait 0.05;
	trace = bullettrace(self.origin, self.origin + (0,0,-10000), true, self);
	grave = spawn("script_model", trace["position"] + (0,0,-50));
	grave setmodel("ch_tombstone2");
	grave moveto(trace["position"], 3, 0, 0.3);

	angle = maps\mp\_utility::orientToNormal(trace["normal"]);

	if(angle[1] == 0 || angle[1] == 360)
		angle = (angle[0],randomInt(360),angle[2]);

	grave.angles = angle;
	grave.targetname = "grave";
}


AttackMelee()
{
	while(1)
	{
		wait 0.05;
		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];
			if(isdefined(p)
       && isdefined(p.pers)
       && p.pers["team"] == "axis"
			 && p attackbuttonpressed()
			 && p HasZomWeapon()
			 && !p usebuttonpressed()
			 && p.health > 0)
				p thread maps\mp\gametypes\zom::cc("+melee; -melee", true);
		}
	}
}


HasZomWeapon()
{
	if(self getcurrentweapon() == "defaultweapon_mp" || self getcurrentweapon() == "bite_mp")
		return true;

	else return false;
	//no skull, otherwise it would melee instead of shooting
}


MineCover() //surely this would be better somewhere else inside a bigger loop
{
	while(1)
	{
		wait 0.2;

		for(i = 0; i < level.pp.size; i++)
		{
			if(isdefined(level.pp[i]))
			{
				if(isdefined(level.pp[i].mine))
					level.pp[i] setstat(988, 1);
				
				else level.pp[i] setstat(988, 0);
			}
		}
	}
}