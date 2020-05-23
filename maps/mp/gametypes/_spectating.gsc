init()
{
	level.spectateOverride["allies"] = spawnstruct();
	level.spectateOverride["axis"] = spawnstruct();

	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerSpawned();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self setSpectatePermissions();
	}
}


onJoinedTeam()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_team");
		self setSpectatePermissions();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_spectators");
		self setSpectatePermissions();
	}
}


updateSpectateSettings()
{
	level endon("game_ended");
	
	for(i = 0; i < level.players.size; i++)
		level.players[i] setSpectatePermissions();
}


getOtherTeam( team )
{
	if(team == "axis")
		return "allies";

	else if( team == "allies")
		return "axis";

	else return "none";
}



setSpectatePermissions()
{
	team = self.sessionteam;

	type = getdvarint("scr_allowspectate");
	movetype = getdvarint("scr_allowspectatemove");

	if(type == 0)
	{
		//no spectating
		self allowSpectateTeam("allies", false);
		self allowSpectateTeam("axis", false);
	}
	else if(type == 1)
	{
		//spectate only zombies
		self allowSpectateTeam("allies", false);
		self allowSpectateTeam("axis", true);
	}
	else if(type == 2)
	{
		//spectate only hunters
		self allowSpectateTeam("allies", true);
		self allowSpectateTeam("axis", false);
	}
	else if(type == 3)
	{
		//spectate both teams
		self allowSpectateTeam("allies", true);
		self allowSpectateTeam("axis", true);
	}

	if(movetype == 0)
	{
		//allow no movement
		self allowSpectateTeam("freelook", false);
		self allowSpectateTeam("none", false);
	}
	else if(movetype == 1)
	{
		//allow all movement
		self allowSpectateTeam("freelook", true);
		self allowSpectateTeam("none", true);
	}
}