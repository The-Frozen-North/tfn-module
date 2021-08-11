//Jump the PC to Lith My'athar
void main()
{
    object oPC = GetPCSpeaker();
    object oTarget = GetWaypointByTag("wp_at_cavallas_port");

    AssignCommand(oPC, JumpToObject(oTarget));
}
