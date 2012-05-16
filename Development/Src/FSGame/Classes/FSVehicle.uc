/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle extends UDKVehicle
	placeable
	abstract;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.WakeRigidBody();
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Name=SVehicleMesh
		LightEnvironment=LightEnvironment0
	End Object

	DestroyOnPenetrationThreshold=50.0
	DestroyOnPenetrationDuration=1.0
}
