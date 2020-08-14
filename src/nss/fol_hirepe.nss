#include "inc_follower"
#include "inc_persist"
#include "nw_i0_generic"


int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = GetLocalInt(OBJECT_SELF, "persuade_dc");

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        SetTemporaryInt(GetObjectUUID(oPC)+"_"+GetObjectUUID(OBJECT_SELF)+"_pers", 1, 900.0);
        return FALSE;
    }
    else
    {
        SetTag(OBJECT_SELF, "follower");

        SetFollowerMaster(OBJECT_SELF, oPC);
        SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);
        ClearAllActions();
        AssignCommand(OBJECT_SELF, ActionEquipMostDamagingMelee());
        return TRUE;
    }
}
