/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPlayerReplicationInfo extends PlayerReplicationInfo;

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'Team')
		FSHUD(GetALocalPlayerController().myHUD).GFxOmniMenu.Invalidate("team");

	Super.ReplicatedEvent(VarName);
}

defaultproperties
{
}
