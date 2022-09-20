#include "nwnx_player"
#include "inc_housing"
#include "inc_persist"

void main()
{
    object oPC = GetLastUsedBy();

    if (GetIsPC(oPC))
    {
        if (GetHomeTag(oPC) == GetTag(GetArea(OBJECT_SELF)))
        {
            if (!CanSavePCInfo(oPC))
            {
                FloatingTextStringOnCreature("You cannot use house storage while polymorphed or bartering.", oPC, FALSE);
                return;
            }
            NWNX_Player_ForcePlaceableInventoryWindow(oPC, GetObjectByTag(GetPCPublicCDKey(oPC)+"_"+GetResRef(OBJECT_SELF)));
            ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN);
        }
        else
        {
            FloatingTextStringOnCreature("This storage container does not belong to you.", oPC, FALSE);
        }
    }
}
