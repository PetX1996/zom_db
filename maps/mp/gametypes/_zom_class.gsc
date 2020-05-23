/////////////////////////////////////////////////////////
////       ///      ///     ////     /// ///// /////////
////   //  ///  //  ///  // ////  // ///  /// /////////
////   //  ///  //  ///     ////     ////    /////////
////   //  ///  //  ///      ///     /////  /////////
////   //  ///  //  ///  /// ///  /// ////  ////////
////       ///      ///      ///      ////  ///////
//////////////////////////////////////////////////

//This whole thing is really stupidly laid out and hard to mod (zom classes) but oh well

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{

	level.objused = [];
	for(i = 0; i < 16; i++) level.objused[i] = false;

	level.zom_repelfx = Loadfx("zom/repel");
	level.zom_unrepelfx = Loadfx("zom/unrepel");
	level.zom_boomfx = Loadfx("zom/boom");
	level.zom_fartfx = Loadfx("zom/fart");
	level.zom_icefx = Loadfx("zom/emit_ice");
	level.zom_iceblastfx = Loadfx("zom/iceblast");
	level.zom_strikefx = Loadfx("zom/lightstrike");
	level.zom_dog_ringfx = Loadfx("zom/dog_ring");
	level.zom_confusefx = Loadfx("zom/dog_confuse");
	level.zom_poisonfx = Loadfx ("zom/poison");
	level.zom_emit_electric = Loadfx("zom/emit_electric");
	level.zom_poisonringfx = Loadfx("zom/poison_ring");
	level.zom_scarefx = Loadfx("zom/scare");
	level.zom_ragefx = Loadfx("zom/ragefx");
	level.zom_teleportfx = Loadfx("zom/teleport");
	level.zom_lmdistortfx = Loadfx("zom/lastman_distort");
	level.zom_mineblink = Loadfx("zom/light_mine_blink");
	level.zom_spawnfx = Loadfx("zom/spawn");
	level.zom_minefx = Loadfx("zom/mine");
	level.zom_freezefx = Loadfx("zom/freeze");
	level.zom_bubblespawn = Loadfx("zom/bubblespawn");

	level thread OnPlayerConnect();

	thread AbilityPrimer();
	thread MiscClasses(); //poison/electric zombie fx & skull control
	thread ZomIce(); //ice zom fx
	thread DogStop(); //buggy way to stop dogs mantling and climbing ladders
}


OnPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread OnJoinedSpectators();
		player thread TimeUntilSpecial();
		player thread onMenuResponse();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined_spectators");
		self Closemenu();
	}
}


onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if(response == "fixmenu")
			self.fixmenu = true;

		if(self.health > 0 && self.pers["team"] != "spectator" && !self.used_ability)
		{
			if(response == "special")
				self thread Specials(true);
	
			if(response == "special2")
				self thread Specials(false);
		}
	}
}


