void main()
{
    object oCaster = GetLastSpellCaster();

    if (GetLastSpellHarmful() && GetIsEnemy(oCaster))
    {
        SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
    }
}
