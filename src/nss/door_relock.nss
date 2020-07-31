void main()
{
     DelayCommand(300.0, ActionCloseDoor(OBJECT_SELF));
     DelayCommand(300.0, ActionLockObject(OBJECT_SELF));
}
