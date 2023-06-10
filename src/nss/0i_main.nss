/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_main
////////////////////////////////////////////////////////////////////////////////
 Include script for handling main/basic functions not defined by other includes.
*///////////////////////////////////////////////////////////////////////////////

// Makes extensive check for player characters (not DM's)
int GetIsCharacter (object oCreature);

// Will return a rolled result from a dice string.
// example: "1d6" will be 1-6 or "3d6" will be 3-18.
int RollDiceString (string sDice);

// Turns a location into a stringarray.
// lLocation is the location to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
string LocationToStringArray (location lLocation);

// Turns a stringarray into a location.
// sArray is the stringarray to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
location StringArrayToLocation (string sArray);

// This function will replace any occurrence of sFind in sSource with sReplace.
// sSource is the sourse text.
// sFind it what to find in the text.
// sReplace is what to replace sFind with.
string StringReplaceText (string sSource, string sFind, string sReplace);

// Gets a string of characters between the predefined marker of ":".
// sText is the text holding the array.
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays).
string GetStringArray (string sText, int iIndex, string sSeperator = ":");

// Sets a string of characters between the predefined markers of ":".
// sText is the text holding the array.
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sField is the field of characters to replace that index.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays).
string SetStringArray (string sText, int iIndex, string sField, string sSeperator = ":");

// Removes characters not in the sLegal string.
string RemoveIllegalCharacters (string sString, string sLegal = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");

// Makes extensive check for player characters (not DM's)
int GetIsCharacter (object oCreature)
{
    if (GetIsPC (oCreature) && !GetIsDM (oCreature) && !GetIsDMPossessed (oCreature)) return TRUE;
    return FALSE;
}

// Will return a rolled result from a dice string.
// example: "1d6" will be 1-6 or "3d6" will be 3-18 or 1d6+5 will be 6-11.
int RollDiceString (string sDice)
{
    int nNegativePos, nBonus = 0;
    string sRight = GetStringRight (sDice, GetStringLength (sDice) - FindSubString (sDice, "d") - 1);
    int nPlusPos = FindSubString (sRight, "+");
    if (nPlusPos != -1)
    {
        nBonus = StringToInt (GetStringRight (sRight, GetStringLength (sRight) - nPlusPos - 1));
        sRight = GetStringLeft (sRight, nPlusPos);
    }
    else
    {
        nNegativePos = FindSubString (sRight, "-");
        if (nNegativePos != -1)
        {
            nBonus = StringToInt (GetStringRight (sRight, GetStringLength (sRight) - nNegativePos - 1));
            sRight = GetStringLeft (sRight, nNegativePos);
            nBonus = nBonus * -1;
        }
    }
    int nDie = StringToInt (sRight);
    int nNumOfDie = StringToInt (GetStringLeft (sDice, FindSubString (sDice, "d")));
    int nResult;
    while (nNumOfDie > 0)
    {
        nResult += Random (nDie) + 1;
        nNumOfDie --;
    }
    return nResult + nBonus;
}

// Turns a location into a stringarray.
// lLocation is the location to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
string LocationToStringArray (location lLocation)
{
    string sLocation;
    object oArea;
    vector vPosition;
    float fFacing;
    oArea = GetAreaFromLocation (lLocation);
    vPosition = GetPositionFromLocation (lLocation);
    fFacing = GetFacingFromLocation (lLocation);
    sLocation = ":" + GetTag (oArea) + ":" + FloatToString(vPosition.x, 0, 2) + ":" +
          FloatToString(vPosition.y, 0, 2) + ":" + FloatToString(vPosition.z, 0, 2) + ":" +
          FloatToString (fFacing, 0, 2) + ":";
    return sLocation;
}

// Turns a stringarray into a location.
// sArray is the stringarray to change.
// StringArray definition :AreaTag:X:Y:Z:Facing:
location StringArrayToLocation (string sArray)
{
    object oArea;
    float fX, fY, fZ, fFacing;
    vector vPosition;
    oArea = GetObjectByTag (GetStringArray (sArray, 0));
    fX = StringToFloat (GetStringArray (sArray, 1));
    fY = StringToFloat (GetStringArray (sArray, 2));
    fZ = StringToFloat (GetStringArray (sArray, 3));
    vPosition = Vector(fX, fY, fZ);
    fFacing = StringToFloat (GetStringArray (sArray, 4));
    return Location (oArea, vPosition, fFacing);
}

// This function will replace any occurrence of sFind in sSource with sReplace.
// sSource is the sourse text.
// sFind it what to find in the text.
// sReplace is what to replace sFind with.
string StringReplaceText (string sSource, string sFind, string sReplace)
{
    int iFindLength = GetStringLength (sFind);
    int iPosition = 0;
    string sRetVal = "";
    // Locate all occurences of sFind.
    int iFound = FindSubString (sSource, sFind);
    while (iFound >= 0 )
    {
        // Build the return string, replacing this occurence of sFind with sReplace.
        sRetVal += GetSubString (sSource, iPosition, iFound - iPosition) + sReplace;
        iPosition = iFound + iFindLength;
        iFound = FindSubString (sSource, sFind, iPosition);
    }
    // Tack on the end of sSource and return.
    return sRetVal + GetStringRight (sSource, GetStringLength(sSource) - iPosition);
}

// Gets a string of characters between the predefined marker of ":".
// sArray is the text holding the array.
// sArray should look as follows ":0:0:0:0:0:"
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays).
string GetStringArray (string sArray, int iIndex, string sSeperator = ":")
{
   int iCount = 0, iMark = 0, iStringLength = GetStringLength (sArray);
   string sChar;
   // Search the string.
   while (iCount < iStringLength)
   {
      sChar = GetSubString (sArray, iCount, 1);
      // Look for the mark.
      if (sChar == sSeperator)
      {
         // If we have not found it then lets see if this mark is the one.
         if (iMark < 1)
         {
             // If we are down to 0 in the index then we have found the mark.
             if (iIndex > 0) iIndex --;
             // Mark the start of the string we need.
             else iMark = iCount + 1;
         }
         else
         {
            // We have the first mark so the next mark will mean we have the string we need.
            // Now pull it and return.
            sArray = GetSubString (sArray, iMark, iCount - iMark);
            return sArray;
         }
      }
      iCount ++;
   }
   // If we hit the end without finding it then return "" as an error.
   return "";
}

