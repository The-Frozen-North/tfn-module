void main()
{
    if (GetIsEnemy(GetLastAttacker()))
    {
        SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
    }
}
