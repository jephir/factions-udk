/**
 * Base weapon class.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeapon extends UDKWeapon
	dependson(FSPlayerController)
	config(WeaponFS)
	abstract;

var class<FSWeaponAttachment> AttachmentClass;

var repnotify int AmmoCountMax;

/**
 * @extends
 */
function ConsumeAmmo(byte FireModeNum)
{
	super.ConsumeAmmo(FireModeNum);

	AddAmmo(-1);
}

/**
 * @extends
 */
function int AddAmmo(int Amount)
{
	super.AddAmmo(Amount);

	AmmoCount = Clamp(AmmoCount + Amount, 0, AmmoCountMax);

	return AmmoCount;
}

/**
 * @extends
 */
simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	super.HasAmmo(FireModeNum, Amount);

	if (Amount == 0)
		return (AmmoCount >= 1);
	else
		return (AmmoCount >= Amount);
}

/**
 * @extends
 */
simulated function bool HasAnyAmmo()
{
	return AmmoCount > 0;
}

/**
 * @extends
 */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	local FSPawn FSP;

	super.AttachWeaponTo(MeshCpnt, SocketName);

	FSP = FSPawn(Instigator);

	if (Role == ROLE_Authority && FSP != None)
	{
		FSP.CurrentWeaponAttachmentClass = AttachmentClass;
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			FSP.WeaponAttachmentChanged();
		}
	}
}

/**
 * @extends
 */
simulated function DetachWeapon()
{
	local FSPawn FSP;

	super.DetachWeapon();

	FSP = FSPawn(Instigator);
	if (FSP != None)
	{
		if (Role == ROLE_Authority && FSP.CurrentWeaponAttachmentClass == AttachmentClass)
		{
			FSP.CurrentWeaponAttachmentClass = None;
			if (Instigator.IsLocallyControlled())
			{
				FSP.WeaponAttachmentChanged();
			}
		}
	}

	SetBase(None);
}

/**
 * @extends
 */
simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	super.TimeWeaponEquipping();
}

defaultproperties
{
	Begin Object Class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object

	AmmoCount=30
	AmmoCountMax=30
}
