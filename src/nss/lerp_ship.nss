void main()
{
    float fDuration = 300.0;
    int nCount = GetLocalInt(OBJECT_SELF, "count");
    vector vPosition = GetPosition(OBJECT_SELF);

    if (GetLocalInt(OBJECT_SELF, "do_once") == 0)
    {
        SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, vPosition.x - 30.0);
        SetLocalInt(OBJECT_SELF, "do_once", 1);
    }

    //if (nCount > 200)
    //{
    //    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, vPosition.y + 1000.0);
    //    DeleteLocalInt(OBJECT_SELF, "count");
    //}
    //else if (nCount > 100)
    //{
        SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, vPosition.y + 100.0);
        SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, vPosition.y - 500.0, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHSTEP, fDuration);
        SetLocalInt(OBJECT_SELF, "count", nCount++);
    //}
    //else
    //{
    //    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, vPosition.y + 1000.0);
    //    SetLocalInt(OBJECT_SELF, "count", nCount++);
    //}
}
