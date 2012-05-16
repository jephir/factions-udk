/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStructure extends Actor
	placeable
	abstract;

var() byte TeamNumber;
var() int Health;
var() int HealthMax;

/**
 * Returns the class for the given structure index.
 */
static function class<FSStructure> GetClass(byte StructureIndex)
{
	switch (StructureIndex)
	{
	case 1:
		return class'FSStruct_Barracks';
	case 2:
		return class'FSStruct_VehicleFactory';
	default:
		return None;
	}
}

//TODO: Change these classes with something semitransparent or w/e
static function class<FSStructurePreview> GetPreviewClass(class<FSStructure> StructureClass)
{
	switch (StructureClass)
	{
	case class'FSStruct_Barracks':
		return class'FSStructurePreview'; 
	case class'FSStruct_VehicleFactory':
		return class'FSStructurePreview';
	default:
		return None;
	}
}

simulated event byte ScriptGetTeamNum()
{
	return TeamNumber;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	Health -= DamageAmount;
	if (Health <= 0)
		Destroy();
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=StructureLightEnvironmentComponent
	End Object
	Components.Add(StructureLightEnvironmentComponent)

	Begin Object Class=StaticMeshComponent Name=StructureMeshComponent
		LightEnvironment=StructureLightEnvironmentComponent
	End Object
	Components.Add(StructureMeshComponent)

	CollisionType=COLLIDE_BlockAll
	BlockRigidBody=True
	bCollideActors=True
	bBlockActors=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2.0
	bAlwaysRelevant=True
	bReplicateMovement=False
	bOnlyDirtyReplication=True

	TeamNumber=0
	Health=1000
	HealthMax=1000
}
