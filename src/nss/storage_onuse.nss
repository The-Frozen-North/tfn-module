#include "nwnx_player"
#include "inc_housing"

void main()
{
    object oPC = GetLastUsedBy();

    if (GetIsPC(oPC))
    {
        if (GetHomeTag(oPC) == GetTag(GetArea(OBJECT_SELF)))
        {
            NWNX_Player_ForcePlaceableInventoryWindow(oPC, GetObjectByTag(GetPCPublicCDKey(oPC)+"_"+GetResRef(OBJECT_SELF)));
            ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN);
        }
        else
        {
            FloatingTextStringOnCreature("This storage container does not belong to you.", oPC, FALSE);
        }
    }
}
