//q2a2_ent_saltrg2
void main()
{
    object oPC = GetEnteringObject();
    if (GetIsPC(oPC) == TRUE)
    {
        //Grab the guards and have them stop and salute
        object oGuard1 = GetObjectByTag("q2atrainreb4");
        object oGuard2 = GetObjectByTag("q2atrainreb5");
        object oGuard3 = GetObjectByTag("q2atrainreb6");
        AssignCommand(oGuard1, ClearAllActions(TRUE));
        AssignCommand(oGuard2, ClearAllActions(TRUE));
        AssignCommand(oGuard3, ClearAllActions(TRUE));

        AssignCommand(oGuard1, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        DelayCommand(0.5, AssignCommand(oGuard1, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

        AssignCommand(oGuard2, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        DelayCommand(1.5, AssignCommand(oGuard2, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

        AssignCommand(oGuard3, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        DelayCommand(0.5, AssignCommand(oGuard3, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

    }
}
