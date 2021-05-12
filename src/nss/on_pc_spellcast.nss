void main()
{
    object oCaster = GetLastSpellCaster();

    if (GetLastSpellHarmful() && GetIsEnemy(oCaster))
        SpeakString("MASTER_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);

}
