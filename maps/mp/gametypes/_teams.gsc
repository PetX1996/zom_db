//zom
init()
{
	switch(game["allies"])
	{
	case "marines":
		precacheShader("mpflag_american");
		break;
	}

	precacheShader("mpflag_russian");
	precacheShader("mpflag_spectator");

	level.teambalance = false; //leave this alone mmkay?

	game["strings"]["autobalance"] = &"MP_AUTOBALANCE_NOW";
	precacheString( &"MP_AUTOBALANCE_NOW" );
	precacheString( &"MP_AUTOBALANCE_NEXT_ROUND" );
	precacheString( &"MP_AUTOBALANCE_SECONDS" );

	level.teamBalance = 0;
	level.maxClients = getDvarInt( "sv_maxclients" );
	
	setPlayerModels();

	level.freeplayers = [];

	if( level.teamBased )
	{
		level thread onPlayerConnect();
		level thread updateTeamBalance();
	
		wait .15;
		level thread updatePlayerTimes();
	}
	else
	{
		level thread onFreePlayerConnect();
	
		wait .15;
		level thread updateFreePlayerTimes();
	}
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		
		if(level.zombiesactive) player.mustgozom = 1;
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		
		player thread trackPlayedTime();
	}
}


onFreePlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		if(level.zombiesactive) player.mustgozom = 1;
		player thread trackFreePlayedTime();
	}
}


onJoinedTeam()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_team");
		self logString( "joined team: " + self.pers["team"] );
		self updateTeamTime();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_spectators");
		self.pers["teamTime"] = undefined;
	}
}


trackPlayedTime()
{
	self endon( "disconnect" );

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["free"] = 0;
	self.timePlayed["other"] = 0;
	self.timePlayed["total"] = 0;
	
	while ( level.inPrematchPeriod )
		wait ( 0.05 );

	for ( ;; )
	{
		if ( game["state"] == "playing" )
		{
			if ( self.sessionteam == "allies" )
			{
				self.timePlayed["allies"]++;
				self.timePlayed["total"]++;
			}
			else if ( self.sessionteam == "axis" )
			{
				self.timePlayed["axis"]++;
				self.timePlayed["total"]++;
			}
			else if ( self.sessionteam == "spectator" )
			{
				self.timePlayed["other"]++;
			}
				
		}
		
		wait ( 1.0 );
	}
}


updatePlayerTimes()
{
	nextToUpdate = 0;
	for ( ;; )
	{
		nextToUpdate++;
		if ( nextToUpdate >= level.players.size )
			nextToUpdate = 0;

		if ( isDefined( level.players[nextToUpdate] ) )
			level.players[nextToUpdate] updatePlayedTime();

		wait ( 4.0 );
	}
}




updatePlayedTime()
{
	if ( self.timePlayed["allies"] )
	{
		self maps\mp\gametypes\_persistence::statAdd( "time_played_allies", self.timePlayed["allies"] );
		self maps\mp\gametypes\_persistence::statAdd( "time_played_total", self.timePlayed["allies"] );
	}
	
	if ( self.timePlayed["axis"] )
	{
		self maps\mp\gametypes\_persistence::statAdd( "time_played_opfor", self.timePlayed["axis"] );
		self maps\mp\gametypes\_persistence::statAdd( "time_played_total", self.timePlayed["axis"] );
	}
		
	if ( self.timePlayed["other"] )
	{
		self maps\mp\gametypes\_persistence::statAdd( "time_played_other", self.timePlayed["other"] );			
		self maps\mp\gametypes\_persistence::statAdd( "time_played_total", self.timePlayed["other"] );
	}
	
	if ( game["state"] == "postgame" )
		return;

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["other"] = 0;
}


updateTeamTime()
{
	if ( game["state"] != "playing" )
		return;
		
	self.pers["teamTime"] = getTime();
}


updateTeamBalanceDvar()
{
	for(;;)
	{
		level.teambalance = 0; //lol um

		wait 1;
	}
}


