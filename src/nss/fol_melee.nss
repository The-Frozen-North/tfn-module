void main()
{
    DeleteLocalInt(OBJECT_SELF, "range");
    ClearAllActions();
    AssignCommand(OBJECT_SELF, ActionEquipMostDamagingMelee());
}
