void main()
{
    string sErrors = GetLocalString(OBJECT_SELF, "errors");
    if (sErrors != "") SpeakString(sErrors, TALKVOLUME_SHOUT);
}
