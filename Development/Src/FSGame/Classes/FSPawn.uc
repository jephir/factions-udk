/**
 * Pawn class for the player.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPawn extends GamePawn
	Implements(FSActorInterface);

const MinimapCaptureRotation=Rot(-16384,-16384,0); // Camera needs to be rotated to make up point north.

var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCapturePosition;

var float CommanderCamZoom;
var float CommanderCamZoomTick;
var float CommanderComZoomMax;
var float CommanderComZoomMin;
var bool bInCommanderView;
var bool bCommanderRotation; 

const MinimapCaptureFOV=90; // This must be 90 degrees otherwise the minimap overlays will be incorrect.

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

/**
 * @extends
 */
simulated function PostBeginPlay()
{
	local FSMapInfo MI;

	Super.PostBeginPlay();

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
function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// Update the capture component's position
	MinimapCaptureComponent.SetView(MinimapCapturePosition, MinimapCaptureRotation);
}

/**
 * Override to calculate the camera.
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

defaultproperties
{
	Components.Remove(Sprite);

	begin object Class=SkeletalMeshComponent Name=FSSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'FSAssets.Mesh.IronGuard'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	end object
	Mesh=FSSkeletalMeshComponent
	Components.Add(FSSkeletalMeshComponent)
	
	CommanderCamZoom=384.0
	CommanderCamZoomTick=18.0
	bInCommanderView=false
	bCommanderRotation=false
}