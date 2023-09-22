#include "inc_henchman"
#include "inc_persist"
#include "inc_general"
#include "inc_xp"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 11 + GetHenchmanCount(oPC)*6;

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetResRef(OBJECT_SELF), 1, 900.0);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "persuade_failed");
        return FALSE;
    }
    else
    {
        GiveDialogueSkillXP(oPC, nDC, nSkill);
        IncrementPlayerStatistic(oPC, "persuade_succeeded");
        IncrementPlayerStatistic(oPC, "henchman_recruited");
        SetMaster(OBJECT_SELF, oPC);
        ForceRest(OBJECT_SELF);
        return TRUE;
    }
}
