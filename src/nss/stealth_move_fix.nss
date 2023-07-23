// currently MOVEMENT_STAGE_PENALTY_STEALTH_MODE 0 still forces the player to walk when clicking to move, force the player to run
// this can be removed if it is fixed in another patch
#include "nwnx_events"

void main()
{
    object oPC = OBJECT_SELF;

// do nothing if not a PC, because creatures probably don't use click to move
    if (!GetIsPC(oPC)) return;

// if we have detect mode active, do nothing because detect mode still has a movement penalty here
    if (!GetHasFeat(FEAT_KEEN_SENSE, oPC) && GetDetectMode(oPC) == DETECT_MODE_ACTIVE) return;

// not in stealth mode, no fix needed
    if (GetStealthMode(oPC) != STEALTH_MODE_ACTIVATED) return;

    object oArea = GetArea(oPC);
    float fOrientation = GetFacing(oPC); // I don't think PCs should be facing the same way from before they moved, but better than 0.0 orientation
    float fX = StringToFloat(NWNX_Events_GetEventData("POS_X"));
    float fY = StringToFloat(NWNX_Events_GetEventData("POS_Y"));
    float fZ = StringToFloat(NWNX_Events_GetEventData("POS_Z"));

    location lLocation = Location(oArea, Vector(fX, fY, fZ), fOrientation);

// not sure if this event can be skipped
    NWNX_Events_SkipEvent();

// clear all actions or it gets queued up when clicking rapidly, these movement actions seem to clear actions anyways
// this makes it quite glitchy when holding down click to move in "arrow mode", oh well
    ClearAllActions();

// make the PC run
    ActionMoveToLocation(lLocation, TRUE);
}
