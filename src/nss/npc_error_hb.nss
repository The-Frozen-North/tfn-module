void main()
{
    int nModuleObjectLoopCount = GetLocalInt(OBJECT_SELF, "module_looped_object_count");
    if (nModuleObjectLoopCount != 0) SpeakString("Module object loop stopped at "+IntToString(nModuleObjectLoopCount), TALKVOLUME_SHOUT);
}