StartChoice()
{
	special = getdvarint("scr_specialclass");
	dogs = getdvarint("scr_dogs");
	force = false;
	f = getdvar("scr_zomclass");

	if(f == "fast" || f == "poison" || f == "normal" || f == "electric" || f == "ice" || f == "dog" || f == "special")
		force = true;
	
	self.god = true;

	//<ent> Makeelem(x, y, alpha, text, sort);
	//<ent> MakeElemPic(x, y, alpha, sort, shader, x2, y2);
	
	self.selector = spawnstruct();

	if(isdefined(self.pzom_class)) //if they've picked a class before, use that one
	{
		//fast poison normal electric ice dog special

		if((self.pzom_class == 7 && !special) || (self.pzom_class == 6 && !dogs)) //set their default to fast zom
			self.pzom_class = 1;
	}
	else //default class...
	{
		self.pzom_class = 1;
	}

	self.selector.place = self.pzom_class;
	self setstat(983, self.pzom_class); //set menu

	if(!force)
	{
		self openmenu("zom_class_pick");
		self thread Rotate();

		if(getdvarint("scr_autospawn"))
			self thread TimeOutSpawn();
	}

	self.picking = true;
	
	if(f == "fast")
		self.selector.place = 1;

	else if(f == "poison")
		self.selector.place = 2;

	else if(f == "normal")
		self.selector.place = 3;

	else if(f == "electric")
		self.selector.place = 4;

	else if(f == "ice")
		self.selector.place = 5;

	else if(f == "dog")
	{
		self.selector.place = 6;
		if(!dogs) self.selector.place = 1;
	}

	else if(f == "special")
	{
		self.selector.place = 7;
		if(!special) self.selector.place = 1;
	}

	if(force)
		self setstat(983, self.selector.place); //fix for wrong special info text (hud.menu) when force class is on

	if(self.selector.place == 7)
		setSpecialDvars(); //update their ZCP menu settings and speed/HP

	lm = false;

	while(1)
	{
		wait 0.05;

		if(!isdefined(self))
			return;

		if(self.sessionteam == "spectator")
			return;

		if(isdefined(level.lastman) && level.lastman == self)
			self.forcespawn = true;

		if(self UseButtonPressed() || force || self.forcespawn)
		{
			self notify("endtimeout");

			if(self.forcespawn && isdefined(level.lastman) && level.lastman == self)
			{
				lm = true; //uh can't remember what this is actually used for
				self.selector.place = 1; //smooth mooovvveeee
			}

			self.forcespawn = false;

			if(self.selector.place == 1)
				self.zom_class = "fast";

			else if(self.selector.place == 2)
				self.zom_class = "poison";

			else if(self.selector.place == 3)
				self.zom_class = "normal";

			else if(self.selector.place == 4)
				self.zom_class = "electric";

			else if(self.selector.place == 5)
				self.zom_class = "ice";

			else if(self.selector.place == 6)
				self.zom_class = "dog";

			else if(self.selector.place == 7)
				self.zom_class = "special";

			//none of this stuff needs to change for disabling dogs/specials because 
			//we only stop them from picking a dog/special, not spawning as it

			self.pzom_class = self.selector.place;
			self.picking = false;
			self notify("classpicked");

			if(getdvarint("scr_zomspawnprotection"))
				self thread SpawnProtect();
			else
				self.god = false;

			self setstat(982, 0);

			self detachall();
			self setmodel("");

			if(self.zom_class != "dog")
				self setclientdvar("cg_drawgun", 1);

			if(self.zom_class == "poison" || self.zom_class == "normal" || self.zom_class == "fast")
				self character\zom_normal::main();

			else if(self.zom_class == "electric")
				self character\zom_electric::main();

			else if(self.zom_class == "ice")
				self character\zom_ice::main();

			else if(self.zom_class == "special")
				self SetSpecialModel();

			if(self.zom_class == "dog")
			{
				self character\zom_dog::main();

				if(!self.dogvars)
				{
					self.dogvars = true;
					self setDogVars(true);
				}
			}
			else if(self.dogvars)
			{
				self.dogvars = false;
				self setDogVars(false);
			}

			if(isdefined(self.zom_class))
			{
				switch(self.zom_class)
				{
					case "fast":
						self.statusicon = "hud_zombie_fast";
							break;

					case "poison":
						self.statusicon = "hud_hh1"; //thanks IW
							break;

					case "normal":
						self.statusicon = "hud_zombie_normal";
							break;

					case "electric":
						self.statusicon = "hud_zombie_electric";
							break;

					case "ice":
						self.statusicon = "hud_zombie_ice";
							break;

					case "dog":
						self.statusicon = "hud_zombie_dog";
							break;

					case "special":
						self.statusicon = "hud_zombie_special";
							break;

					default:
						self.statusicon = "";
							break;
				}
			}

			self.linker delete();
			self Closemenu();

			if(isdefined(self.zom_class))
			{
				if(self.zom_class == "dog")
				{
					self GiveWeapon("bite_mp");
					self SwitchToWeapon("bite_mp");
				}
				else
				{
					self GiveWeapon("defaultweapon_mp");
					self SwitchToWeapon("defaultweapon_mp");
				}
			}

			return;
		}
	}
}


SetSpecialModel()
{
	//ok so could have a headmodel might not, scr_specialclass_model and scr_specialclass_headmodel

	self detachAll();
	self setModel(getdvar("scr_specialclass_model"));

	if(getdvar("scr_specialclass_model_head") != "")
		self attach(getdvar("scr_specialclass_model_head"), "", true);
}


SetDogvars(set)
{
	if(set)
	{
		self setclientdvar("cg_drawgun", 0);
		self setclientdvar("cg_fovmin", 110);
	
		self setclientdvar("r_filmtweakdesaturation", 1);
		self setclientdvar("r_filmtweakenable", 1);
		self setclientdvar("r_filmusetweaks", 1);
		self setclientdvar("r_filmtweakbrightness", 0.2);
	}
	else
	{
		self setclientdvar("cg_fovmin", 10);
		self setclientdvar("cg_drawgun", 1);

		self setclientdvar("r_filmtweakdesaturation", 0);
		self setclientdvar("r_filmtweakenable", 0);
		self setclientdvar("r_filmusetweaks", 0);
		self setclientdvar("r_filmtweakbrightness", 0);
	}
}

SpawnProtect()
{
	self endon("death");
	self endon("disconnect");

	if(getdvarint("scr_spawnprotectmsg"))
		self iprintln("^2Spawn protection active...");

	wait getdvarint("scr_zomspawnprotection");

	if(getdvarint("scr_spawnprotectmsg"))
		self iprintln("^2Spawn protection finished");

	self.god = false;
}


Rotate()
{
	self endon("disconnect");
	self endon("classpicked");

	dogs = getdvarint("scr_dogs");
	special = getdvarint("scr_specialclass");
	while(1)
	{
		wait 0.05;

		if(self.sessionteam == "spectator" || self UseButtonPressed())
			return;

		if(isDefined(self.fixmenu) && self.fixmenu)
		{
			self.fixmenu = false;
			wait 0.1;
		
			self setstat(983, self.selector.place);
			self openmenu("zom_class_pick");
		}

		if(self AttackButtonPressed())
		{
			self PlayLocalSound("zom_class_change");

			if(self.selector.place == 1) //is on fast
			{
				self.selector.place++; //move to poison
				self setstat(983, 2);
			}
		
			else if(self.selector.place == 2) //is on poison
			{
				self.selector.place++; //move to normal
				self setstat(983, 3);
			}
		
			else if(self.selector.place == 3) //is on normal
			{
				self.selector.place++; //move to electric
				self setstat(983, 4);
			}

			else if(self.selector.place == 4) //is on electric
			{
				self.selector.place++; //move to ice
				self setstat(983, 5);
			}

			//don't look at this next bit it pains me

			else if(self.selector.place == 5) //is on ice
			{
				if(dogs) //move to dog
				{
					self.selector.place = 6;
					self setstat(983, 6);
				}
				else if(special) //move to special
				{
					self.selector.place = 7;
					self setstat(983, 7);
					self setSpecialDvars();
				}
				else //dogs and specials are disabled, move to fast
				{
					self.selector.place = 1;
					self setstat(983, 1);
				}
			}

			else if(self.selector.place == 6) //is on dog
			{
				if(special) //move to special
				{
					self.selector.place = 7; 
					self setstat(983, 7);
					self setSpecialDvars();
				}
				else //move to fast
				{
					self.selector.place = 1;
					self setstat(983, 1);
				}
			}

			else if(self.selector.place == 7) //is on special
			{
				self.selector.place = 1; //move to fast
				self setstat(983, 1);
			}
		
			while(self AttackButtonPressed()) wait 0.05; //wait whilst they're clicking
		}
	}
}


