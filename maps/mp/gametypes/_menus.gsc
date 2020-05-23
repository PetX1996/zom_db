init()
{
	game["menu_team"] = "team_marinesopfor";
	game["menu_class_allies"] = "class_marines";
	game["menu_changeclass_allies"] = "changeclass_marines_mw";
	game["menu_class_axis"] = "class_opfor";
	game["menu_changeclass_axis"] = "changeclass_opfor_mw";
	game["menu_class"] = "class";
	game["menu_changeclass"] = "changeclass_mw";
	game["menu_changeclass_offline"] = "changeclass_offline";

	game["menu_callvote"] = "callvote";
	game["menu_muteplayer"] = "muteplayer";
	precacheMenu(game["menu_callvote"]);
	precacheMenu(game["menu_muteplayer"]);
	
	game["menu_eog_unlock"] = "popup_unlock";
	game["menu_eog_summary"] = "popup_summary";
	game["menu_eog_unlock_page1"] = "popup_unlock_page1";
	game["menu_eog_unlock_page2"] = "popup_unlock_page2";
	
	precacheMenu(game["menu_eog_unlock"]);
	precacheMenu(game["menu_eog_summary"]);
	precacheMenu(game["menu_eog_unlock_page1"]);
	precacheMenu(game["menu_eog_unlock_page2"]);

	precacheMenu("zom_help");
	precacheMenu("zom_settings");
	precacheMenu("scoreboard");
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_class_allies"]);
	precacheMenu(game["menu_changeclass_allies"]);
	precacheMenu(game["menu_class_axis"]);
	precacheMenu(game["menu_changeclass_axis"]);
	precacheMenu(game["menu_class"]);
	precacheMenu(game["menu_changeclass"]);
	precacheMenu(game["menu_changeclass_offline"]);
	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_HOST_ENDGAME_RESPONSE" );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		
		player setClientDvar("ui_3dwaypointtext", "1");
		player.enable3DWaypoints = true;
		player setClientDvar("ui_deathicontext", "1");
		player.enableDeathIcons = true;
		player.classType = undefined;
		player.selectedClass = false;
		player.usedhundred = false;
		player.usedhundredtwo = false;
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if(response == "rotation_next" && self.rc < self.rcmax - 6)
		{
			self.rc++;
			continue;
		}
		if(response == "rotation_previous" && self.rc > 0)
		{
			self.rc--;
			continue;
		}

		if(response == "updatesettings") //triggered on opening zom_settings.menu
		{
			self setClientDvar("cl_zom_hunskull", getdvar("scr_hunskull"));
			self setClientDvar("cl_zom_falldamage", getdvar("scr_falldamage"));
			self setClientDvar("cl_zom_gravity", getdvar("scr_gravity"));
			self setClientDvar("cl_zom_perks", getdvar("scr_perks"));
			self setClientDvar("cl_zom_movemines", getdvar("scr_movemines"));
			self setClientDvar("cl_zom_minestokiller", getdvar("scr_minestokiller"));
			self setClientDvar("cl_zom_unlimitedammo", getdvar("scr_unlimitedammo"));
			self setClientDvar("cl_zom_zammotime", getdvar("scr_zammotime"));
			self setClientDvar("cl_zom_drops", getdvar("scr_drops"));
			self setClientDvar("cl_zom_autospawn", getdvar("scr_autospawn"));
			self setClientDvar("cl_zom_arq", getdvar("scr_arq"));
			self setClientDvar("cl_zom_spawnprotect", getdvar("scr_zomspawnprotection"));
			self setClientDvar("cl_zom_spectatetype", getdvar("scr_allowspectate"));

			self.rc = level.rccurrent;

			if(level.rccurrent > (self.rcmax - 6))
				self.rc = self.rcmax - 6;

			continue;
		}

		if(response == "updatehelp") //triggered op opening zom_help.menu
		{
			if(getDvarInt("scr_specialclass"))
			{
				self setClientDvar("cl_helpmenu_specialclass1",
					getDvar("scr_specialclass_name")
					+ ", ^2" + getDvar("scr_specialclass_health")
					+ ", ^3" + getDvar("scr_specialclass_speed"));

				self setClientDvar("cl_helpmenu_specialclass2",
					", ^5" + getDvar("scr_specialclass_damage"));


				str = "^2";
				
				spec = []; spec[0] = "scr_specialclass_special1"; spec[1] = "scr_specialclass_special2";

				for(i = 0; i < spec.size; i++)
				{
					switch(getDvar(spec[i]))
					{
						case "hj": str += "High Jump"; break;
						case "zc": str += "Zombie Call"; break;
						case "zf": str += "Zombie Fart"; break;
						case "zs": str += "Scare"; break;
						case "ls": str += "Lightning Strike"; break;
						case "sb": str += "Sonic Boom"; break;
						case "ib": str += "Ice Blast"; break;
						case "am": str += "Avoid Mines"; break;
						case "ch": str += "Confuse Hunters"; break;
					}

					str += "\n^3";
				}

				self setClientDvar("cl_helpmenu_specialname", getDvar("scr_specialclass_name") + ":");
				self setClientDvar("cl_helpmenu_specialabils", str);
			}
			else
			{
				self setClientDvar("cl_helpmenu_specialclass1", "No special class is defined...\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1\n^1");
				//those /n's are a very hacky way to make sure the % sign is hidden off screen lol

				self setClientDvar("cl_helpmenu_specialclass2", "");
				self setClientDvar("cl_helpmenu_specialname", "");
				self setClientDvar("cl_helpmenu_specialabils", "No special class is defined...");
			}
		}

		if(response == "openqm") //no QM's for zombies, so put this in a response
		{
			self CloseMenu();
			self CloseInGameMenu();

			if(self.pers["team"] == "allies")
				self OpenMenu("orig_quickmessage");
		}

		if(response == "suicideconfirm")
		{
			if(self.pers["team"] == "allies")
			{
				self closemenu();
				self openmenu("suicideconfirm");
			}
			else if(!isdefined(self.suiciding))							    
			{
				self.suiciding = "lul";

				self PlayLocalSound("zom_class_change");

				self iprintln("^2Suicide timer...2");
				wait 1;

				self iprintln("^2Suicide timer...1");
				wait 1;				

				if(self.health > 0)
					self suicide();

				self.suiciding = undefined; //temp var to stop them trying to suicide twice
			}
		}

		if(response == "rankability")
		{
			self PlayLocalSound("zom_class_change");
			rank = self maps\mp\gametypes\_rank::getrank();

			if(rank >= 99 && level.perks && !self.usedhundred && self.health > 0)
			{
				self.usedhundred = true;

				if(self.pers["team"] == "allies")
					self thread Clone();
		
				else if(self.pers["team"] == "axis")
					self thread Disguise();
			}
		}

		if(response == "rankability2")
		{
			self PlayLocalSound("zom_class_change");
			rank = self maps\mp\gametypes\_rank::getrank();

			if(rank >= 199 && level.perks && !self.usedhundredtwo && self.health > 0)
			{
				self.usedhundredtwo = true;

				if(self.pers["team"] == "allies")
					self thread Teleport();

				if(self.pers["team"] == "axis")
					self thread Freezehunters();
			}
		}

		if(response == "suicidenow")
		{
			if(self.health > 0 && self.pers["team"] == "allies")
				self suicide();

			self PlayLocalSound("zom_class_change");
		}

		if(response == "click")
			self PlayLocalSound("zom_class_change");


		if(game["state"] != "postgame")
		{
			if(response == "thirdperson")
			{
				self PlayLocalSound("zom_class_change");

				if(self.thirdperson)
				{
					self.third_elem.alpha = 0;
					self setclientdvar("cg_thirdperson",0);
					self.thirdperson = false;
				}
				else if(!self.thirdperson)
				{
					self.third_elem.alpha = 1; //crosshair
					self setclientdvar("cg_thirdperson",1);
					self.thirdperson = true;
				}
			}

			if(response == "hardcore")
			{
				self PlayLocalSound("zom_class_change");
				if(self.hardcore)
				{
					self setclientdvar("ui_hud_hardcore",1);
					self.hardcore = false;
				}
				else if(!self.hardcore)
				{
					self setclientdvar("ui_hud_hardcore",0);
					self.hardcore = true;
				}
			}

			if(response == "laser")
			{
				self PlayLocalSound("zom_class_change");
	
				if(self.laser)
				{
					self setclientdvar("cg_laserforceon", 0);
					self.laser = false;
				}
				else if(!self.laser)
				{
					if(self.pers["team"] == "allies")
					{
						self setclientdvar("cg_laserforceon", 1);
						self.laser = true;
					}
				}
			}
		}

		if(response == "ghillie")
		{
			self PlayLocalSound("zom_class_change");

			if(self.ghillie)
			{
				self detachall();
				self setmodel("");
				self character\hun_normal::main();
				self.ghillie = false;
			}
			else
			{
				if(self.pers["team"] == "allies")
				{
					self detachall();
					self setmodel("");
					self character\hun_ghillie::main();
					self.ghillie = true;
				}
			}
		}

		if ( response == "back" )
		{
			self closeMenu();
			self closeInGameMenu();
			if ( menu == "changeclass" && self.pers["team"] == "allies" )
				self openMenu( game["menu_changeclass_allies"] );

			else if ( menu == "changeclass" && self.pers["team"] == "axis" )
				self openMenu( game["menu_changeclass_axis"] );	
		
			continue;
		}
		
		if( getSubStr( response, 0, 7 ) == "loadout" )
		{
			self maps\mp\gametypes\_modwarfare::processLoadoutResponse( response );
			continue;
		}
		
		if( response == "changeteam" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_team"]);
		}
	
		if( response == "changeclass_marines" )
		{
			self closeMenu();
			self closeInGameMenu();

			if(!level.zombiesactive)
				self openMenu( game["menu_changeclass_allies"] );

			continue;
		}
		
		if( response == "endgame" )
		{
			continue;
		}

		if( menu == game["menu_team"] )
		{
			switch(response)
			{
			case "autoassign":
				self [[level.autoassign]]();
				break;

			case "spectator":
				self [[level.spectator]]();
				break;
			}
		}
		else if(menu == game["menu_changeclass_allies"] || menu == game["menu_changeclass_axis"])
		{
			if(!self maps\mp\gametypes\_modwarfare::verifyClassChoice(self.pers["team"], response))
				continue;

			if(!level.zombiesactive)
				self maps\mp\gametypes\_modwarfare::setClassChoice(response);

			self closeMenu();
			self closeInGameMenu();

			if(!level.zombiesactive)
				self openMenu( game["menu_changeclass"] );

			if(level.zombiesactive)
			{
				self.selectedClass = true;
				self maps\mp\gametypes\_modwarfare::menuAcceptClass();
			}
			continue;
		}
		else if( menu == game["menu_changeclass"] )
		{
			self closeMenu();
			self closeInGameMenu();

			self.selectedClass = true;
			self maps\mp\gametypes\_modwarfare::menuAcceptClass();
		}
		else if ( !level.console && self.pers["team"] == "allies")
		{
			if(menu == game["menu_quickcommands"])
				maps\mp\gametypes\_quickmessages::quickcommands(response);

			else if(menu == game["menu_quickstatements"])
				maps\mp\gametypes\_quickmessages::quickstatements(response);

			else if(menu == game["menu_quickresponses"])
				maps\mp\gametypes\_quickmessages::quickresponses(response);
		}
	}
}


