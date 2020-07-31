void main()
{
    object oTransition = GetTransitionTarget(OBJECT_SELF);
    SendMessageToPC(GetFirstPC(), "transition tag: "+GetTag(oTransition));
    SendMessageToPC(GetFirstPC(), "transition valid:"+IntToString(GetIsObjectValid(oTransition)));
    SendMessageToPC(GetFirstPC(), "transition stored variable:"+GetLocalString(OBJECT_SELF, "transition_target"));
}