// Sets a string of characters between the predefined markers of ":".
// sArray is the text holding the array.
// sArray should look as follows ":0:0:0:0:0:"
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sField is the field of characters to replace that index.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays in one string).
string SetStringArray (string sArray, int iIndex, string sField, string sSeperator = ":")
{
   int iCount = 1, iMark = 1, iStringLength = GetStringLength (sArray);
   int iIndexCounter = 0;
   string sChar, sNewArray = sSeperator, sText;
   // Check to make sure this is not a new array.
   // If it is new then set it with 1 slot.
   if (iStringLength < 2)
   {
        sArray = sSeperator + " " + sSeperator;
        iStringLength = 3;
   }
   // Search the string.
   while (iCount <= iStringLength)
   {
      sChar = GetSubString (sArray, iCount, 1);
      // Look for the mark.
      if (sChar == sSeperator)
      {
            // First check to see if this is the index we are replacing.
            if (iIndex == iIndexCounter) sText = sField;
            else
            {
                // Get the original text for this field.
                sText = GetSubString (sArray, iMark, iCount - iMark);
            }
            // Add the field to the new index.
            sNewArray = sNewArray + sText + sSeperator;
            // Now set the marker to the new starting point.
            iMark = iCount + 1;
            // Increase the index counter as well.
            iIndexCounter ++;
      }
      iCount ++;
   }
   // if we are at the end of the array and still have not set the data
   // then add blank data until we get to the correct index.
   while (iIndexCounter <= iIndex)
   {
        // If they match add the field.
        if (iIndexCounter == iIndex) sNewArray = sNewArray + sField + sSeperator;
        // Otherwise just add a blank field.
        else sNewArray = sNewArray + " " + sSeperator;
        iIndexCounter ++;
   }
   // When done return the new array.
   return sNewArray;
}

// Removes characters not in the sLegal string.
string RemoveIllegalCharacters (string sString, string sLegal = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
{
    string sOut, sVal;
    int nLength = GetStringLength(sString);
    int i;
    for (i = 0; i != nLength; ++i)
    {
        sVal = GetSubString(sString, i, 1);
        if (TestStringAgainstPattern("**" + sVal + "**", sLegal))
            sOut += sVal;
    }
    return sOut;
}
