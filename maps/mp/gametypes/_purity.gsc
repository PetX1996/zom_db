#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	wait 10;
	origiwds = getDvar("sv_referencedIwdNames");
	iwds = StrTok(origiwds, " ");
	fs_game = getDvar("fs_game");
	stock = false;

	if(tolower(fs_game) == "mods/zom_db")
		stock = true;

	hasinvalidiwds = false;
	invalidiwds = [];

	for(i = 0; i < iwds.size; i++)
	{
		if(!IsSubStr(iwds[i], fs_game)) //if the iwd isn't in the modfolder, skip it
			continue;

		if(iwds[i] != fs_game + "/z_zomdb_ext") //if it is in the modfolder and has a different name
		{
			hasinvalidiwds = true;
			invalidiwds[invalidiwds.size] = iwds[i];
		}
	}


	mapiwds = false;

	if(hasinvalidiwds) 
		for(t = 0; t < invalidiwds.size; t++)

	if(getsubstr(invalidiwds[t], fs_game.size + 1, fs_game.size + 4) == "mp_") //if any iwds are named mp_*
		mapiwds = true;

	sums = StrTok(getDvar("sv_referencedIwds"), " ");

	rightiwd = false;

	for(p = 0; p < sums.size; p++) if(sums[p] == "1114398691")
		rightiwd = true; 
		//the checksum/hash of the right iwd, as in sv_referencedIwds

	//print a warning, change the hostname to show the warning, then wait and exit the map

	if(!rightiwd && stock)
		Quitmap("IMPURE Z_ZOMDB_EXT.IWD");

	if(stock && hasinvalidiwds)
		Quitmap("IMPURE MODFOLDER");

	else if(!stock && mapiwds)
		Quitmap("MAP IWDS IN THE MODFOLDER");
}

Quitmap(reason)
{
	iprintlnbold(reason);
	setdvar("sv_hostname", getdvar("sv_hostname") + " " + reason);

	wait 20;
	exitlevel(false);
}