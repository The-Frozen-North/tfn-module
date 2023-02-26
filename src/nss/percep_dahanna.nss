// Dahanna (isle of the maker surface)

#include "util_i_csvlists"

void main()
{
    object oPC = GetLastPerceived();
    if (GetIsPC(oPC) && GetLastPerceptionSeen() && !IsInConversation(OBJECT_SELF))
    {
        string sPC = GetPCPublicCDKey(oPC) + GetName(oPC);;
        object oMaker3 = GetObjectByTag("ud_maker3");
        if (FindListItem(GetLocalString(oMaker3, "pcs_entered"), sPC) > -1)
        {
            AssignCommand(oPC, ClearAllActions());
            BeginConversation("", oPC);
        }
    }
}