CheckSpecialHealth()
{
	var1 = "scr_specialclass_health";
	var2 = "scr_specialclass_fzhealth";

	if(getDvarFloat(var1) > 1000
	 || getDvarFloat(var2) > 1000
	 || getDvarFloat(var1) < 1
	 || getDvarFloat(var2) < 1)
	{
		setDvar(var1, 100);
		setDvar(var2, 200);
	}
}


setSpecialDvars() //messy :D
{
	CheckSpecialHealth();

	self setClientDvar("cl_specialclass_name", getDvar("scr_specialclass_name"));
	self setClientDvar("cl_specialclass_speed", getDvarFloat("scr_specialclass_speed"));
	self setClientDvar("cl_specialclass_health", getDvarint("scr_specialclass_health"));
	self setClientDvar("cl_specialclass_damage", getDvarint("scr_specialclass_damage"));

	spec = []; spec[0] = "specialclass_special1"; spec[1] = "specialclass_special2";

	for(i = 0; i < spec.size; i++)
	{
		switch(getdvar("scr_" + spec[i]))
		{
			case "hj": self setClientDvar("cl_" + spec[i], "High Jump"); break;
			case "zc": self setClientDvar("cl_" + spec[i], "Zombie Call"); break;
			case "zf": self setClientDvar("cl_" + spec[i], "Zombie Fart"); break;
			case "zs": self setClientDvar("cl_" + spec[i], "Scare"); break;
			case "ls": self setClientDvar("cl_" + spec[i], "Lightning Strike"); break;
			case "sb": self setClientDvar("cl_" + spec[i], "Sonic Boom"); break;
			case "ib": self setClientDvar("cl_" + spec[i], "Ice Blast"); break;
			case "am": self setClientDvar("cl_" + spec[i], "Avoid Mines"); break;
			case "ch": self setClientDvar("cl_" + spec[i], "Confuse Hunters"); break;
		}
	}
}


ZomIce()
{
	while(1)
	{
		wait 0.3;
		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];

			if(p.pers["team"] == "axis"
			 && isdefined(p.zom_class)
			 && p.zom_class == "ice"
			 && game["state"] != "postgame"
			 && p ia())
			{
				if(p GetStance() != "prone")
					playfx(level.zom_icefx, p.origin + (0, 0, 30));
				else
					playfx(level.zom_icefx, p.origin + (0, 0, 5));

				if(p.ragefx)
				{
					playfx(level.zom_ragefx, p.origin + (0, 0, 30));
					//p playsound("zom_rage_e"); ///eeyyeah mkay it's better without the sound
				}
			}
		}
	}
}


MiscClasses()
{
	while(1)
	{
		wait 0.5;
	
		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];

			if(!p ia())
				continue;

			isaxis = false;
			isallies = false;

			if(p.pers["team"] == "axis")
				isaxis = true;

			if(p.pers["team"] == "allies")
				isallies = true;

			class = p.zom_class;

			if(isaxis && p getstance() != "prone" && isdefined(class))
			{
				if(class == "poison")
					playfx(level.zom_poisonfx, p.origin + (0, 0, 30));

				if(class == "electric")
				{
					playfx(level.zom_emit_electric, p.origin + (0, 0, 25));

					switch(randomint(5))
					{
						case 0:	case 1: case 3: case 4: default: break;
						case 2:	p playsound("zom_electric_spark"); break;
					}
				}
			}
		}

		if(isdefined(level.lp.size) && level.lp.size <= getdvarint("scr_hunskull"))
		{
			level.skulls = true;

			for(z = 0; z < level.pp.size; z++)
			{
				p = level.pp[z];

				weap = p GetCurrentWeapon();
				clip = p GetWeaponAmmoClip(weap);

				if(clip == 0 && weap == "skull_mp")
				{
					p TakeWeapon("skull_mp");
					p SwitchToWeapon("defaultweapon_mp");
				}

				if(p getammocount("skull_mp") > 3) //cheaters
				{
					p SetWeaponAmmoClip("skull_mp", 3);
					p SetWeaponAmmoStock("skull_mp", 0);
				}

				if(p.health > 0
				 && isdefined(p.zom_class)

				 && (p.zom_class == "fast"
				 || (p.zom_class == "special" && getDvarInt("scr_specialclass_skulls")))

				 && !isdefined(p.gotskull)
				 && p ia()
				 && p.pers["team"] == "axis")
				{
					p GiveWeapon("skull_mp"); //default ammo is 2...
					p SwitchToWeapon("skull_mp");
					
					rank = p maps\mp\gametypes\_rank::getrank();

					if(rank >= 65 && level.perks) 
						p SetWeaponAmmoClip("skull_mp", 3); //...but give them 3 if they are past lvl 66
					
					p.gotskull = true;
				}
			}
		}
		else
		{
			level.skulls = false;
		}
	}
}


