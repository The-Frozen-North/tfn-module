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
            SetCustomToken(CTOKEN_HOUSE_GOLDSTORAGE, IntToString(GetCampaignInt(GetPCPublicCDKey(oPC), "gold")));
            ActionStartConversation(GetLastUsedBy(), "", TRUE, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("This storage container does not belong to you.", oPC, FALSE);
        }
    }
}
