///Checks if player has
//animalempathy

int StartingConditional()
{
    int iResult;

    iResult = GetSkillRank(SKILL_ANIMAL_EMPATHY,GetPCSpeaker())>=1;
    return iResult;
}
