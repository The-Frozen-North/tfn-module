#include "inc_housing"

void main()
{
    object oPC = GetLastUsedBy();

    if (GetIsPC(oPC))
    {
        if (GetHomeTag(oPC) == GetTag(GetArea(OBJECT_SELF)))
        {
            SetCustomToken(29901, IntToString(GetCampaignInt(GetPCPublicCDKey(oPC), "gold")));
            ActionStartConversation(GetLastUsedBy(), "", TRUE, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("This storage container does not belong to you.", oPC, FALSE);
        }
    }
}