updateTeamBalance()
{
	level.teamLimit = level.maxclients / 2;
	
	level thread updateTeamBalanceDvar();

	wait .15;

	if ( level.teamBalance && (level.roundLimit > 1 || (!level.roundLimit && level.scoreLimit != 1)) )
	{
    	if( isDefined( game["BalanceTeamsNextRound"] ) )
    		iPrintLnbold( &"MP_AUTOBALANCE_NEXT_ROUND" );

		// TODO: add or change
		level waittill( "restarting" );

		if( isDefined( game["BalanceTeamsNextRound"] ) )
		{
			level balanceTeams();
			game["BalanceTeamsNextRound"] = undefined;
		}
		else if( !getTeamBalance() )
		{
			game["BalanceTeamsNextRound"] = true;
		}
	}
	else
	{
		for( ;; )
		{
			if( level.teamBalance )
			{
				if( !getTeamBalance() )
				{
					iPrintLnBold( &"MP_AUTOBALANCE_SECONDS", 15 );
				    wait 15.0;

					if( !getTeamBalance() )
						level balanceTeams();
				}
				
				wait 59.0;
			}
			
			wait 1.0;
		}
	}

}


getTeamBalance()
{
	level.team["allies"] = 0;
	level.team["axis"] = 0;

	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			level.team["allies"]++;
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			level.team["axis"]++;
	}
	
	if((level.team["allies"] > (level.team["axis"] + level.teamBalance)) || (level.team["axis"] > (level.team["allies"] + level.teamBalance)))
		return false;
	else
		return true;
}


balanceTeams()
{
	iPrintLnBold( game["strings"]["autobalance"] );
	//Create/Clear the team arrays
	AlliedPlayers = [];
	AxisPlayers = [];
	
	// Populate the team arrays
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i].pers["teamTime"]))
			continue;
			
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			AlliedPlayers[AlliedPlayers.size] = players[i];
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			AxisPlayers[AxisPlayers.size] = players[i];
	}
	
	MostRecent = undefined;
	
	while((AlliedPlayers.size > (AxisPlayers.size + 1)) || (AxisPlayers.size > (AlliedPlayers.size + 1)))
	{	
		if(AlliedPlayers.size > (AxisPlayers.size + 1))
		{
			// Move the player that's been on the team the shortest ammount of time (highest teamTime value)
			for(j = 0; j < AlliedPlayers.size; j++)
			{
				if(isdefined(AlliedPlayers[j].dont_auto_balance))
					continue;
				
				if(!isdefined(MostRecent))
					MostRecent = AlliedPlayers[j];
				else if(AlliedPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"])
					MostRecent = AlliedPlayers[j];
			}
			
			MostRecent changeTeam("axis");
		}
		else if(AxisPlayers.size > (AlliedPlayers.size + 1))
		{
			// Move the player that's been on the team the shortest ammount of time (highest teamTime value)
			for(j = 0; j < AxisPlayers.size; j++)
			{
				if(isdefined(AxisPlayers[j].dont_auto_balance))
					continue;

				if(!isdefined(MostRecent))
					MostRecent = AxisPlayers[j];
				else if(AxisPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"])
					MostRecent = AxisPlayers[j];
			}

			MostRecent changeTeam("allies");
		}

		MostRecent = undefined;
		AlliedPlayers = [];
		AxisPlayers = [];
		
		players = level.players;
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				AlliedPlayers[AlliedPlayers.size] = players[i];
			else if((isdefined(players[i].pers["team"])) &&(players[i].pers["team"] == "axis"))
				AxisPlayers[AxisPlayers.size] = players[i];
		}
	}
}

changeTeam( team )
{
	if (self.sessionstate != "dead")
	{
		// Set a flag on the player to they aren't robbed points for dying - the callback will remove the flag
		self.switching_teams = true;
		self.joining_team = team;
		self.leaving_team = self.pers["team"];
		
		// Suicide the player so they can't hit escape and fail the team balance
		self suicide();
	}

	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["team"] = team;
	self.team = team;
	self.pers["teamTime"] = undefined;
	self.sessionteam = self.pers["team"];
	self maps\mp\gametypes\_globallogic::updateObjectiveText();
	
	// update spectator permissions immediately on change of team
	self maps\mp\gametypes\_spectating::setSpectatePermissions();
	
	if ( self.pers["team"] == "allies" )
	{
		self setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);
		self openMenu( game[ "menu_changeclass_allies" ] );
	}
	else
	{
		self setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);
		self openMenu( game[ "menu_changeclass_axis" ] );
	}
	
	self notify( "end_respawn" );
}


