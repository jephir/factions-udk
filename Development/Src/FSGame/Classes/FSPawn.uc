/**
 * Pawn class for the player.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPawn extends UDKPawn
	Implements(FSActorInterface)
	config(GameFS)
	notplaceable;

const MinimapCaptureFOV=90; // This must be 90 degrees otherwise the minimap overlays will be incorrect.

var DynamicLightEnvironmentComponent LightEnvironment;

// Weapon
var repnotify class<FSWeaponAttachment> CurrentWeaponAttachmentClass;
var FSWeaponAttachment CurrentWeaponAttachment;
var name WeaponSocket;
var bool bWeaponAttachmentVisible;

// Minimap
var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCapturePosition;
var Rotator MinimapCaptureRotation;

// Commander
var float CommanderCamZoom;
var float CommanderCamZoomTick;
var float CommanderComZoomMax;
var float CommanderComZoomMin;
var bool bInCommanderView;
var bool bCommanderRotation;

replication
{
	if (bNetDirty)
		CurrentWeaponAttachmentClass;
}

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	local FSMapInfo MI;

	super.PostBeginPlay();

	MI = FSMapInfo(WorldInfo.GetMapInfo());
	if (MI != none)
	{
		// Initialize the minimap capture component
		MinimapCaptureComponent = new class'SceneCapture2DComponent';
		MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'FSAssets.HUD.minimap_render_texture', MinimapCaptureFOV, , 0);
		MinimapCaptureComponent.bUpdateMatrices = false;
		AttachComponent(MinimapCaptureComponent);

		MinimapCapturePosition.X = MI.MapCenter.X;
		MinimapCapturePosition.Y = MI.MapCenter.Y;
		MinimapCapturePosition.Z = MI.MapRadius;
	}
}
/**
 * @extends
 */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// Only refresh anim nodes if our main mesh was updated
	if (SkelComp == Mesh)
	{
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
	}
}

/**
 * @extends
 */
simulated event Destroyed()
{
	super.Destroyed();

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(Mesh);
		CurrentWeaponAttachment.Destroy();
	}
}


/**
 * @extends
 */
simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	// Update the capture component's position
	MinimapCaptureComponent.SetView(MinimapCapturePosition, MinimapCaptureRotation);
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	super.ReplicatedEvent(VarName);

	if (VarName == 'CurrentWeaponAttachmentClass')
		WeaponAttachmentChanged();
	else if (VarName == 'bPuttingDownWeapon')
		SetPuttingDownWeapon(bPuttingDownWeapon);
}

/**
 * Override.
 * 
 * @extends
 */
simulated singular event Rotator GetBaseAimRotation()
{
   local vector   POVLoc;
   local rotator   POVRot, tempRot;
   
   if ( bInCommanderView )
   {
	   tempRot = Rotation;
	   tempRot.Pitch = 0;
	   SetRotation(tempRot);
	   POVRot = Rotation;
	   POVRot.Pitch = 0;    
	}
	else
   {
	  if( Controller != None && !InFreeCam() )
	  {
		 Controller.GetPlayerViewPoint(POVLoc, POVRot);
		 return POVRot;
	  }
	  else
	  {
		 POVRot = Rotation;
		 
		 if( POVRot.Pitch == 0 )
		 {
			POVRot.Pitch = RemoteViewPitch << 8;
		 }
	  }
   }

	return POVRot;
}

/**
 * Override.
 * 
 * @extends
 */
simulated function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	if (bInCommanderView)
	{
		out_CamLoc = Location;
		out_CamLoc.Z += CommanderCamZoom;

	   if(bCommanderRotation)
	   {
		  out_CamRot.Pitch = -16384;
		  out_CamRot.Yaw = Rotation.Yaw;
		  out_CamRot.Roll = Rotation.Roll;
	   }
	   else
	   {
		  out_CamRot.Pitch = -16384;
		  out_CamRot.Yaw = 0;
		  out_CamRot.Roll = 0;
	   }

	   return true;
	}
	else
	{
		// Set the camera to the player's eyes
		Mesh.GetSocketWorldLocationAndRotation('Eyes', out_CamLoc);
		out_CamRot = GetViewRotation();
		return true;
	}
}

