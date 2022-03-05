void main()
{
     DelayCommand(30.0, ActionCloseDoor(OBJECT_SELF));
     DelayCommand(30.0, ActionLockObject(OBJECT_SELF));
}
