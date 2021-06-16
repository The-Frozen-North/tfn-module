// From ladder script in Last Stand / Castle Defense 2
void main()
{
object oPC = GetLastUsedBy();
object oTarget = GetNearestObjectByTag(GetTag(OBJECT_SELF));
AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 6.0));
FloatingTextStringOnCreature("Attempting...", oPC);
DelayCommand(0.01, SetCommandable(FALSE, oPC));
DelayCommand(4.5, SetCommandable(TRUE, oPC));
DelayCommand(4.44, AssignCommand(oPC, ClearAllActions()));
DelayCommand(4.5, AssignCommand(oPC, ActionJumpToObject(oTarget)));
}
