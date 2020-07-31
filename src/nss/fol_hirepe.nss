#include "inc_follower"
#include "inc_persist"
#include "nw_i0_generic"


int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 10 + GetFollowerCount(oPC)*6;

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_militia_pers", 1, 900.0);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        return FALSE;
    }
    else
    {
        SetFollowerMaster(OBJECT_SELF, oPC);
        SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);
        ClearAllActions();
        AssignCommand(OBJECT_SELF, ActionEquipMostDamagingMelee());
        return TRUE;
    }
}
