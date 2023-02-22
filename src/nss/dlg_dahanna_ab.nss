#include "util_i_csvlists"
#include "inc_ai_combat"

void main()
{
    int nAttack = GetLocalInt(OBJECT_SELF, "attack");
    int nLeave = GetLocalInt(OBJECT_SELF, "leave");
    // Also attack if PC has been in maker3
    object oMaker3 = GetObjectByTag("ud_maker3");
    object oPC = GetPCSpeaker();
    string sPC = GetPCPublicCDKey(oPC) + GetName(oPC);
    if (FindListItem(GetLocalString(oMaker3, "pcs_entered"), sPC) > -1)
    {
        nAttack = 1;
    }


    if (nAttack || nLeave)
    {
        location lSelf = GetLocation(OBJECT_SELF);
        location lLeave = GetLocation(GetWaypointByTag("maker1_leave"));
        object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, lSelf);
        while (GetIsObjectValid(oTest))
        {
            if (oTest == OBJECT_SELF || (!GetIsPC(oTest) && !GetIsObjectValid(GetMaster(oTest)) && FindSubString(GetName(oTest), "Duergar") > -1))
            {
                if (nLeave)
                {
                    AssignCommand(oTest, ActionMoveToLocation(lLeave));
                    DestroyObject(oTest, 5.0);
                    // Dahanna shouldn't try to talk to you again
                    DeleteLocalString(oTest, "perception_script");
                }
                else
                {
                    ChangeToStandardFaction(oTest, STANDARD_FACTION_HOSTILE);
                    AssignCommand(oTest, FastBuff());
                    AssignCommand(oTest, gsCBDetermineCombatRound(oPC));
                }
            }
            oTest = GetNextObjectInShape(SHAPE_SPHERE, 30.0, lSelf);
        }
    }
}
