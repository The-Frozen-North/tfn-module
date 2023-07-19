int StartingConditional()
{
    // initialized
    if (GetLocalInt(GetModule(), "houses_initialized")) return FALSE;

    // not initialized
    return TRUE;
}
