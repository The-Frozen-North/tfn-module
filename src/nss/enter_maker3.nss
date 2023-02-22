#include "util_i_csvlists"

void main()
{
    object oPC = GetEnteringObject();
    
    if (GetIsPC(oPC))
    {
        string sList = GetLocalString(OBJECT_SELF, "pcs_entered");
        string sPC = GetPCPublicCDKey(oPC) + GetName(oPC);
        sList = AddListItem(sList, sPC, TRUE);
        SetLocalString(OBJECT_SELF, "pcs_entered", sList);
    }
}
