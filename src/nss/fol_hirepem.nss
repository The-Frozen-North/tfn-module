#include "inc_follower"
#include "inc_persist"
#include "inc_general"
#include "nw_i0_generic"


int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 10 + GetFollowerCount(oPC)*6;

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "persuade_failed");
        SetTemporaryInt(GetObjectUUID(oPC)+"_"+GetObjectUUID(OBJECT_SELF)+"_pers", 1, 900.0);
        return FALSE;
    }
    else
    {
        IncrementPlayerStatistic(oPC, "persuade_succeeded");
        SetFollowerMaster(OBJECT_SELF, oPC);
        SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);
        ClearAllActions();
        AssignCommand(OBJECT_SELF, ActionEquipMostDamagingMelee());
        return TRUE;
    }
}
