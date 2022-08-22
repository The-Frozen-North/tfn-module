// See also: area_ref_udobl.nss (area refresh script)

// Pulling the lever will solve the puzzle if there are 1-3 wrong tiles left
// But it also destroys the same number of loot containers on the other side of the gate

void FlipTile(object oTile, int nState)
{
    SetLocalInt(oTile, "tilestate", nState);
    ExecuteScript("ud_obpuz_tiletex", oTile);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_M), oTile);
    // Find and destroy a loot container
    object oArea = GetArea(OBJECT_SELF);
    int i;
    for (i=1; i<=100; i++)
    {
        object oLoot = GetLocalObject(oArea, "UDObeliskPuzzleLoot" + IntToString(i));
        if (GetIsObjectValid(oLoot))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_M), oLoot);
            DestroyObject(oLoot);
            break;
        }
    }
}

void FinishPuzzle(object oTile)
{
    object oArea = GetArea(OBJECT_SELF);
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
    int PUZZLE_MAX_FORCED = GetLocalInt(oArea, "PUZZLE_MAX_FORCED");
    for (i=1; i<=PUZZLE_MAX_FORCED; i++)
    {
        object oLoot = GetLocalObject(oArea, "UDObeliskPuzzleLoot" + IntToString(i));
        if (GetIsObjectValid(oLoot))
        {
            ExecuteScript("treas_init", oLoot);
        }
    }
    AssignCommand(oTile, SpeakString("With the last of the tiles flipped to the same color, the mechanism clatters once more. The hissing of gas stops."));
    DelayCommand(1.0, AssignCommand(oTile, SpeakString("It sounds like the nearby gate can now be opened.")));
}

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    if (GetLocalInt(oArea, "UDObeliskPuzzleComplete"))
    {
        return;
    }
    int PUZZLE_GRID_SIZE = GetLocalInt(oArea, "PUZZLE_GRID_SIZE");
    int PUZZLE_MAX_FORCED = GetLocalInt(oArea, "PUZZLE_MAX_FORCED");
    // See if the puzzle is complete
    int nState0 = 0;
    int nState1 = 0;
    int nMyState = GetLocalInt(OBJECT_SELF, "tilestate");
    int x;
    int y;
    int bCanFinishPuzzle = 0;
    int bGiveUpCheckingPuzzle = 0;
    
    for (x=0; x<PUZZLE_GRID_SIZE; x++)
    {
        for (y=0; y<PUZZLE_GRID_SIZE; y++)
        {
            string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
            object oTile = GetLocalObject(oArea, sVar);
            if (GetIsObjectValid(oTile))
            {
                if (GetLocalInt(oTile, "tilestate"))
                {
                    nState1++;
                }
                else
                {
                    nState0++;
                }
            }
            // Once this is the case there's no longer any point in checking more tiles because we can't autocomplete
            if (nState0 > PUZZLE_MAX_FORCED && nState1 > PUZZLE_MAX_FORCED)
            {
                bGiveUpCheckingPuzzle = 1;
                break;
            }
        }
        if (bGiveUpCheckingPuzzle)
        {
            break;
        }
    }
    
    int nFinishState;
    
    if (nState0 <= PUZZLE_MAX_FORCED || nState1 <= PUZZLE_MAX_FORCED)
    {
        bCanFinishPuzzle = 1;
        nFinishState = nState0 <= PUZZLE_MAX_FORCED;
    }
    
    if (!bCanFinishPuzzle)
    {
        SpeakString("From the strange control, a voice clearly intones:\nOne stuck tile costs one golden pile,\nBut the risk increases all the while.");
    }
    else
    {
        SpeakString("The deal is struck!");
        float fDelay = 0.0;
        int nTilesForced = 0;
        object oTile;
        for (x=0; x<PUZZLE_GRID_SIZE; x++)
        {
            for (y=0; y<PUZZLE_GRID_SIZE; y++)
            {
                string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
                oTile = GetLocalObject(oArea, sVar);
                if (GetIsObjectValid(oTile))
                {
                    if (GetLocalInt(oTile, "tilestate") != nFinishState)
                    {
                        nTilesForced++;
                        DelayCommand(fDelay, FlipTile(oTile, nFinishState));
                        fDelay += 0.5;
                    }
                }
            }
        }
        // Immediately lock the puzzle tiles
        SetLocalInt(oArea, "UDObeliskPuzzleComplete", 1);
        DelayCommand(fDelay, FinishPuzzle(oTile));
        
    }
    
    
}