void main()
{
    if (GetIsEnemy(GetLastAttacker()))
    {
        SpeakString("I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
        SpeakString("MASTER_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
    }
}
