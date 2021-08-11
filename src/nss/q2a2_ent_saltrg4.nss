//q2a2_ent_saltrg4
void main()
{
    object oPC = GetEnteringObject();
    if (GetIsPC(oPC) == TRUE)
    {
        //Grab the guards and have them stop and salute
        object oGuard1 = GetObjectByTag("q2amaemark4");
        object oGuard2 = GetObjectByTag("q2amaemark5");
        object oGuard3 = GetObjectByTag("q2amaemark6");
        AssignCommand(oGuard1, ClearAllActions(TRUE));
        AssignCommand(oGuard2, ClearAllActions(TRUE));
        AssignCommand(oGuard3, ClearAllActions(TRUE));

        AssignCommand(oGuard1, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        //AssignCommand(oGuard1, ActionDoCommand(ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

        AssignCommand(oGuard2, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        DelayCommand(0.5, AssignCommand(oGuard2, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

        AssignCommand(oGuard3, ActionDoCommand(SetFacingPoint(GetPosition(oPC))));
        //AssignCommand(oGuard3, ActionDoCommand(ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE)));

    }
}
