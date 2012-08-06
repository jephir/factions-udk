/**
 * Holds ammo to be used in a weapon.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMagazine extends Inventory;

// Archetype of the weapon this magazine provides ammo for
var FWeapon AmmoFor;

var int AmmoCount;
var(Magazine) int MaxAmmoCount;

replication
{
	if (bNetDirty)
		AmmoFor, AmmoCount, MaxAmmoCount;
}

/**
 * @extends
 */
event PostBeginPlay()
{
	Super.PostBeginPlay();

	AmmoCount = MaxAmmoCount;
}

/**
 * Adds ammo to the magazine.
 * 
 * Amount can be negative to subtract ammo.
 */
function int AddAmmo(int Amount)
{
	AmmoCount = Clamp(AmmoCount + Amount, 0, MaxAmmoCount);

	return AmmoCount;
}

defaultproperties
{
	AmmoCount=30
	MaxAmmoCount=30
}
