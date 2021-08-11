//q2a2_ent_saltrg3
void main()
{
    object oPC = GetEnteringObject();
    if (GetIsPC(oPC) == TRUE)
    {
        //Grab the guards and have them stop and salute
        object oGuard1 = GetObjectByTag("q2amaemark1");
        object oGuard2 = GetObjectByTag("q2amaemark2");
        object oGuard3 = GetObjectByTag("q2amaemark3");
        AssignCommand(oGuard1, ClearAllActions(TRUE));
        AssignCommand(oGuard2, ClearAllActions(TRUE));
        AssignCommand(oGuard3, ClearAllActions(TRUE));

        AssignCommand(oGuard1, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        DelayCommand(0.5, AssignCommand(oGuard1, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

        AssignCommand(oGuard2, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        //DelayCommand(0.5, AssignCommand(oGuard2, ActionDoCommand(ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE))));

        AssignCommand(oGuard3, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        //AssignCommand(oGuard3, ActionDoCommand(ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

    }
}