Freezehunters()
{
	self endon("disconnect");

	playfx(level.zom_freezefx, self.origin + (0, 0, 30));
	hit = false;

	for(i = 0; i < level.pp.size; i++)
	{
		p = level.pp[i];
		if(p.pers["team"] == "allies"
		 && p.health > 0
		 && isdefined(distance(p.origin, self.origin))
		 && distance(self.origin, p.origin) <= 250
		 && maps\mp\gametypes\_zom_class::IsInViewNoEnts(self,p))
		{
			p iprintlnbold(self.name + "^1 froze you");
			self iprintln("^1You froze " + p.name);
			p setmovespeedscale(0);
			p allowjump(false);
			p.frozen = true;
			p thread unfreeze();
			hit = true;
		}
	}

	wait 2;

	if(!hit)
	{
		self.usedhundredtwo = false;
		self iprintlnbold("^2Your freeze didn't hit anyone, so you got it back");
	}
}


unfreeze()
{
	self endon("death");
	self endon("disconnect");
	self notify("end unfreeze");
	self endon("end unfreeze");

	wait 2;

	self setmovespeedscale(1);
	self.frozen = undefined;
	self allowjump(true);

	rank = self maps\mp\gametypes\_rank::getrank();
	
	if(rank >= 32 && level.perks)
		self setMoveSpeedScale(1.1);

	self iprintln("^2You unfroze");
}


