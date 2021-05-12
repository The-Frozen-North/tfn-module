void main()
{
    if (GetIsEnemy(GetLastAttacker()))
        SpeakString("MASTER_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
}
