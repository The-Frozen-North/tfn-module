#include "inc_housing"

void main()
{
    object oPC = GetLastUsedBy();

    if (GetIsPC(oPC))
    {
        if (GetHomeTag(oPC) == GetTag(GetArea(OBJECT_SELF)))
        {
            ActionStartConversation(GetLastUsedBy(), "", TRUE, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("This house does not belong to you.", oPC, FALSE);
        }
    }
}