/**
 * @extends
 */
simulated function NotifyTeamChanged()
{
	super.NotifyTeamChanged();
	if (CurrentWeaponAttachmentClass != None)
	{
		if (WorldInfo.NetMode != NM_DedicatedServer && CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
			CurrentWeaponAttachment = None;
		}
		WeaponAttachmentChanged();
	}
}

/**
 * @extends
 */
simulated function PlayDying(class<DamageType> DamageType, Vector HitLoc)
{
	super.PlayDying(DamageType, HitLoc);

	CurrentWeaponAttachmentClass = None;
	WeaponAttachmentChanged();
}

/**
 * @extends
 */
simulated function FiringModeUpdated(Weapon InWeapon, byte InFiringMode, bool bViaReplication)
{
	super.FiringModeUpdated(InWeapon, InFiringMode, bViaReplication);
	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.FireModeUpdated(InFiringMode, bViaReplication);
	}
}

/**
 * @extends
 */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	super.WeaponFired(InWeapon, bViaReplication, HitLocation);

	if (CurrentWeaponAttachment != None)
	{
		if (!IsFirstPerson())
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
		else
		{
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
	        if (class'Engine'.static.IsSplitScreen() && CurrentWeaponAttachment.EffectIsRelevant(CurrentWeaponAttachment.Location, false, CurrentWeaponAttachment.MaxFireEffectDistance))
		        CurrentWeaponAttachment.CauseMuzzleFlash();
		}
	}
}

/**
 * @extends
 */
simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	super.WeaponFired(InWeapon, bViaReplication);

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
	}
}

/**
 * Called when the weapon attachment needs to be changed.
 */
simulated function WeaponAttachmentChanged()
{
	if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass) && Mesh.SkeletalMesh != None)
	{
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
		}

		if (CurrentWeaponAttachmentClass != None)
		{
			CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass, self);
			CurrentWeaponAttachment.Instigator = self;
		}
		else
			CurrentWeaponAttachment = None;

		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.AttachTo(self);
			CurrentWeaponAttachment.ChangeVisibility(bWeaponAttachmentVisible);
		}
	}
}

/**
 * Called when weapon is being put down.
 */
simulated function SetPuttingDownWeapon(bool bNowPuttingDownWeapon)
{
	if (bPuttingDownWeapon != bNowPuttingDownWeapon || Role < ROLE_Authority)
	{
		bPuttingDownWeapon = bNowPuttingDownWeapon;
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.SetPuttingDownWeapon(bPuttingDownWeapon);
		}
	}
}

simulated function ChangeClass()
{
}

exec function ToggleCommanderView()
{
	bInCommanderView = !bInCommanderView;
}

exec function ComZoomIn()
{
	CommanderCamZoom += CommanderCamZoomTick;
}

exec function ComZoomOut()
{
	CommanderCamZoom -= CommanderCamZoomTick;
}

exec function ComRotate()
{
	bCommanderRotation = !bCommanderRotation;
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=WSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'FSAssets.Mesh.IronGuard'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	End Object
	Mesh=WSkeletalMeshComponent
	Components.Add(WSkeletalMeshComponent)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	BaseTranslationOffset=6.0

	MinimapCaptureRotation=(Pitch=-16384,Yaw=-16384,Roll=0) // Camera needs to be rotated to make up point north.
	
	CommanderCamZoom=384.0
	CommanderCamZoomTick=18.0
	bInCommanderView=false
	bCommanderRotation=false

	bWeaponAttachmentVisible=true

	WeaponSocket=WeaponPoint

	bCanPickupInventory=true

	InventoryManagerClass=class'FSGame.FSInventoryManager'
}