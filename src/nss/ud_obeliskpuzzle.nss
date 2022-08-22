// See also: area_ref_udobl.nss (area refresh script)

void BeLocked()
{
    ActionCloseDoor(OBJECT_SELF);
    SetLocked(OBJECT_SELF, TRUE);
    SetLockKeyRequired(OBJECT_SELF, TRUE);
    SpeakString("There is a clattering sound from the door. It seems as though some mechanism has sealed it.");
}

void main()
{
    int PUZZLE_GRID_SIZE = GetLocalInt(GetArea(OBJECT_SELF), "PUZZLE_GRID_SIZE");
    object oArea = GetArea(OBJECT_SELF);
    if (GetLocalInt(oArea, "UDObeliskPuzzleComplete"))
    {
        return;
    }
    // If someone is using this without opening the entry gate first
    // then teleport them out.
    // The first gate requires the key from the bebilith to open and is consumed
    // to stop you from logging out at any point in the puzzle, looting it, waiting for it to refresh, and then logging out safely
    // The loot piles do not function until the puzzle is completed, and well, you need to be able to use the tiles to complete the puzzle...
    // This makes that quite hard!
    int bAreaInit = GetLocalInt(oArea, "UDObeliskInInit");
    if (GetLocked(GetObjectByTag("UDObeliskPuzzleFrontGate")) && !bAreaInit)
    {
        SpeakString("The floor tile swirls with magic and sends you flying back over the locked gate!");
        AssignCommand(GetLastUsedBy(), ActionJumpToLocation(GetLocation(GetWaypointByTag("UDObeliskEntranceTarget"))));
        return;
    }
    
    int nMyX = GetLocalInt(OBJECT_SELF, "TileX");
    int nMyY = GetLocalInt(OBJECT_SELF, "TileY");
    // + shape, so self, (X-1, Y), (X+1, Y), (X, Y+1), (X, Y-1)
    int i;
    for (i=0; i<5; i++)
    {
        int x;
        int y;
        if (i == 0) { x = nMyX; y = nMyY; }
        else if (i == 1) { x = nMyX-1; y = nMyY; }
        else if (i == 2) { x = nMyX+1; y = nMyY; }
        else if (i == 3) { x = nMyX; y = nMyY+1; }
        else if (i == 4) { x = nMyX; y = nMyY-1; }
        string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
        object oTile = GetLocalObject(oArea, sVar);
        // Trying to access a tile over an edge will do this
        if (!GetIsObjectValid(oTile))
        {
            continue;
        }
        
        // Flip it
        SetLocalInt(oTile, "tilestate", !GetLocalInt(oTile, "tilestate"));
        // Retexture
        ExecuteScript("ud_obpuz_tiletex", oTile);
        int nVFX;
        if (i == 0)
        {
            //nVFX = VFX_IMP_POLYMORPH;
            nVFX = VFX_IMP_CONFUSION_S;
        }
        else
        {
            nVFX = VFX_IMP_MAGIC_RESISTANCE_USE;
        }
        if (!bAreaInit)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nVFX), oTile);
        }
    }
    // Trigger the trap if it's not triggered
    if (!bAreaInit)
    {
        if (!GetLocalInt(oArea, "UDObeliskTrapTriggered"))
        {
            SetLocalInt(oArea, "UDObeliskTrapTriggered", 1);
            // Make fog
            for (i=1; i<=2; i++)
            {
                location lFog = GetLocation(GetWaypointByTag("UDTilePuzzleFog" + IntToString(i)));
                object oFog = CreateObject(OBJECT_TYPE_PLACEABLE, "tm_pl_ifog50_md", lFog);
                SetLocalObject(oArea, "UDObeliskFog" + IntToString(i), oFog);
            }
            SpeakString("With the clatter of mechanisms, there is a hissing of gas. You hear the door to the room creak closed behind you.");
            object oDoor = GetObjectByTag("UDObeliskPuzzleEntrance");
            AssignCommand(oDoor, BeLocked());
        }
    }
    
    // See if the puzzle is complete
    int bDone = 1;
    int nMyState = GetLocalInt(OBJECT_SELF, "tilestate");
    int x;
    int y;
    for (x=0; x<PUZZLE_GRID_SIZE; x++)
    {
        for (y=0; y<PUZZLE_GRID_SIZE; y++)
        {
            string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
            object oTile = GetLocalObject(oArea, sVar);
            if (GetIsObjectValid(oTile))
            {
                if (GetLocalInt(oTile, "tilestate") != nMyState)
                {
                    bDone = 0;
                    break;
                }
            }
        }
        if (!bDone)
        {
            break;
        }
    }
    
    if (bDone)
    {
        SetLocalInt(oArea, "UDObeliskPuzzleComplete", 1);
        object oExit = GetObjectByTag("UDObeliskPuzzleProgression");
        SetLocked(oExit, FALSE);
        oExit = GetObjectByTag("UDObeliskPuzzleEntrance");
        SetLocked(oExit, FALSE);
        // Destroy fog
        int i;
        for (i=1; i<=2; i++)
        {
            object oFog = GetLocalObject(oArea, "UDObeliskFog" + IntToString(i));
            if (GetIsObjectValid(oFog))
            {
                DestroyObject(oFog);
            }
        }
        SpeakString("With the last of the tiles flipped to the same color, the mechanism clatters once more. The hissing of gas stops.");
        DelayCommand(1.0, SpeakString("It sounds like the nearby gate can now be opened."));
        // Unlock loot
        int PUZZLE_MAX_FORCED = GetLocalInt(oArea, "PUZZLE_MAX_FORCED");
        for (i=1; i<=PUZZLE_MAX_FORCED; i++)
        {
            object oLoot = GetLocalObject(oArea, "UDObeliskPuzzleLoot" + IntToString(i));
            if (GetIsObjectValid(oLoot))
            {
                ExecuteScript("treas_init", oLoot);
            }
        }
    }
}