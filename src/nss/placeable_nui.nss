// code from Philos, thank you!
/*
Learnings:
- NWNX set position is slow and laggy, but faster than CopyObject
- CopyObject seems less finicky
- Visual transform is the best but hard to map out the real location
*/
#include "nwnx_object"
#include "inc_housing"
#include "x0_i0_position"
#include "nwnx_visibility"

const float STEP = 0.1;
const float ROTATE_STEP = 10.0;
const int YELLOW = 0xFFFF00;

// Window id and event script, shared with placeable_edit.
const string WINDOW_ID = "moveplaceablewin";

// Fine rotation slider: -SLIDER_RANGE..+SLIDER_RANGE degrees (180 total) around the
// facing the placeable had when the window opened or was last saved/reset/rotated.
const string SLIDER_BIND = "rot_slider_value";
const string BASE_FACING_VAR = "placeable_base_facing";
const float SLIDER_APPLY_DELAY = 0.3;

object MovePlaceableByCopying(object oTarget, object oPC, vector vPosition, float fFacing)
{
    location lLocation = Location(GetArea(oTarget), vPosition, fFacing);
    object oCopy = CopyObject(oTarget, lLocation, OBJECT_INVALID, "_HomePlaceable", TRUE);
    SetLocalObject(oPC, "0_Placeable_Target", oCopy);
    SetObjectHiliteColor(oCopy, YELLOW);
    DestroyObject(oTarget);

    return oCopy;
}

// Returns the position after pressing sElem (unchanged if it is not a move button).
vector GetMovedPosition(string sElem, vector vPosition)
{
    if (sElem == "btn_north") vPosition.y += STEP;
    else if (sElem == "btn_south") vPosition.y -= STEP;
    else if (sElem == "btn_east") vPosition.x += STEP;
    else if (sElem == "btn_west") vPosition.x -= STEP;
    else if (sElem == "btn_up") vPosition.z += STEP;
    else if (sElem == "btn_down") vPosition.z -= STEP;
    return vPosition;
}

// Returns the facing after pressing sElem (unchanged if it is not a rotate button).
float GetRotatedFacing(string sElem, float fFacing)
{
    if (sElem == "btn_rotate_left") fFacing += ROTATE_STEP;
    else if (sElem == "btn_rotate_right") fFacing -= ROTATE_STEP;
    if (fFacing > 360.0) fFacing -= 360.0;
    else if (fFacing < 0.0) fFacing += 360.0;
    return fFacing;
}

// Make the slider the zero point for the placeable's current facing.
void SetBaseFacing(object oPC, int nToken, float fFacing)
{
    SetLocalFloat(oPC, BASE_FACING_VAR, fFacing);
    NuiSetBind(oPC, nToken, SLIDER_BIND, JsonInt(0));
}

// Applies the slider's current value. Runs delayed so dragging collapses into one update.
void ApplySliderRotation(object oPC, int nToken)
{
    DeleteLocalInt(oPC, "placeable_slider_pending");
    if (NuiGetWindowId(oPC, nToken) != WINDOW_ID) return;

    object oTarget = GetLocalObject(oPC, "0_Placeable_Target");
    if (!GetIsObjectValid(oTarget)) return;

    int nValue = JsonGetInt(NuiGetBind(oPC, nToken, SLIDER_BIND));
    float fFacing = GetNormalizedDirection(GetLocalFloat(oPC, BASE_FACING_VAR) + IntToFloat(nValue));
    if (fabs(fFacing - GetFacing(oTarget)) < 0.5) return;

    MovePlaceableByCopying(oTarget, oPC, GetPosition(oTarget), fFacing);
}

int IsMoveButton(string sElem)
{
    return sElem == "btn_north" || sElem == "btn_south" || sElem == "btn_east" ||
           sElem == "btn_west" || sElem == "btn_up" || sElem == "btn_down" ||
           sElem == "btn_rotate_left" || sElem == "btn_rotate_right";
}

void main ()
{
    object oPC = NuiGetEventPlayer();
    int    nToken  = NuiGetEventWindow();
    string sEvent  = NuiGetEventType();
    string sElem   = NuiGetEventElement();

    if (NuiGetWindowId(oPC, nToken) != WINDOW_ID) return;
    if (!IsInOwnHome(oPC)) return;

    if (sEvent == "watch" && sElem == SLIDER_BIND)
    {
        if (!GetLocalInt(oPC, "placeable_slider_pending"))
        {
            SetLocalInt(oPC, "placeable_slider_pending", 1);
            DelayCommand(SLIDER_APPLY_DELAY, ApplySliderRotation(oPC, nToken));
        }
        return;
    }

    if (sEvent != "click") return;

    if (GetLocalInt(oPC, "placeable_cd") == 1) return;

    // this thing can really chug the server, so throttle players that attempt to spam it
    SetLocalInt(oPC, "placeable_cd", 1);
    DelayCommand(0.3, DeleteLocalInt(oPC, "placeable_cd"));

    object oTarget = GetLocalObject(oPC, "0_Placeable_Target");
    if (!GetIsObjectValid(oTarget)) return;

    if (IsMoveButton(sElem))
    {
        vector vPosition = GetMovedPosition(sElem, GetPosition(oTarget));
        float fFacing = GetRotatedFacing(sElem, GetFacing(oTarget));
        MovePlaceableByCopying(oTarget, oPC, vPosition, fFacing);
        if (sElem == "btn_rotate_left" || sElem == "btn_rotate_right") SetBaseFacing(oPC, nToken, fFacing);
    }
    else if (sElem == "btn_reset")
    {
        location lReset = GetLocalLocation(oTarget, "0_Reset_Location");
        object oCopy = MovePlaceableByCopying(oTarget, oPC, GetPositionFromLocation(lReset), GetFacingFromLocation(lReset));
        SetBaseFacing(oPC, nToken, GetFacingFromLocation(lReset));

        // reset highlight color
        SetObjectHiliteColor(oCopy, -1);

        FloatingTextStringOnCreature("Placeable location reset.", oPC, FALSE);
    }
    else if (sElem == "btn_save")
    {
        SetLocalLocation(oTarget, "0_Reset_Location", GetLocation(oTarget));

        // reset highlight color
        SetObjectHiliteColor(oTarget, -1);

        UpdatePlaceable(oTarget, oPC, GetPosition(oTarget), GetFacing(oTarget), GetLocalString(oTarget, "uuid"));
        SetBaseFacing(oPC, nToken, GetFacing(oTarget));

        FloatingTextStringOnCreature("Placeable location saved.", oPC, FALSE);
    }
    else if (sElem == "btn_destroy")
    {
        RemovePlaceable(oPC, oTarget);
        DeleteLocalObject(oPC, "0_Placeable_Target");
        NuiDestroy(oPC, nToken);
        FloatingTextStringOnCreature("Placeable moved back to inventory.", oPC, FALSE);
    }
}
