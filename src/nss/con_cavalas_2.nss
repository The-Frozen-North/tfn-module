//con_cavalas_2
//Return true if currently not at the island
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oArea = GetArea(oPC);
    if (GetTag(oArea) != "q4a_IslandOfTheMaker")
        return TRUE;
    return FALSE;
}