AbilityPrimer() //handles abils through use/atack/melee
{
	while(1)
	{
		wait 0.05;
		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];

			if(isdefined(p) && p ia())
			{
				///Mines//////////////////////////////////////////////////////////////////////////////////
				if(p AttackButtonPressed()
				 && p UseButtonPressed()
				 && p.pers["team"] == "allies")
					p thread Specials(true);
				//////////////////////////////////////////////////////////////////////////////////////////


				///Repels/////////////////////////////////////////////////////////////////////////////////
				if(p AttackButtonPressed()
				 && p MeleeButtonPressed()
				 && p.pers["team"] == "allies"
				 && !self.repelled)
					p thread Specials(false);
				//////////////////////////////////////////////////////////////////////////////////////////


				///Zombies use + attack///////////////////////////////////////////////////////////////////
				if(p AttackButtonPressed()
				 && p UseButtonPressed()
				 && p.pers["team"] == "axis"
				 && !p.used_ability)
					p thread Specials(true);
				//////////////////////////////////////////////////////////////////////////////////////////


				///Zombies nade button////////////////////////////////////////////////////////////////////
				if(p Fragbuttonpressed()
				 && p.pers["team"] == "axis"
				 && !p.used_ability)
					p thread Specials(false);
				//////////////////////////////////////////////////////////////////////////////////////////
			}
		}
	}
}


Specials(first)
{
	if(isdefined(self.highjumpdelay))
		return;

	//first = true: first special ability
	//first = false: second special ability

	if(self.pers["team"] == "allies")
	{
		if(first
		 && !isdefined(self.mine) //if not already got a mine + not been hit by scare
		 && getdvarint("scr_mines")
		 && self.minenum > -1
		 && self.canmine)
			self thread PlantMine();

		if(first
		 && isdefined(self.mine) //if already got one and can plant/move mines
		 && self.canmine
		 && !isdefined(self.mmtimeout)
		 && !self.mine.exploding2
		 && self.movedmine < getdvarint("scr_movemines"))
			self thread MoveMine();

		if(!first
		 && !self.repelled //if hasn't already used repel within some time
		 && self.repelnum > -1)
			self thread Repel();

		self.used_ability = false;
	}

	else if(self.pers["team"] == "axis")
	{
		self.used_ability = true;

		if(self.zom_class == "fast")
		{
			if(first)
				self thread HighJump();

			//if(!first)
				//skulls handled elsewhere
		}
		else if(self.zom_class == "poison")
		{
			if(first)
				self thread ZombieCall();
			else
				self thread HighJump();
		}
		else if(self.zom_class == "normal")
		{
			if(first)
				self thread ZombieFart();
			else
				self thread Scare();
		}
		else if(self.zom_class == "electric")
		{
			if(first)
				self thread LightningStrike();
			else
				self thread SonicBoom();
		}
		else if(self.zom_class == "ice")
		{
			if(first)
				self thread IceBlast();
			else
				self thread Rage();
		}
		else if(self.zom_class == "dog")
		{
			if(first)
				self thread AvoidMines();
			else
				self thread ConfuseHunters();
		}
		else if(self.zom_class == "special")
		{
			switchOn = "scr_specialclass_special1";

			if(!first) switchOn = "scr_specialclass_special2";

			switchOn = getDvar(switchOn);

			switch(switchOn)
			{
				case "hj": self thread HighJump(); break;
				case "zc": self thread ZombieCall(); break;
				case "zf": self thread ZombieFart(); break;
				case "zs": self thread Scare(); break;
				case "ls": self thread LightningStrike(); break;
				case "sb": self thread SonicBoom(); break;
				case "ib": self thread IceBlast(); break;
				case "am": self thread AvoidMines(); break;
				case "ch": self thread ConfuseHunters(); break;
			}
		}

		self thread Countdown();
	}
}


PlantMine() //hunter
{
  self endon("disconnect");
  self endon("death");

	for(i = 0; i < level.pp.size; i++)
		level.pp[i] iprintln(self.name + " ^2placed a mine");

	self playsound("zom_mine_place");

	self.minenum--;
	self.mine = spawn("script_model", self.origin + (0, 0, 30));
	self.mine.exploding2 = false;
	self.mine.moving = true;
	self.mmtimeout = 10;
	self thread mmtime();

	trace = undefined;

	trace = bullettrace(self.origin, self.origin + (0, 0, -100000), false, self.mine);
	rank = self maps\mp\gametypes\_rank::getrank();

	if(isdefined(rank) && rank >= 99)
		self.mine setmodel("mine_gold"); //yay for eye candy.
	else
		self.mine setmodel("zom_mine");

	self.mine.targetname = "mine";
	self.mine.owner = self;
	self.mine moveto(trace["position"] + (0, 0, 3), 0.2);
	self.mine.angles = orientToNormal(trace["normal"]);
	wait 0.3;
	self.mine.moving = false;

	self.mine thread MineWatch(); //watch for detonate
}


