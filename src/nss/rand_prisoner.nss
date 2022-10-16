#include "inc_rand_equip"
#include "inc_rand_feat"
#include "inc_rand_appear"

// Users: Brute (prisonerbrut), Convict (prisonermele), Prisoner (prisonerrang), Sorceress (prisonermage)

// Before:
// Brute - unarmed
// Convict - club/large shield
// Prisoner - sling/club
// Sorceress - dagger

// Giving out better weapons here seems like a horrible idea from a difficulty standpoint
// Plus prisoners would probably only have clublike objects to bonk people with and not swords etc

void main()
{
    RandomiseGenderAndAppearance(OBJECT_SELF);
    RandomiseCreatureSoundset_Rough(OBJECT_SELF);
    string sResRef = GetResRef(OBJECT_SELF);
    if (sResRef == "prisonermele")
    {
        int nShield = BASE_ITEM_LARGESHIELD;
        if (d2() == 2)
        {
            nShield = BASE_ITEM_SMALLSHIELD;
        }
        TryEquippingRandomItemOfTier(nShield, 1, 1, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
        // Club is left intact
    }
    if (sResRef == "prisonermage")
    {
        if (GetGender(OBJECT_SELF) != GENDER_FEMALE)
        {
            SetName(OBJECT_SELF, "Escaped Sorcerer");
        }
    }
    
}
