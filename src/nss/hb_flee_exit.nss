void main()
{
    ActionMoveToObject(GetNearestObject(OBJECT_TYPE_DOOR));
    ActionDoCommand(DestroyObject(OBJECT_SELF));
}