MoveMine()
{
	if(self.health < 1)
		return;

	self.movedmine++;
	self.mine.moving = true;

	self iprintln("^2You moved your mine");
	self playsound("zom_mine_place");

	mine = self.mine;
	mine.origin = self.origin + (0, 0, 40);

	self.mmtimeout = 2;
	self thread mmtime();

	trace = bullettrace(self.origin, self.origin + (0, 0, -10000), true, self);
	mineplace = trace["position"];

	self.mine moveto(mineplace + (0, 0, 3), 0.2);
	self.mine.angles = orientToNormal(trace["normal"]);

	wait 0.3;

	self.mine.moving = false;
}


mmtime()
{
	self endon("death");
	self endon("disconnect");
	self endon("mmtstop");

	wait self.mmtimeout;
	self.mmtimeout = undefined;
}


MineWatch()
{
	self thread ExplodeOn(); //explode after getting shot by the owner a few times
	self thread Blink();
	
	//wait till an enemy comes to blow the mine up...messy but it works

	while(1)
	{
		wait 0.1;
	
		if(isdefined(self) && !isdefined(self.owner))
			self delete();

		if(!isdefined(self))
			return;

		for(o = 0; o < level.xp.size; o++)
		{
			p = level.xp[o];

			if(isdefined(distance(p.origin, self.origin)) //oh wow this is innefficient
			 && isdefined(p.health)
			 && distance(p.origin, self.origin) <= 200
			 && p.health > 0
			 && !p.god
			 && !self.exploding2
			 && !p.beingmined
			 && !self.moving
			 && !p.dogability)
			{
				if(self.owner.health < 1) return; //stop it if they're dead, it won't help them now
				self MineExplode(p);
			}
		}
	}
}


ExplodeOn()
{

	self setcandamage(true);
	self.ownershot = false;
	self.owner endon("disconnect");
	self.num = 0;

	while(1)
	{
		self waittill("damage", dmg, who, dir, point, mod);

		if(who.pers["team"] == "allies" && who != self.owner && mod != "MOD_EXPLOSIVE")
			who iprintln("^2This is " + self.owner.name + "'s mine");

		if(who == self.owner && !self.ownershot && !self.exploding2)
		{
			self.ownershot = true;
			who iprintlnbold("^2Your mine will blow up after a few shots");
			wait .2;
			continue;
		}

		if(who == self.owner)
			self.num++;

		if(self.num > 5 && !self.moving)
		{
			self MineExplode();
			return;
		}
	}
}


MineExplode(player) //carry across the player if it was a zombie setting it off
{
	if(isdefined(player))
		player.beingmined = true;
	
	self.exploding2 = true;
	self movez(40, 0.7, 0, 0.2);
	self rotateyaw(360, 0.7);
	self playsound("zom_clicky");
	plusfort = spawn("script_model", self.origin);
	wait 0.7;

	if(isdefined(player))
		player.beingmined = false;
	
	self.owner radiusDamage(self.origin, 200, 69, 69, self.owner, "MOD_EXPLOSIVE");
	PhysicsExplosionSphere(self.origin + (0,0,50), 200, 100, 2);	

	self hide();
	self notify("end blink");

	self.owner notify("mmtstop"); //stop the move mine timeout
	self.owner.mmtimeout = undefined;

	if(self.owner.health < 1)
	{
		self.owner.mine = undefined;
		self delete();
		plusfort delete();
		return;
	}

	playfx(level.zom_minefx, self.origin);
	self playsound("exp_armor_vehicle");
	plusfort playsound("exp_armor_vehicle");

	//check for any axis in radius to kill them
	for(y = 0; y < level.xp.size; y++)
	{
		if(distance(level.xp[y].origin, self.origin) <= 200 && level.xp[y].health > 0 && !level.xp[y].god)
		{
			self.owner.score += 500;
			self.owner.score2 += 500;
			self.owner.score3 += 500;

			level.xp[y].minehook = true;
			level.xp[y].minedby = self.owner;
			level.xp[y] suicide(); //fake a death using minehook...fixes anims
		}
	}

	self.owner.mine = undefined;
	self.owner.movedmine = 0;

	wait 1;
	plusfort delete();
	self delete();
}


Blink()
{
	self endon("end blink");

	while(1)
	{
		wait 1;
	
		if(isdefined(self))
			playfx(level.zom_mineblink, self.origin);
	
		else return;
	}
}


Repel() //hunter
{
	self endon("death");
	self endon("disconnect");

	self.repelled = true; //stop the ability triggering again quickly, like used_ability
	self.repelNum--;

	PhysicsExplosionSphere(self.origin + (0,0,50), 200, 100, 2);
	self playsound("zom_repel");
	playfx(level.zom_repelfx, self.origin + (0, 0, 30));
	
	hit = false;

	for(i = 0; i < level.pp.size; i++)
	{
		p = level.pp[i];

		if(p.pers["team"] == "axis"
		 && p.health > 0
		 && isdefined(distance(p.origin, self.origin))
		 && distance(self.origin, p.origin) <= 200
		 && IsInViewNoEnts(self,p))
		{
			p iprintlnbold(self.name + " repelled you");
			self iprintln("You repelled " + p.name);

			hit = true;

			p.health += 600;

			p thread maps\mp\gametypes\_globallogic::finishPlayerDamageWrapper(p, p, 200, 0, "MOD_PROJECTILE", "rpg_mp", self.origin + (0,0,-10), vectornormalize(p.origin - (self.origin - (0,0,10))), "none", 0);
			p thread maps\mp\gametypes\_globallogic::finishPlayerDamageWrapper(p, p, 200, 0, "MOD_PROJECTILE", "rpg_mp", self.origin + (0,0,-10), vectornormalize(p.origin - (self.origin - (0,0,10))), "none", 0);
			p thread maps\mp\gametypes\_globallogic::finishPlayerDamageWrapper(p, p, 200, 0, "MOD_PROJECTILE", "rpg_mp", self.origin + (0,0,-10), vectornormalize(p.origin - (self.origin - (0,0,10))), "none", 0);
		}
	}

	wait 2;

	if(!hit)
	{
		self.repelNum++;
		self iprintlnbold("^2Your last repel missed, you get another one.");
		playfx(level.zom_unrepelfx, self.origin + (0, 0, 30));
	}
	self.repelled = false;
}


