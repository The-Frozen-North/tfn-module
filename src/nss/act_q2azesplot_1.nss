//::///////////////////////////////////////////////
//:: Name act_q2azesplot_1
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Jump the PC into House Maeviir - they'll
    have to fight the Matron or betray Zessyr
*/
//:://////////////////////////////////////////////
//:: Created By:  Keith Warner
//:: Created On:  Sept 26/03
//:://////////////////////////////////////////////

void main()
{
    object oPC = GetPCSpeaker();
    //Set variable so entering the house will trigger the correct scene
    SetLocalInt(GetModule(), "X2_Q2AZesPlotScene", 1);

    //Jump Zesyyr and guards into position for the cutscene
    object oZesTarget = GetWaypointByTag("cut108wp_copystart");

    object oZesyyr = GetObjectByTag("q2amaezesyyr");
    SetAILevel(oZesyyr, AI_LEVEL_NORMAL);
    object oGuard1 = GetObjectByTag("q2azesguard1");
    SetAILevel(oGuard1, AI_LEVEL_NORMAL);
    object oGuard2 = GetObjectByTag("q2azesguard2");
    SetAILevel(oGuard2, AI_LEVEL_NORMAL);

    AssignCommand(oZesyyr, JumpToObject(oZesTarget));
    AssignCommand(oGuard1, JumpToObject(oZesTarget));
    AssignCommand(oGuard2, JumpToObject(oZesTarget));

    //Destroy the Ring
    object oRing = GetLocalObject(OBJECT_SELF, "oRing");
    DestroyObject(oRing);

    //Jump PC into the house
    object oTarget = GetWaypointByTag("wp_zesplot_pcstart");
    AssignCommand(oPC, JumpToObject(oTarget));
}
