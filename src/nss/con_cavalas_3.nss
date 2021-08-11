//con_cavalas_3
//Return true if currently not at the Shattered Mirror
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oArea = GetArea(oPC);
    if (GetTag(oArea) != "ShaorisFellEmptyCavern")
        return TRUE;
    return FALSE;
}
