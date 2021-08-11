//con_cavalas_1
//Return true if currently not in the city
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oArea = GetArea(oPC);
    if (GetTag(oArea) != "q2a_city2")
        return TRUE;
    return FALSE;
}