HighJump() //fast, poison zoms
{
	self endon("death");
	self endon("disconnect");

	if(!self isonground() || self.health < 100)
	{
		self notify("cancel countdown");
		self.used_ability = false;

		if(self.health < 100)
			self iprintln("^1You must have at least 100 health to do this");
		if(!self isonground())
			self iprintln("^1You must be on the ground to do this");

		self.highjumpdelay = true;
		self thread JumpDelay();
		return;
	}

	if(self isonground())
	{
		self.specialtime = 15;
		PhysicsExplosionSphere(self.origin + (0,0,50), 200, 100, 2);
		self playsound("zom_high_jump");

		away = (self.origin + (0, 0, -50));
		prehealth = self.health;
		self.health = 2000;


		self maps\mp\gametypes\_globallogic::finishPlayerDamageWrapper(self, self, int(getdvarint("scr_gravity") * 0.25), 0, "MOD_PROJECTILE", "rpg_mp", away, vectornormalize(self.origin - away), "none", 0);
		self maps\mp\gametypes\_globallogic::finishPlayerDamageWrapper(self, self, int(getdvarint("scr_gravity") * 0.25), 0, "MOD_PROJECTILE", "rpg_mp", away, vectornormalize(self.origin - away), "none", 0);

		self.health = prehealth;
	}
}


JumpDelay()
{
	wait 1;
	self.highjumpdelay = undefined;
}


ZombieCall() //poison zom
{
	self.specialtime = 10;
	place = self.origin;

	self Playsound("zom_call");
	playfx(level.zom_poisonringfx, self.origin + (0,0,40));

	self.objnum = GetNextObjNum();
	objective_add(self.objnum, "active", place, "hud_zombie_call");
	objective_team(self.objnum, "axis");

	self thread lolz();
}


getrid()
{
	wait 15;
	self destroy();
}


lolz()
{
	thing = self.objnum; //just in case self.objnum changes
	wait 7;
	deletecompassIcon(thing);
}


ZombieFart() //normal zom
{
	self.specialtime = 10;

	playfx(level.zom_fartfx, self.origin + (0,0,30));

	self playsound("zom_fart");

	if(isdefined(level.lp))
	{
		for(i = 0; i < level.lp.size; i++)
		{
			p = level.lp[i];

			if(isdefined(distance(p.origin, self.origin)) && p ia())
			{
				if(distance(p.origin, self.origin) <= 150 && !p.fartedon)
				{
					p.fartedon = true;
					p ShellShock("tankblast", 3);
					p iPrintLnBold(self.name + " farted on you");
					self iprintln("You farted on " + p.name);
					p thread AntiFart();
				}
			}
		}
	}
}


AntiFart()
{
	self endon("disconnect");
	self notify("twitter");
	self endon("twitter");

	wait 5;

	self.fartedon = false;
}


Scare() //normal zom
{
	self.specialtime = 15;

	object = spawn("script_model", self.origin + (0, 0, 40));
	object setmodel("tag_origin");

	object2 = spawn("script_model", self.origin + (0, 0, 40));
	object2 setmodel("tag_origin");

	wait 0.05;

	playfx(level.zom_scarefx, self.origin + (0, 0, 40));
	earthquake(0.6, 0.6, self.origin, 250);

	object2 playsound("zom_scare");
	object playsound("zom_scare");
	self playsound("zom_scare");

	for(i = 0; i < level.pp.size; i++)
	{
		p = level.pp[i];
		if(p.pers["team"] == "allies" && p ia() && isdefined(distance(p.origin, self.origin)))
		{
			if(distance(self.origin, p.origin) <= 150 && IsInView(self,p))
			{
				p.canmine = false;
				self iprintln("You scared " + p.name);
				p thread LetMeMine(self.name);
			}
		}
	}
	
	wait 1;

	object delete();
	object2 delete();
}


LetMeMine(aName)
{
	self endon("death");
	self endon("disconnect");
	self notify("end scare");
	self endon("end scare");

	delay = 7;

	if(isdefined(self.frozen)) //aww
		delay = 3; //we'll cut it down since they're screwed anyway

	self iprintlnbold(aName + " scared you (can't drop mines for " + delay + " secs)");

	wait delay;

	self.canmine = true;
	self iprintlnbold("^2You can drop mines again");
}



