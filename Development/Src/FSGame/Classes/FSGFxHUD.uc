/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxHUD extends GFxMoviePlayer;

var GFxObject TopLeftHUD;
var GFxObject TopRightHUD;
var GFxObject BottomLeftHUD;
var GFxObject BottomRightHUD;

var float LastHealth;
var float LastHealthMax;
var float LastAmmo;
var float LastAmmoMax;
var float LastResources;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	TopLeftHUD = GetVariableObject("_root.topLeftHUD");
	TopRightHUD = GetVariableObject("_root.topRightHUD");
	BottomLeftHUD = GetVariableObject("_root.bottomLeftHUD");
	BottomRightHUD = GetVariableObject("_root.bottomRightHUD");

	ResizeHUD();
}

function TickHud()
{
	local FSPawn FSP;
	local FSWeapon FSW;

	FSP = GetPlayerPawn();

	if (FSP != None)
	{
		UpdateHealth(FSP.Health, FSP.HealthMax);

		if (FSP.PlayerReplicationInfo != None)
		{
			UpdateResources(FSTeamInfo(FSP.PlayerReplicationInfo.Team).Resources);
		}

		FSW = FSWeapon(FSP.Weapon);
		if (FSW != None)
			UpdateAmmo(FSW.AmmoCount, FSW.AmmoCountMax);
		else
			UpdateAmmo(0, 1);
	}
	else
	{
		UpdateHealth(0, 1);
		UpdateAmmo(0, 1);
	}
}

function FSPawn GetPlayerPawn()
{
	local PlayerController PC;
	local FSPawn FSP;
	local UDKVehicle FSV; //@todo change to FSVehicle
	local UDKWeaponPawn FWP; //@todo change to FSWeaponPawn

	PC = GetPC();
	FSP = FSPawn(GetPC().Pawn);

	// Set the pawn if driving a vehicle or mounted weapon
	if (FSP == None)
	{
		FSV = UDKVehicle(PC.Pawn);

		if (FSV == None)
		{
			FWP = UDKWeaponPawn(PC.Pawn);
			if (FWP != None)
			{
				FSV = FWP.MyVehicle;
				FSP = FSPawn(FWP.Driver);
			}
		}
		else
			FSP = FSPawn(FSV.Driver);

		if (FSV == None)
			return None;
	}

	return FSP;
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function ResizeHUD()
{
	local float Left, Top, Right, Bottom;
	local ASDisplayInfo DI;

	GetVisibleFrameRect(Left, Top, Right, Bottom);

	DI.hasY = true;
	DI.Y = Bottom;
	BottomLeftHUD.SetDisplayInfo(DI);
	BottomRightHUD.SetDisplayInfo(DI);
	DI.hasY = false;

	DI.hasX = true;
	DI.X = Right;
	TopRightHUD.SetDisplayInfo(DI);
	BottomRightHUD.SetDisplayInfo(DI);
}

/*********************************************************************************************
 Functions calling ActionScript
**********************************************************************************************/

function UpdateHealth(int Health, int HealthMax)
{
	if (Health != LastHealth || HealthMax != LastHealthMax)
	{
		ActionScriptVoid("_root.UpdateHealth");
		LastHealth = Health;
		LastHealthMax = HealthMax;
	}
}

function UpdateAmmo(int Ammo, int AmmoMax)
{
	if (Ammo != LastAmmo || AmmoMax != LastAmmoMax)
	{
		ActionScriptVoid("_root.UpdateAmmo");
		LastAmmo = Ammo;
		LastAmmoMax = AmmoMax; 
	}
}

function UpdateResources(int Resources)
{
	if (Resources != LastResources)
	{
		ActionScriptVoid("_root.UpdateResources");
		LastResources = Resources;
	}
}

function UpdateIsAlive(bool IsAlive)
{
	ActionScriptVoid("_root.UpdateIsAlive");
}

function UpdateCommStatus(string CommName, int Health, int HealthMax)
{
	ActionScriptVoid("_root.UpdateCommStatus");
}

function UpdateCurrentResearch(string ResearchName, int SecsLeft)
{
	ActionScriptVoid("_root.UpdateCurrentResearch");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_hud'
	bDisplayWithHudOff=false
	bAutoPlay=true
	LastHealth=-110
	LastHealthMax=-110
	LastAmmo=-110
	LastAmmoMax=-110
	LastResources=-110
}