setPlayerModels()
{
	game["allies_model"] = [];
	game["axis_model"] = [];

	game["allies_soldiertype"] = "desert";
	game["allies"] = "marines";
	game["axis_soldiertype"] = "desert";
	game["axis"] = "arab";

	assert(game["allies"] == "marines");
	assert(game["axis"] == "arab");
	
	game["allies_model"]["SNIPER"] = character\hun_normal::main;
	game["allies_model"]["SUPPORT"] = character\hun_normal::main;
	game["allies_model"]["ASSAULT"] = character\hun_normal::main;
	game["allies_model"]["RECON"] = character\hun_normal::main;
	game["allies_model"]["SPECOPS"] = character\hun_normal::main;
	game["axis_model"]["SNIPER"] = character\hun_normal::main;
	game["axis_model"]["SUPPORT"] = character\hun_normal::main;
	game["axis_model"]["ASSAULT"] = character\hun_normal::main;
	game["axis_model"]["RECON"] = character\hun_normal::main;
	game["axis_model"]["SPECOPS"] = character\hun_normal::main;

}


playerModelForWeapon(weapon) //FLYER
{
}	


CountPlayers()
{
	players = level.players;
	allies = 0;
	axis = 0;
	for(i = 0; i < players.size; i++)
	{
		if ( players[i] == self )
			continue;
			
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			allies++;
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			axis++;
	}
	players["allies"] = allies;
	players["axis"] = axis;
	return players;
}


trackFreePlayedTime()
{
	self endon( "disconnect" );

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["other"] = 0;
	self.timePlayed["total"] = 0;

	for ( ;; )
	{
		if ( game["state"] == "playing" )
		{
			if ( isDefined( self.pers["team"] ) && self.pers["team"] == "allies" && self.sessionteam != "spectator" )
			{
				self.timePlayed["allies"]++;
				self.timePlayed["total"]++;
			}
			else if ( isDefined( self.pers["team"] ) && self.pers["team"] == "axis" && self.sessionteam != "spectator" )
			{
				self.timePlayed["axis"]++;
				self.timePlayed["total"]++;
			}
			else
			{
				self.timePlayed["other"]++;
			}
		}
		
		wait ( 1.0 );
	}
}


updateFreePlayerTimes()
{
	nextToUpdate = 0;
	for ( ;; )
	{
		nextToUpdate++;
		if ( nextToUpdate >= level.players.size )
			nextToUpdate = 0;

		if ( isDefined( level.players[nextToUpdate] ) )
			level.players[nextToUpdate] updateFreePlayedTime();

		wait ( 1.0 );
	}
}


updateFreePlayedTime()
{
	if ( self.timePlayed["allies"] )
	{
		self maps\mp\gametypes\_persistence::statAdd( "time_played_allies", self.timePlayed["allies"] );
		self maps\mp\gametypes\_persistence::statAdd( "time_played_total", self.timePlayed["allies"] );
	}
	
	if ( self.timePlayed["axis"] )
	{
		self maps\mp\gametypes\_persistence::statAdd( "time_played_opfor", self.timePlayed["axis"] );
		self maps\mp\gametypes\_persistence::statAdd( "time_played_total", self.timePlayed["axis"] );
	}
		
	if ( self.timePlayed["other"] )
	{
		self maps\mp\gametypes\_persistence::statAdd( "time_played_other", self.timePlayed["other"] );			
		self maps\mp\gametypes\_persistence::statAdd( "time_played_total", self.timePlayed["other"] );
	}
	
	if ( game["state"] == "postgame" )
		return;

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["other"] = 0;
}


getJoinTeamPermissions( team )
{
	teamcount = 0;
	
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		
		if((isdefined(player.pers["team"])) && (player.pers["team"] == team))
			teamcount++;
	}
	
	if( teamCount < level.teamLimit )
		return true;
	else
		return false;
}