LightningStrike() //electric zom
{
	self.specialtime = 15;

	object = spawn("script_model", self.origin + (0, 0, 100));
	object2 = spawn("script_model", self.origin + (0, 0, 100));

	object2.angles = (0,90,0); //redundant? autosprite...

	object setmodel("tag_origin");
	object2 setmodel("tag_origin");

	wait 0.05;

	self radiusDamage(self.origin, 200, 69, 69, self, "MOD_EXPLOSIVE");
	PhysicsExplosionSphere(self.origin + (0,0,50), 200, 100, 2);
	earthquake(0.6, 0.6, self.origin, 150);

	object playsound("zom_electric_strike");
	object2 playsound("zom_electric_strike");

	playfxontag(level.zom_strikefx, object, "tag_origin");
	playfxontag(level.zom_strikefx, object2, "tag_origin");
	
	for(i = 0; i < level.pp.size; i++)
	{
		player = level.pp[i];
		if(player.pers["team"] == "allies" && player ia() && isdefined(distance(player.origin, self.origin)))
		{
			if(distance(self.origin, player.origin) <= 150 && IsInView(self,player))
			{
				player iprintlnbold(self.name + " struck you by lightning");

				player.lastdmgabil = "lightning";

				player thread maps\mp\gametypes\_globallogic::Callback_PlayerDamage(self, self, 26, 0, "MOD_SUICIDE", "electric_mp", player.origin, self.origin + (0, 0, 50), "none", 0);

			}
		}
	}
	
	wait 1;
	object delete();
	object2 delete();
}


SonicBoom() //electric zom
{
	self.specialtime = 10;

	self radiusDamage(self.origin, 200, 69, 69, self, "MOD_EXPLOSIVE");
	PhysicsExplosionSphere(self.origin + (0,0,50), 250, 100, 2);
	earthquake(0.6, 0.6, self.origin, 250);

	self playsound("zom_boom");
	playfx(level.zom_boomfx, self.origin + (0,0,40));

	for(i = 0; i < level.pp.size; i++)
	{
		p = level.pp[i];
		if(p.pers["team"] == "allies" && p ia() && isdefined(distance(p.origin, self.origin)))
		{
			if(distance(self.origin, p.origin) <= 250 && IsInView(self,p) && !isdefined(p.boomed))
			{
				p.boomed = true;
				p ShellShock("jeepride_zak", 7);
				p iprintlnbold(self.name + " used sonic boom on you");
				self iprintln("You sonic boomed " + p.name);
				p thread GiveBackSound();
			}
		}
	}
}


GiveBackSound()
{
	self endon("disconnect");
	self endon("death");

	wait 7;
	self.boomed = undefined;
	self StopShellShock();
}


IceBlast() //ice zom
{
	self.specialtime = 15;

	object = spawn("script_model",self.origin + (0,0,40));
	object setmodel("tag_origin");

	wait 0.05;

	self radiusDamage(self.origin, 200, 69, 69, self, "MOD_EXPLOSIVE");
	PhysicsExplosionSphere(self.origin + (0,0,50), 200, 100, 2);
	earthquake( 0.6, 0.6, self.origin, 150 );

	object playsound("zom_ice_blast");
	self playsound("zom_ice_blast");

	playfxontag(level.zom_iceblastfx, object, "tag_origin");
	
	for(i = 0; i < level.pp.size; i++)
	{
		p = level.pp[i];

		if(p.pers["team"] == "allies"
		 && p ia()
		 && isdefined(distance(p.origin, self.origin))
		 && distance(self.origin, p.origin) <= 170
		 && IsInView(self,p))
		{
			p iprintlnbold(self.name + " ice blasted you");
			p.lastdmgabil = "ice";

			p setmovespeedscale(0.85);

			p thread UnFreezeMARKTWO(); //hehe

			p thread maps\mp\gametypes\_globallogic::Callback_PlayerDamage(self, self, 25, 0, "MOD_SUICIDE",
			"ice_mp", p.origin, self.origin + (0,0,50), "none", 0);
		}
	}
	
	wait 1;

	object delete();
}


UnFreezeMARKTWO()
{
	self endon("death");
	self endon("disconnect");
	self notify("end freezev2");
	self endon("end freezev2");

	wait 3;

	self setmovespeedscale(1);

	rank = self maps\mp\gametypes\_rank::getrank();

	if(rank >= 65 && level.perks)
		self setMoveSpeedScale(1.1);

	self iprintln("^2You unfroze");	
}


Rage() //ice zom
{
	self.specialtime = 30;

	self playsound("zom_rage");

	self endon("death");
	self endon("disconnect");

	wait 2;

	earthquake(0.6, 0.6, self.origin, 250);
	self radiusDamage(self.origin, 200, 69, 69, self, "MOD_EXPLOSIVE");
	PhysicsExplosionSphere(self.origin + (0,0,50), 250, 100, 2);

	self setmovespeedscale(0.7);

	prehealth = self.health;
	premax = self.maxhealth;

	if(self.health < 800 && self.maxhealth != 1000)
	{
		self.maxhealth = 800;
		self.health = 800;
	}
	
	self.ragefx = true;

	wait 15;

	self.ragefx = false;

	self.maxhealth = premax;
	self.health = prehealth;
}


AvoidMines() //dog zom
{
	self endon("death");
	self endon("disconnect");
	self.specialtime = 25;

	object = spawn("script_model", self.origin);
	object playsound("zom_dog_special");

	self playsound("zom_dog_special");
	PlayFx(level.zom_dog_ringfx, self.origin + (0,0,40));

	self iprintlnbold("^2You won't set mines off for 15 seconds");
	self.dogability = true;

	if(self.zom_class == "dog")
		self setmovespeedscale(1.1);

	wait 2;

	object delete();
	wait 8;

	self iprintln("Five seconds left to avoid mines...");
	wait 5;

	if(self.zom_class == "dog")
		self setmovespeedscale(1.3);

	self.dogability = false;
}


