void main()
{
    SetLocalInt(OBJECT_SELF, "range", 1);
    ClearAllActions();
    AssignCommand(OBJECT_SELF, ActionEquipMostDamagingRanged());
}
