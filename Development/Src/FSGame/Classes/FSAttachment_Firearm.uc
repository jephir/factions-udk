/**
 * Attachment for firearm weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSAttachment_Firearm extends FSWeaponAttachment;

var ParticleSystem BeamTemplate;

var int CurrentPath;

simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
	local ParticleSystemComponent E;
	local Actor HitActor;
	local Vector HitNormal, HitLocation;

	if (End == Vect(0,0,0))
	{
		if (!bFirstPerson || (Instigator.Controller == None))
	    	return;

		End = Start + Vector(Instigator.Controller.Rotation) * class'UTWeap_ShockRifle'.default.WeaponRange;
		HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, true, vect(0,0,0), , TRACEFLAG_Bullet);
		if (HitActor != None)
			End = HitLocation;
	}

	E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
	E.SetVectorParameter('ShockBeamEnd', End);
	if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
		E.SetDepthPriorityGroup(SDPG_Foreground);
	else
		E.SetDepthPriorityGroup(SDPG_World);
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
	local Vector EffectLocation;

	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	if (Instigator.FiringMode == 0 || Instigator.FiringMode == 3)
	{
		EffectLocation = GetEffectLocation();
		SpawnBeam(EffectLocation, HitLocation, true);
	}
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);

	if ((Instigator.FiringMode == 0 || Instigator.FiringMode == 3))
	{
		SpawnBeam(GetEffectLocation(), HitLocation, false);
	}
}

simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	local float PathValues[3];
	local int NewPath;
	Super.SetMuzzleFlashparams(PSC);
	if (Instigator.FiringMode == 0)
	{
		NewPath = Rand(3);
		if (NewPath == CurrentPath)
		{
			NewPath++;
		}
		CurrentPath = NewPath % 3;

		PathValues[CurrentPath % 3] = 1.0;
		PSC.SetFloatParameter('Path1',PathValues[0]);
		PSC.SetFloatParameter('Path2',PathValues[1]);
		PSC.SetFloatParameter('Path3',PathValues[2]);
//			CurrentPath++;
	}
	else if (Instigator.FiringMode == 3)
	{
		PSC.SetFloatParameter('Path1',1.0);
		PSC.SetFloatParameter('Path2',1.0);
		PSC.SetFloatParameter('Path3',1.0);
	}
	else
	{
		PSC.SetFloatParameter('Path1',0.0);
		PSC.SetFloatParameter('Path2',0.0);
		PSC.SetFloatParameter('Path3',0.0);
	}
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
	End Object

	BeamTemplate=particlesystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam'
	
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33;
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
}