ConfuseHunters() //dog zom
{
	self.specialtime = 20;

	object = spawn("script_model", self.origin);
	object playsound("zom_disorient");

	self playsound("zom_disorient");
	PlayFx(level.zom_confusefx, self.origin + (0,0,40));

	for(i = 0; i < level.pp.size; i++)
	{
		p = level.pp[i];
		if(p.pers["team"] == "allies" && p ia() && isdefined(distance(p.origin, self.origin)))
		{
			if(distance(self.origin, p.origin) <= 250 && IsInView(self,p))
			{
				p iprintlnbold(self.name + " confused you");
				self iprintln("You confused " + p.name);

				p thread ConfuseMe();
			}
		}
	}

	wait 2;

	object delete();
}


ConfuseMe()
{
	self setplayerangles(maps\mp\gametypes\_players::randomvect(180));
	wait 0.1;
	self setplayerangles(maps\mp\gametypes\_players::randomvect(180));
	wait 0.1;
	self setplayerangles(maps\mp\gametypes\_players::randomvect(180));
}


IsInView(aimer,target)
{
	tracer = bullettrace(aimer.origin + (0,0,40), target.origin + (0,0,40), true, aimer);
	check = distance((target.origin + (0,0,40)), tracer["position"]);

	if(check < 40)
		return true;

	else return false;
}


GetNextObjNum()
{
	for(i = 0; i < 16; i++)
	{
		if(level.objused[i] == true)
			continue;
		
		level.objused[i] = true;
		return (i);
	}
	return -1;
}


deletecompassIcon(num)
{
	if(isdefined(num))
	{
		objective_delete(num);
		level.objused[num] = false;
	}

	else if(isdefined(self.objnum))
	{
		objective_delete(self.objnum);
		level.objused[self.objnum] = false;
		self.objnum = undefined;
	}
}


ia() //IsAlive...I don't trust the built in one
{
	if(self.health > 0) return true;
	else return false;
}


MakeElem(x, y, alpha, text, sort)
{
	elem = NewClientHudElem(self);
	elem.alignX = "center";
	elem.alignY = "middle";
	elem.font = "objective";
	elem.archived = true;
	if(isdefined(x)) elem.x = x;
	if(isdefined(y)) elem.y = y;
	elem.alpha = alpha;
	elem.sort = sort;
	elem.fontscale = 1.4;
	elem settext(text);
	return elem;
}


MakeElemPic(x, y, alpha, sort, shader, x2, y2)
{
	elem = NewClientHudElem(self);
	elem.alignX = "center";
	elem.alignY = "middle";
	elem.font = "objective";
	elem.archived = true;
	if(isdefined(x)) elem.x = x;
	if(isdefined(y)) elem.y = y;
	elem.alpha = alpha;
	elem.sort = sort;
	elem.fontscale = 1.4;
	elem setshader(shader, x2, y2);
	return elem;
}


TimeUntilSpecial()
{
	self endon("disconnect");

	while(1)
	{
		wait 0.1;

		if(isdefined(self.pers["team"]) && self.pers["team"] == "axis")
		{
			self thread maps\mp\gametypes\_weapons::detach_all_weapons(); //hovering weapons fix

			self setstat(985, 0);

			if(self.specialtime > 0)
				self setstat(987, self.specialtime);

			if(self.specialtime == 0)
				self setstat(987, 0);
		}
	}
}


Countdown()
{
	self endon("cancel countdown");
	self endon("death");
	self endon("disconnect");
	self setstat(960, self.specialtime); //one time for the bar

	rank = self maps\mp\gametypes\_rank::getrank();

	while(1)
	{
		if(self.zom_class != "ice" && game["state"] == "postgame")
		{
			wait 0.3;
		}
		else
		{
			if(level.perks && rank >= 165)
				wait 0.75;
			else
				wait 1;
		}

		if(self.specialtime > 0)
			self.specialtime--;

		if(self.specialtime <= 0)
		{
			if(self.zom_class == "ice")
				self SetMoveSpeedScale(0.9); //Wat

			self.used_ability = false;
			self setstat(960, 0); //remove special bar
			return;
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


TimeOutSpawn()
{
	self endon("death");
	self endon("disconnect");
	self endon("endtimeout");

	wait self.spawnnoob;

	if(self.spawnnoob > 5)
		self.spawnnoob -= 5;

	self.forcespawn = true; //people were getting around me typing +activate into their console ;)

	self iprintlnbold("^3Autospawned after " + self.spawnnoob + " seconds");
}


DogStop()
{
	name = undefined;

	while(1)
	{
		wait 0.05;

		for(i = 0; i < level.pp.size; i++)
		{
			p = level.pp[i];
      if (!isdefined(p))
        continue;
        
			if(isdefined(level.pp[i].minenum))
				level.pp[i] setstat(989, level.pp[i].minenum + 1);		

			if(isdefined(level.pp[i].repelNum))
				level.pp[i] setstat(975, level.pp[i].repelNum + 1);

			if(isdefined(p.pers) && p.pers["team"] == "axis" && isdefined(p.zom_class) && p.zom_class == "dog")
			{
				if(!p ismantling() && !p isonladder())
					p.firstorigin = p.origin;
			
				behind = p.firstorigin + maps\mp\_utility::vector_scale(anglestoforward(p getplayerangles()), -3);
			
				if(p ismantling())
					p setorigin(behind);
			
				if(p isonladder()) 
				{
					p suicide();
					p iprintlnbold("No ladders for doggy");
				}
			}
		}
	}
}