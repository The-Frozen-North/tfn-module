int StartingConditional()
{
    object oPC = GetPCSpeaker();
    string sTag = GetTag(OBJECT_SELF);
    int nSkill = SKILL_BLUFF;
    int nDC = 10 + GetSkillRank(nSkill, OBJECT_SELF, TRUE);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC))) return FALSE;

    return TRUE;
}
