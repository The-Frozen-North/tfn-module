void main()
{
    ActionPauseConversation();

    object oPC = GetPCSpeaker();

    ActionCastFakeSpellAtObject(StringToInt(GetScriptParam("spell_id")), oPC);

    ActionResumeConversation();
}
