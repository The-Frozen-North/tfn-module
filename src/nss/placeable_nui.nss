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

object MovePlaceableByCopying(object oTarget, object oPC, vector vPosition, float fFacing)
{
    location lLocation = Location(GetArea(oTarget), vPosition, fFacing);
    object oCopy = CopyObject(oTarget, lLocation, OBJECT_INVALID, "_HomePlaceable", TRUE);
    SetLocalObject(oPC, "0_Placeable_Target", oCopy);
    SetObjectHiliteColor(oCopy, YELLOW);
    DestroyObject(oTarget);

    return oCopy;
}

void main ()
{
    object oPC = NuiGetEventPlayer();
    int    nToken  = NuiGetEventWindow();
    string sEvent  = NuiGetEventType();
    string sElem   = NuiGetEventElement();
    //int    nIdx    = NuiGetEventArrayIndex();
    string sWndId  = NuiGetWindowId(oPC, nToken);

    if (!IsInOwnHome(oPC)) return;

    if (sWndId == "moveplaceablewin")
    {
        if (GetLocalInt(oPC, "placeable_cd") == 1) return;

        // this thing can really chug the server, so throttle players that attempt to spam it
        SetLocalInt(oPC, "placeable_cd", 1);
        DelayCommand(0.3, DeleteLocalInt(oPC, "placeable_cd"));

        object oTarget = GetLocalObject(oPC, "0_Placeable_Target");
        if (sEvent == "click")
        {
            /*
            if (sElem == "btn_get_placeable")
            {
                // Get Target.
                SetLocalString (oPC, "0_Target_Mode", "0_DM_GET_PLACEABLE_TARGET");
                EnterTargetingMode (oPC, OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_TILE, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            */
            if (sElem == "btn_rotate_left")
            {
                float fFacing = GetFacing (oTarget) + ROTATE_STEP;
                if (fFacing > 360.0f) fFacing = fFacing - 360.0f;
                // AssignCommand (oTarget, SetFacing (fFacing));
                MovePlaceableByCopying(oTarget, oPC, GetPosition(oTarget), fFacing);

                //float fFacing = GetNormalizedDirection(GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_ROTATE_X) + ROTATE_STEP);
                //if (fFacing > 360.0f) fFacing = fFacing - 360.0;
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_ROTATE_X, fFacing);
            }
            else if (sElem == "btn_north")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.y = vPosition.y + STEP;
                //NWNX_Object_SetPosition (oTarget, vPosition, FALSE);
                MovePlaceableByCopying(oTarget, oPC, vPosition, GetFacing(oTarget));

                //float fCurrent = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, fCurrent - STEP);
            }
            else if (sElem == "btn_rotate_right")
            {
                float fFacing = GetFacing (oTarget) - ROTATE_STEP;
                if (fFacing < 0.0f) fFacing = 360.0f + fFacing;
                //AssignCommand (oTarget, SetFacing (fFacing));
                MovePlaceableByCopying(oTarget, oPC, GetPosition(oTarget), fFacing);

                //float fFacing = GetNormalizedDirection(GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_ROTATE_X) - ROTATE_STEP);
                //if (fFacing < 0.0f) fFacing = 360.0f - fFacing;
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_ROTATE_X, fFacing);
            }
            else if (sElem == "btn_west")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.x = vPosition.x - STEP;
                //NWNX_Object_SetPosition(oTarget, vPosition, FALSE);
                MovePlaceableByCopying(oTarget, oPC, vPosition, GetFacing(oTarget));

                //float fCurrent = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, fCurrent + STEP);
            }
            else if (sElem == "btn_reset")
            {
                location lReset = GetLocalLocation (oTarget, "0_Reset_Location");
                vector vPosition = GetPositionFromLocation (lReset);
                float fFacing = GetFacingFromLocation (lReset);
                //NWNX_Object_SetPosition (oTarget, vPosition, FALSE);
                //AssignCommand (oTarget, SetFacing (fFacing));
                object oCopy = MovePlaceableByCopying(oTarget, oPC, vPosition, fFacing);

                // reset highlight color
                SetObjectHiliteColor(oCopy, -1);

                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, 0.0);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, 0.0);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_ROTATE_X, 0.0);

                FloatingTextStringOnCreature("Placeable location reset.", oPC, FALSE);
            }
            else if (sElem == "btn_east")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.x = vPosition.x + STEP;
                //NWNX_Object_SetPosition (oTarget, vPosition, FALSE);
                MovePlaceableByCopying(oTarget, oPC, vPosition, GetFacing(oTarget));

                //float fCurrent = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, fCurrent - STEP);
            }
            else if (sElem == "btn_up")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.z = vPosition.z + STEP;
                //NWNX_Object_SetPosition (oTarget, vPosition, FALSE);
                MovePlaceableByCopying(oTarget, oPC, vPosition, GetFacing(oTarget));
                
                //float fCurrent = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fCurrent + STEP);
            }
            else if (sElem == "btn_south")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.y = vPosition.y - STEP;
                //NWNX_Object_SetPosition (oTarget, vPosition, FALSE);
                MovePlaceableByCopying(oTarget, oPC, vPosition, GetFacing(oTarget));

                //float fCurrent = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, fCurrent + STEP);
            }
            else if (sElem == "btn_down")
            {
                vector vPosition = GetPosition (oTarget);
                vPosition.z = vPosition.z - STEP;
                //NWNX_Object_SetPosition (oTarget, vPosition, FALSE);
                MovePlaceableByCopying(oTarget, oPC, vPosition, GetFacing(oTarget));

                //float fCurrent = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z);
                //SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fCurrent - STEP);
            }

            if (sElem == "btn_save")
            {
                /*
                float fOffsetX = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X);
                float fOffsetY = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y);
                float fOffsetZ = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z);
                float fFacingOffset = GetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_ROTATE_X);

                vector vPosition = GetPosition(oTarget);

                vPosition.x = vPosition.x + fOffsetX;
                vPosition.y = vPosition.y + fOffsetY;
                vPosition.z = vPosition.z + fOffsetZ;

                float fFacing = GetNormalizedDirection(GetFacing(oTarget) + fFacingOffset);

                SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, 0.0);
                SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, 0.0);
                SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0);
                SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_ROTATE_X, 0.0);
                */

                SetLocalLocation(oTarget, "0_Reset_Location", GetLocation(oTarget));

                // reset highlight color
                SetObjectHiliteColor(oTarget, -1);

                // AssignCommand (oTarget, SetFacing(fFacing));
                // NWNX_Object_SetPosition(oTarget, vPosition, FALSE);

                UpdatePlaceable(oTarget, oPC, GetPosition(oTarget), GetFacing(oTarget), GetLocalString(oTarget, "uuid"));

                // when using set facing with very little degrees, it tends to not turn the object clientside at all even though the facing actually changed
                // this is a hack to reload the model and force that to happen
                // NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, oTarget, NWNX_VISIBILITY_HIDDEN);
                // DelayCommand(0.1, NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, oTarget, NWNX_VISIBILITY_DEFAULT));

                FloatingTextStringOnCreature("Placeable location saved.", oPC, FALSE);
            }
            else if (sElem == "btn_destroy")
            {
                RemovePlaceable(oPC, oTarget);
                DeleteLocalObject(oPC, "0_Placeable_Target");
                NuiDestroy(oPC, nToken);
                FloatingTextStringOnCreature("Placeable moved back to inventory.", oPC, FALSE);
                /*
                SetPlayerWinTarget (oPC, "No Target");
                oTarget = OBJECT_INVALID;
                NuiSetBind (oPC, nToken, "btn_rotate_right_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_north_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_rotate_left_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_west_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_reset_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_east_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_up_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_south_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_down_event", JsonBool (FALSE));
                NuiSetBind (oPC, nToken, "btn_destroy_event", JsonBool (FALSE));
                */
            }
        }
    }
}
