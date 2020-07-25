//::///////////////////////////////////////////////
//:: Community Patch OnLevelDown module event script
//:: 70_mod_leveldown
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script will run when player character loses level. Runs twice, before
the level is lost and after.

The usual use is to remove/recalculate possible custom content bonuses based on
feat or class.

Requires running game via NWNX or NWNCX and Community Patch plugin.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 31-05-2017
//:://////////////////////////////////////////////

const int LEVELDOWN_EVENTTYPE_LEVELDOWN_INVALID = 0;
const int LEVELDOWN_EVENTTYPE_LEVELDOWN_STARTED = 1;
const int LEVELDOWN_EVENTTYPE_LEVELDOWN_FINISHED = 2;
const int LEVELDOWN_EVENTTYPE_LEVELDOWN_COMPLETED = 3;


int GetLastLevelDownEventType()
{
return GetLocalInt(GetModule(),"GetLastLevelDownEventType()");
}

void main()
{
    object oPC = OBJECT_SELF;
    int nEvent = GetLastLevelDownEventType();

    if(nEvent == LEVELDOWN_EVENTTYPE_LEVELDOWN_STARTED)
    {
        int nLevelPre = GetLevelByPosition(1)+GetLevelByPosition(2)+GetLevelByPosition(3);
    }
    else if(nEvent == LEVELDOWN_EVENTTYPE_LEVELDOWN_FINISHED)
    {
        int nLevelAfter = GetLevelByPosition(1)+GetLevelByPosition(2)+GetLevelByPosition(3);
    }
    else if(nEvent == LEVELDOWN_EVENTTYPE_LEVELDOWN_COMPLETED)
    {
        ExecuteScript("70_featfix",OBJECT_SELF);
    }
}