Teleport()
{
	self endon("death");
	self endon("disconnect");

	object2 = spawn("script_model", self.origin);
	object = spawn("script_model", self.origin);
	wait 0.55;

	object playsound("zom_teleport");
	object2 playsound("zom_teleport");

	wait 0.45;

	playfx(level.zom_teleportfx, self.origin + (0, 0, 50));

	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints("allies");
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnPoints);

	self setorigin(spawnpoint.origin);
	self setplayerangles(spawnpoints.angles);

	wait 3;
	object delete();
	object2 delete();
}


Clone()
{
	self iprintlnbold("^2You placed some decoys");

	decoy = self cloneplayer(10);
	decoy2 = self cloneplayer(10);

	infront = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self getplayerangles()), 50);

	playfx(level.zom_minefx, infront);

	decoy.origin = infront + (20, 0, 0);
	decoy2.origin = infront + (-20, 0, 0);

	decoy thread shimmer();
	decoy2 thread shimmer();

	wait 10;

	decoy delete();
	decoy2 delete();
}

shimmer()
{
	while(isdefined(self))
	{
		wait (0.5 + randomfloat(3));
		self hide();
		wait 0.01;
		self show();
	}
}


Disguise()
{
	self endon("death");
	self endon("disconnect");
	
	if(self.zom_class == "dog")
	{
		self.usedhundred = false;
		self iprintln("^1You can't use this ability as a dog");
		wait 0.5;
		return;
	}
	
	self detachall();
	self setmodel("");

	self.disguised = true;

	self setclientdvar("cg_drawgun", 0);
	self iprintln("^1You are disguised for 10 seconds");
	self character\hun_ghillie::main();
	self thread nog();

	wait 10;

	self detachall();
	self setmodel("");

	//urgh, need a func like setzomodel(); in _glogic for this...

	if(self.zom_class == "poison"
	 || self.zom_class == "normal"
	 || self.zom_class == "fast")
		self character\zom_normal::main();

	else if(self.zom_class == "electric")
		self character\zom_electric::main();

	else if(self.zom_class == "ice")
		self character\zom_ice::main();

	else if(self.zom_class == "special")
		self maps\mp\gametypes\_zom_class::SetSpecialModel();

	//like, now

	self iprintln("^1Disguise ended");
	self PlayLocalSound("zom_class_change");

	self.disguised = false;
}


nog()
{
	self endon("disconnect");

	for(i = 0; i < 20; i++)
	{
		wait 0.5;

		if(self.health < 1)
		{
			self setclientdvar("cg_drawgun", 1);
			return;
		}
	}
}