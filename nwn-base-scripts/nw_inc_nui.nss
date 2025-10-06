const int NUI_DIRECTION_HORIZONTAL         = 0;
const int NUI_DIRECTION_VERTICAL           = 1;

const int NUI_MOUSE_BUTTON_LEFT            = 0;
const int NUI_MOUSE_BUTTON_MIDDLE          = 1;
const int NUI_MOUSE_BUTTON_RIGHT           = 2;

const int NUI_SCROLLBARS_NONE              = 0;
const int NUI_SCROLLBARS_X                 = 1;
const int NUI_SCROLLBARS_Y                 = 2;
const int NUI_SCROLLBARS_BOTH              = 3;
const int NUI_SCROLLBARS_AUTO              = 4;

const int NUI_ASPECT_FIT                   = 0;
const int NUI_ASPECT_FILL                  = 1;
const int NUI_ASPECT_FIT100                = 2;
const int NUI_ASPECT_EXACT                 = 3;
const int NUI_ASPECT_EXACTSCALED           = 4;
const int NUI_ASPECT_STRETCH               = 5;

const int NUI_HALIGN_CENTER                = 0;
const int NUI_HALIGN_LEFT                  = 1;
const int NUI_HALIGN_RIGHT                 = 2;

const int NUI_VALIGN_MIDDLE                = 0;
const int NUI_VALIGN_TOP                   = 1;
const int NUI_VALIGN_BOTTOM                = 2;

// -----------------------
// Style

const float NUI_STYLE_PRIMARY_WIDTH        = 150.0;
const float NUI_STYLE_PRIMARY_HEIGHT       = 50.0;

const float NUI_STYLE_SECONDARY_WIDTH      = 150.0;
const float NUI_STYLE_SECONDARY_HEIGHT     = 35.0;

const float NUI_STYLE_TERTIARY_WIDTH       = 100.0;
const float NUI_STYLE_TERTIARY_HEIGHT      = 30.0;

const float NUI_STYLE_ROW_HEIGHT           = 25.0;

// -----------------------
// Bind params

// These currently only affect presentation and serve as a
// optimisation to let the client do the heavy lifting on this.
// In particular, this enables you to bind an array of values and
// transform them all at once on the client, instead of having to
// have the server transform them before sending.

// NB: These must be OR-ed together into a bitmask.

const int NUI_NUMBER_FLAG_HEX              = 0x001;

// NB: These must be OR-ed together into a bitmask.

const int NUI_TEXT_FLAG_LOWERCASE          = 0x001;
const int NUI_TEXT_FLAG_UPPERCASE          = 0x002;

// -----------------------
// Window

// Special cases:
// * Set the window title to JsonBool(FALSE), Collapse to JsonBool(FALSE) and bClosable to FALSE
//   to hide the title bar.
//   Note: You MUST provide a way to close the window some other way, or the user will be stuck with it.
// * Set a minimum size constraint equal to the maximmum size constraint in the same dimension to prevent
//   a window from being resized in that dimension.
json                        // Window
NuiWindow(    
  json jRoot,               // Layout-ish (NuiRow, NuiCol, NuiGroup)
  json jTitle,              // Bind:String
  json jGeometry,           // Bind:Rect        Set x and/or y to -1.0 to center the window on that axis
                            //                  Set x and/or y to -2.0 to position the window's top left at the mouse cursor's position of that axis
                            //                  Set x and/or y to -3.0 to center the window on the mouse cursor's position of that axis
  json jResizable,          // Bind:Bool        Set to JsonBool(TRUE) or JsonNull() to let user resize without binding.
  json jCollapsed,          // Bind:Bool        Set to a static value JsonBool(FALSE) to disable collapsing.
                            //                  Set to JsonNull() to let user collapse without binding.
                            //                  For better UX, leave collapsing on.
  json jClosable,           // Bind:Bool        You must provide a way to close the window if you set this to FALSE.
                            //                  For better UX, handle the window "closed" event.
  json jTransparent,        // Bind:Bool        Do not render background
  json jBorder,             // Bind:Bool        Do not render border
  json jAcceptsInput =      // Bind:Bool        Set JsonBool(FALSE) to disable all input.
    JSON_TRUE,              //                  All hover, clicks and keypresses will fall through.
  json jSizeConstraint =    // Bind:Rect        Constrains minimum and maximum size of window.
    JSON_NULL,              //                  Set x to minimum width, y to minimum height, w to maximum width, h to maximum height.
                            //                  Set any individual constraint to 0.0 to ignore that constraint.
  json jEdgeConstraint =    // Bind:Rect        Prevents a form from being rendered within the specified margins.
    JSON_NULL,              //                  Set x to left margin, y to top margin, w to right margin, h to bottom margin.
                            //                  Set any individual constraint to 0.0 to ignore that constraint.
  json jFont = JSON_STRING  // Bind:String      Override font used on window, including decorations. See NuiStyleFont() for details.
);

// -----------------------
// Values

// Create a dynamic bind. Unlike static values, these can change at runtime:
//    NuiBind("mybindlabel");
//    NuiSetBind(.., "mybindlabel", JsonString("hi"));
// To create static values, just use the json types directly:
//    JsonString("hi");
//
// You can parametrise this particular bind with the given flags.
// These flags only apply to that particular usage of this bind value.
json                      // Bind
NuiBind(
  string sId,
  int nNumberFlags = 0,   // bitmask of NUI_NUMBER_FLAG_*
  int nNumberPrecision = 0, // Precision to print number with (int or float)
  int nTextFlags = 0      // bitmask of NUI_TEXT_FLAG_*
);

// Tag the given element with a id.
// Only tagged elements will send events to the server.
json                     // Element
NuiId(
  json jElem,            // Element
  string sId             // String
);

// A shim/helper that can be used to render or bind a strref where otherwise
// a string value would go.
json
NuiStrRef(
    int nStrRef          // STRREF
);

// -----------------------
// Layout

// A column will auto-space all elements inside of it and advise the parent
// about it's desired size.
json                     // Layout
NuiCol(
  json jList             // Layout[] or Element[]
);

// A row will auto-space all elements inside of it and advise the parent
// about it's desired size.
json                     // Layout
NuiRow(
  json jList             // Layout[] or Element[]
);

// A group, usually with a border and some padding, holding a single element. Can scroll.
// Will not advise parent of size, so you need to let it fill a span (col/row) as if it was
// a element.
json                     // Layout
NuiGroup(
  json jChild,           // Layout or Element
  int bBorder = TRUE,
  int nScroll = NUI_SCROLLBARS_AUTO
);

// Modifiers/Attributes: These are all static and cannot be bound, since the UI system
// cannot easily reflow once the layout is set up. You need to swap the layout if you
// want to change element geometry.

json                     // Element
NuiWidth(
  json jElem,            // Element
  float fWidth           // Float: Element width in pixels (strength=required).
);

json                     // Element
NuiHeight(
  json jElem,            // Element
  float fHeight          // Float: Height in pixels (strength=required).
);

json                     // Element
NuiAspect(
  json jElem,            // Element
  float fAspect          // Float: Ratio of x/y.
);

// Set a margin on the widget. The margin is the spacing outside of the widget.
json                     // Element
NuiMargin(
  json jElem,            // Element
  float fMargin          // Float
);

// Set padding on the widget. The margin is the spacing inside of the widget.
json                     // Element
NuiPadding(
  json jElem,            // Element
  float fPadding         // Float
);

// Disabled elements are non-interactive and greyed out.
json                     // Element
NuiEnabled(
  json jElem,            // Element
  json jEnabler          // Bind:Bool
);

// Invisible elements do not render at all, but still take up layout space.
json                     // Element
NuiVisible(
  json jElem,            // Element
  json jVisible          // Bind:Bool
);

// Tooltips show on mouse hover.
json                     // Element
NuiTooltip(
  json jElem,            // Element
  json jTooltip          // Bind:String
);

// Tooltips for disabled elements show on mouse hover.
json                     // Element
NuiDisabledTooltip(
  json jElem,            // Element
  json jTooltip          // Bind:String
);

// Encouraged elements have a breathing animated glow inside of it.
json                     // Element
NuiEncouraged(
  json jElem,            // Element
  json jEncouraged       // Bind:Bool
);

// -----------------------
// Props & Style

json                     // Vec2
NuiVec(float x, float y);

json                     // Rect
NuiRect(float x, float y, float w, float h);

json                     // Color
NuiColor(int r, int g, int b, int a = 255);

// Style the foreground color of a widget or window title. This is dependent on the widget
// in question and only supports solid/full colors right now (no texture skinning).
// For example, labels would style their text color; progress bars would style the bar.
// To color the window title text, pass the result of NuiWindow into this function as jElem.
json                     // Element
NuiStyleForegroundColor(
  json jElem,            // Element
  json jColor            // Bind:Color
);

// Override the font used for this element. The font and it's properties needs to be listed in
// nui_skin.tml, as all fonts are pre-baked into a texture atlas at content load.
json
NuiStyleFont(
    json jElem,          // Element
    json sFont           // Bind:String ([[fonts]].name in nui_skin.tml)
);

// -----------------------
// Widgets

// A special widget that just takes up layout space.
// If you add multiple spacers to a span, they will try to size equally.
//  e.g.: [ <spacer> <button|w=50> <spacer> ] will try to center the button.
json                     // Element
NuiSpacer();

// Create a label field. Labels are single-line stylable non-editable text fields.
json                     // Element
NuiLabel(
  json jValue,           // Bind:String
  json jHAlign,          // Bind:Int:NUI_HALIGN_*
  json jVAlign           // Bind:Int:NUI_VALIGN_*
);

// Create a non-editable text field. Note: This text field internally implies a NuiGroup wrapped
// around it, which is providing the optional border and scrollbars.
json                     // Element
NuiText(
  json jValue,           // Bind:String
  int bBorder = TRUE,    // Bool
  int nScroll = NUI_SCROLLBARS_AUTO // Int:NUI_SCROLLBARS_*
);

// A clickable button with text as the label.
// Sends "click" events on click.
json                     // Element
NuiButton(
  json jLabel            // Bind:String
);

// A clickable button with an image as the label.
// Sends "click" events on click.
json                     // Element
NuiButtonImage(
  json jResRef           // Bind:ResRef
);

// A clickable button with text as the label.
// Same as the normal button, but this one is a toggle.
// Sends "click" events on click.
json                     // Element
NuiButtonSelect(
  json jLabel,           // Bind:String
  json jValue            // Bind:Bool
);

// A checkbox with a label to the right of it.
json                     // Element
NuiCheck(
  json jLabel,           // Bind:String
  json jBool             // Bind:Bool
);

// A image, with no border or padding.
json                     // Element
NuiImage(
  json jResRef,          // Bind:ResRef
  json jAspect,          // Bind:Int:NUI_ASPECT_*
  json jHAlign,          // Bind:Int:NUI_HALIGN_*
  json jVAlign           // Bind:Int:NUI_VALIGN_*
);

// Optionally render only subregion of jImage.  This property can be set on
// NuiImage and NuiButtonImage widgets.
// jRegion is a NuiRect (x, y, w, h) to indicate the render region inside the image.
json                     // NuiImage
NuiImageRegion(
    json jImage,         // NuiImage
    json jRegion         // Bind:NuiRect
);

// A combobox/dropdown.
json                     // Element
NuiCombo(
  json jElements,        // Bind:ComboEntry[]
  json jSelected         // Bind:Int (index into jElements)
);

json                     // ComboEntry
NuiComboEntry(
  string sLabel,
  int nValue
);

// A floating-point slider. A good step size for normal-sized sliders is 0.01.
json                     // Element
NuiSliderFloat(
  json jValue,           // Bind:Float
  json jMin,             // Bind:Float
  json jMax,             // Bind:Float
  json jStepSize         // Bind:Float
);

// A integer/discrete slider.
json                     // Element
NuiSlider(
  json jValue,           // Bind:Int
  json jMin,             // Bind:Int
  json jMax,             // Bind:Int
  json jStepSize         // Bind:Int
);

// A progress bar. Progress is always from 0.0 to 1.0.
json                     // Element
NuiProgress(
  json jValue            // Bind:Float (0.0->1.0)
);

// A editable text field.
json                     // Element
NuiTextEdit(
  json jPlaceholder,     // Bind:String
  json jValue,           // Bind:String
  int nMaxLength,        // UInt >= 1, <= 65535
  int bMultiline,        // Bool
  int bWordWrap = TRUE   // Bool
);

// Creates a list view of elements.
// jTemplate needs to be an array of NuiListTemplateCell instances.
// All binds referenced in jTemplate should be arrays of rRowCount size;
// e.g. when rendering a NuiLabel(), the bound label String should be an array of strings.
// You can pass in one of the template jRowCount into jSize as a convenience. The array
// size will be uses as the Int bind.
// jRowHeight defines the height of the rendered rows.
json                     // Element
NuiList(
  json jTemplate,        // NuiListTemplateCell[] (max: 16)
  json jRowCount,        // Bind:Int
  float fRowHeight = NUI_STYLE_ROW_HEIGHT,
  int bBorder = TRUE,
  int nScroll = NUI_SCROLLBARS_Y  // Note: Cannot be AUTO.
);

json                     // NuiListTemplateCell
NuiListTemplateCell(
  json jElem,            // Element
  float fWidth,          // Float:0 = auto, >1 = pixel width
  int bVariable          // Bool:Cell can grow if space is available; otherwise static
);

// A simple color picker, with no border or spacing.
json                     // Element
NuiColorPicker(
  json jColor            // Bind:Color
);

// A list of options (radio buttons). Only one can be selected
// at a time. jValue is updated every time a different element is
// selected. The special value -1 means "nothing".
json                     // Element
NuiOptions(
  int nDirection,        // NUI_DIRECTION_*
  json jElements,        // JsonArray of string labels
  json jValue            // Bind:Int
);

// A group of buttons.  Only one can be selected at a time.  jValue
// is updated every time a different button is selected.  The special
// value -1 means "nothing".
json                     // Element
NuiToggles(
  int nDirection,        // NUI_DIRECTION_*
  json jElements,        // JsonArray of string labels
  json jValue            // Bind:Int
);

const int NUI_CHART_TYPE_LINES                 = 0;
const int NUI_CHART_TYPE_COLUMN                = 1;

json                     // NuiChartSlot
NuiChartSlot(
  int nType,             // Int:NUI_CHART_TYPE_*
  json jLegend,          // Bind:String
  json jColor,           // Bind:NuiColor
  json jData             // Bind:Float[]
);

// Renders a chart.
// Currently, min and max values are determined automatically and
// cannot be influenced.
json                    // Element
NuiChart(
  json jSlots           // NuiChartSlot[]
);

// -----------------------
// Draw Lists

// Draw lists are raw painting primitives on top of widgets.
// They are anchored to the widget x/y coordinates, and are always
// painted in order of definition, without culling. You cannot bind
// the draw_list itself, but most parameters on individual draw_list
// entries can be bound.

const int NUI_DRAW_LIST_ITEM_TYPE_POLYLINE     = 0;
const int NUI_DRAW_LIST_ITEM_TYPE_CURVE        = 1;
const int NUI_DRAW_LIST_ITEM_TYPE_CIRCLE       = 2;
const int NUI_DRAW_LIST_ITEM_TYPE_ARC          = 3;
const int NUI_DRAW_LIST_ITEM_TYPE_TEXT         = 4;
const int NUI_DRAW_LIST_ITEM_TYPE_IMAGE        = 5;
const int NUI_DRAW_LIST_ITEM_TYPE_LINE         = 6;
const int NUI_DRAW_LIST_ITEM_TYPE_RECT         = 7;

// You can order draw list items to be painted either before, or after the
// builtin render of the widget in question. This enables you to paint "behind"
// a widget.

const int NUI_DRAW_LIST_ITEM_ORDER_BEFORE      = -1;
const int NUI_DRAW_LIST_ITEM_ORDER_AFTER       = 1;

// Always render draw list item (default).
const int NUI_DRAW_LIST_ITEM_RENDER_ALWAYS       = 0;
// Only render when NOT hovering.
const int NUI_DRAW_LIST_ITEM_RENDER_MOUSE_OFF    = 1;
// Only render when mouse is hovering.
const int NUI_DRAW_LIST_ITEM_RENDER_MOUSE_HOVER  = 2;
// Only render while LMB is held down.
const int NUI_DRAW_LIST_ITEM_RENDER_MOUSE_LEFT   = 3;
// Only render while RMB is held down.
const int NUI_DRAW_LIST_ITEM_RENDER_MOUSE_RIGHT  = 4;
// Only render while MMB is held down.
const int NUI_DRAW_LIST_ITEM_RENDER_MOUSE_MIDDLE = 5;

json                    // DrawListItem
NuiDrawListPolyLine(
  json jEnabled,        // Bind:Bool
  json jColor,          // Bind:Color
  json jFill,           // Bind:Bool
  json jLineThickness,  // Bind:Float
  json jPoints,         // Bind:Float[]    Always provide points in pairs
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE // Values in binds are considered arrays-of-values
);

json                    // DrawListItem
NuiDrawListCurve(
  json jEnabled,        // Bind:Bool
  json jColor,          // Bind:Color
  json jLineThickness,  // Bind:Float
  json jA,              // Bind:Vec2
  json jB,              // Bind:Vec2
  json jCtrl0,          // Bind:Vec2
  json jCtrl1,          // Bind:Vec2
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE // Values in binds are considered arrays-of-values
);

json                    // DrawListItem
NuiDrawListCircle(
  json jEnabled,        // Bind:Bool
  json jColor,          // Bind:Color
  json jFill,           // Bind:Bool
  json jLineThickness,  // Bind:Float
  json jRect,           // Bind:Rect
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE // Values in binds are considered arrays-of-values
);

json                    // DrawListItem
NuiDrawListArc(
  json jEnabled,        // Bind:Bool
  json jColor,          // Bind:Color
  json jFill,           // Bind:Bool
  json jLineThickness,  // Bind:Float
  json jCenter,         // Bind:Vec2
  json jRadius,         // Bind:Float
  json jAMin,           // Bind:Float
  json jAMax,           // Bind:Float
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE // Values in binds are considered arrays-of-values
);

json                    // DrawListItem
NuiDrawListText(
  json jEnabled,        // Bind:Bool
  json jColor,          // Bind:Color
  json jRect,           // Bind:Rect
  json jText,           // Bind:String
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE, // Values in binds are considered arrays-of-values
  json jFont = JSON_STRING // Bind:String
);

json                    // DrawListItem
NuiDrawListImage(
  json jEnabled,        // Bind:Bool
  json jResRef,         // Bind:ResRef
  json jPos,            // Bind:Rect
  json jAspect,         // Bind:Int:NUI_ASPECT_*
  json jHAlign,         // Bind:Int:NUI_HALIGN_*
  json jVAlign,         // Bind:Int:NUI_VALIGN_*
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE // Values in binds are considered arrays-of-values
);

json                    // DrawListItemImage
NuiDrawListImageRegion(
  json jDrawListImage,  // DrawListItemImage
  json jRegion          // Bind:NuiRect
);

json                    // DrawListItem
NuiDrawListLine(
  json jEnabled,        // Bind:Bool
  json jColor,          // Bind:Color
  json jLineThickness,  // Bind:Float
  json jA,              // Bind:Vec2
  json jB,              // Bind:Vec2
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE // Values in binds are considered arrays-of-values
);

json                    // DrawListItem
NuiDrawListRect(
  json jEnabled,        // Bind:Bool
  json jColor,          // Bind:Color
  json jFill,           // Bind:Bool
  json jLineThickness,  // Bind:Float
  json jRect,           // Bind:Rect
  int  nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER, // Int:NUI_DRAW_LIST_ITEM_ORDER_*
  int  nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS, // Int:NUI_DRAW_LIST_ITEM_RENDER_*
  int  nBindArrays = FALSE // Values in binds are considered arrays-of-values
);

json                    // Element
NuiDrawList(
  json jElem,           // Element
  json jScissor,        // Bind:Bool       Constrain painted elements to widget bounds.
  json jList            // DrawListItem[]
);

// -----------------------
// Implementation

json
NuiWindow(
  json jRoot,
  json jTitle,
  json jGeometry,
  json jResizable,
  json jCollapsed,
  json jClosable,
  json jTransparent,
  json jBorder,
  json jAcceptsInput = JSON_TRUE,
  json jWindowConstraint = JSON_NULL,
  json jEdgeConstraint = JSON_NULL,
  json jFont = JSON_STRING
)
{
  json ret = JsonObject();
  // Currently hardcoded and here to catch backwards-incompatible data in the future.
  ret = JsonObjectSet(ret, "version", JsonInt(1));
  ret = JsonObjectSet(ret, "title", jTitle);
  ret = JsonObjectSet(ret, "root", jRoot);
  ret = JsonObjectSet(ret, "geometry", jGeometry);
  ret = JsonObjectSet(ret, "resizable", jResizable);
  ret = JsonObjectSet(ret, "collapsed", jCollapsed);
  ret = JsonObjectSet(ret, "closable", jClosable);
  ret = JsonObjectSet(ret, "transparent", jTransparent);
  ret = JsonObjectSet(ret, "border", jBorder);
  ret = JsonObjectSet(ret, "accepts_input", jAcceptsInput);
  ret = JsonObjectSet(ret, "size_constraint", jWindowConstraint);
  ret = JsonObjectSet(ret, "edge_constraint", jEdgeConstraint);
  ret = NuiStyleFont(ret, jFont);
  return ret;
}

json
NuiElement(
  string sType,
  json jLabel,
  json jValue
)
{
    json ret = JsonObject();
    ret = JsonObjectSet(ret, "type", JsonString(sType));
    ret = JsonObjectSet(ret, "label", jLabel);
    ret = JsonObjectSet(ret, "value", jValue);
    return ret;
}

json
NuiBind(
  string sId,
  int nNumberFlags = 0,
  int nNumberPrecision = 0,
  int nTextFlags = 0
)
{
  json ret = JsonObject();
  ret = JsonObjectSet(ret, "bind", JsonString(sId));
  ret = JsonObjectSet(ret, "number_flags", JsonInt(nNumberFlags));
  ret = JsonObjectSet(ret, "number_precision", JsonInt(nNumberPrecision));
  ret = JsonObjectSet(ret, "text_flags", JsonInt(nTextFlags));
  return ret;
}

json
NuiId(
  json jElem,
  string sId
)
{
  return JsonObjectSet(jElem, "id", JsonString(sId));
}

json
NuiStrRef(
    int nStrRef
)
{
    json ret = JsonObject();
    ret = JsonObjectSet(ret, "strref", JsonInt(nStrRef));
    return ret;
}

json
NuiCol(
  json jList
)
{
  return JsonObjectSet(NuiElement("col", JsonNull(), JsonNull()), "children", jList);
}

json
NuiRow(
  json jList
)
{
  return JsonObjectSet(NuiElement("row", JsonNull(), JsonNull()), "children", jList);
}

json
NuiGroup(
  json jChild,
  int bBorder = TRUE,
  int nScroll = NUI_SCROLLBARS_AUTO
)
{
  json ret = NuiElement("group", JsonNull(), JsonNull());
  ret = JsonObjectSet(ret, "children", JsonArrayInsert(JsonArray(), jChild));
  ret = JsonObjectSet(ret, "border", JsonBool(bBorder));
  ret = JsonObjectSet(ret, "scrollbars", JsonInt(nScroll));
  return ret;
}

json
NuiWidth(json jElem, float fWidth)
{
  return JsonObjectSet(jElem, "width", JsonFloat(fWidth));
}

json
NuiHeight(json jElem, float fHeight)
{
  return JsonObjectSet(jElem, "height", JsonFloat(fHeight));
}

json
NuiAspect(json jElem, float fAspect)
{
  return JsonObjectSet(jElem, "aspect", JsonFloat(fAspect));
}

json
NuiMargin(
  json jElem,
  float fMargin
)
{
  return JsonObjectSet(jElem, "margin", JsonFloat(fMargin));
}

json
NuiPadding(
  json jElem,
  float fPadding
)
{
  return JsonObjectSet(jElem, "padding", JsonFloat(fPadding));
}

json
NuiEnabled(
  json jElem,
  json jEnabler
)
{
  return JsonObjectSet(jElem, "enabled", jEnabler);
}

json
NuiVisible(
  json jElem,
  json jVisible
)
{
  return JsonObjectSet(jElem, "visible", jVisible);
}

json
NuiTooltip(
  json jElem,
  json jTooltip
)
{
  return JsonObjectSet(jElem, "tooltip", jTooltip);
}

json
NuiDisabledTooltip(
  json jElem,
  json jTooltip
)
{
  return JsonObjectSet(jElem, "disabled_tooltip", jTooltip);
}

json
NuiEncouraged(
  json jElem,
  json jEncouraged
)
{
  return JsonObjectSet(jElem, "encouraged", jEncouraged);
}

json
NuiVec(float x, float y)
{
  json ret = JsonObject();
  ret = JsonObjectSet(ret, "x", JsonFloat(x));
  ret = JsonObjectSet(ret, "y", JsonFloat(y));
  return ret;
}

json
NuiRect(float x, float y, float w, float h)
{
  json ret = JsonObject();
  ret = JsonObjectSet(ret, "x", JsonFloat(x));
  ret = JsonObjectSet(ret, "y", JsonFloat(y));
  ret = JsonObjectSet(ret, "w", JsonFloat(w));
  ret = JsonObjectSet(ret, "h", JsonFloat(h));
  return ret;
}

json
NuiColor(int r, int g, int b, int a = 255)
{
  json ret = JsonObject();
  ret = JsonObjectSet(ret, "r", JsonInt(r));
  ret = JsonObjectSet(ret, "g", JsonInt(g));
  ret = JsonObjectSet(ret, "b", JsonInt(b));
  ret = JsonObjectSet(ret, "a", JsonInt(a));
  return ret;
}

json
NuiStyleForegroundColor(
  json jElem,
  json jColor
)
{
  return JsonObjectSet(jElem, "foreground_color", jColor);
}

json
NuiStyleFont(
  json jElem,
  json jFont
)
{
  return JsonObjectSet(jElem, "font", jFont);
}

json
NuiSpacer()
{
  return NuiElement("spacer", JsonNull(), JsonNull());
}

json
NuiLabel(
  json jValue,
  json jHAlign,
  json jVAlign
)
{
  json ret = NuiElement("label", JsonNull(), jValue);
  ret = JsonObjectSet(ret, "text_halign", jHAlign);
  ret = JsonObjectSet(ret, "text_valign", jVAlign);
  return ret;
}

json
NuiText(
  json jValue,
  int bBorder = TRUE,
  int nScroll = NUI_SCROLLBARS_AUTO
)
{
  json ret = NuiElement("text", JsonNull(), jValue);
  ret = JsonObjectSet(ret, "border", JsonBool(bBorder));
  ret = JsonObjectSet(ret, "scrollbars", JsonInt(nScroll));
  return ret;
}

json
NuiButton(
  json jLabel
)
{
  return NuiElement("button", jLabel, JsonNull());
}

json
NuiButtonImage(
  json jResRef
)
{
  return NuiElement("button_image", jResRef, JsonNull());
}

json
NuiButtonSelect(
  json jLabel,
  json jValue
)
{
  return NuiElement("button_select", jLabel, jValue);
}

json
NuiCheck(
  json jLabel,
  json jBool
)
{
  return NuiElement("check", jLabel, jBool);
}

json
NuiImage(
  json jResRef,
  json jAspect,
  json jHAlign,
  json jVAlign
)
{
  json img = NuiElement("image", JsonNull(), jResRef);
  img = JsonObjectSet(img, "image_aspect", jAspect);
  img = JsonObjectSet(img, "image_halign", jHAlign);
  img = JsonObjectSet(img, "image_valign", jVAlign);
  return img;
}

json
NuiImageRegion(
    json jImage,
    json jRegion
)
{
    return JsonObjectSet(jImage, "image_region", jRegion);
}

json
NuiCombo(
  json jElements,
  json jSelected
)
{
  return JsonObjectSet(NuiElement("combo", JsonNull(), jSelected), "elements", jElements);
}

json
NuiComboEntry(
  string sLabel,
  int nValue
)
{
  return JsonArrayInsert(JsonArrayInsert(JsonArray(), JsonString(sLabel)), JsonInt(nValue));
}

json
NuiSliderFloat(
  json jValue,
  json jMin,
  json jMax,
  json jStepSize
)
{
  json ret = NuiElement("sliderf", JsonNull(), jValue);
  ret = JsonObjectSet(ret, "min", jMin);
  ret = JsonObjectSet(ret, "max", jMax);
  ret = JsonObjectSet(ret, "step", jStepSize);
  return ret;
}

json
NuiSlider(
  json jValue,
  json jMin,
  json jMax,
  json jStepSize
)
{
  json ret = NuiElement("slider", JsonNull(), jValue);
  ret = JsonObjectSet(ret, "min", jMin);
  ret = JsonObjectSet(ret, "max", jMax);
  ret = JsonObjectSet(ret, "step", jStepSize);
  return ret;
}

json
NuiProgress(
  json jValue
)
{
  return NuiElement("progress", JsonNull(), jValue);
}

json
NuiTextEdit(
  json jPlaceholder,
  json jValue,
  int nMaxLength,
  int bMultiline,
  int bWordWrap = TRUE
)
{
  json ret = NuiElement("textedit", jPlaceholder, jValue);
  ret = JsonObjectSet(ret, "max", JsonInt(nMaxLength));
  ret = JsonObjectSet(ret, "multiline", JsonBool(bMultiline));
  ret = JsonObjectSet(ret, "wordwrap", JsonBool(bWordWrap));
  return ret;
}

json
NuiList(
  json jTemplate,
  json jRowCount,
  float fRowHeight = NUI_STYLE_ROW_HEIGHT,
  int bBorder = TRUE,
  int nScroll = NUI_SCROLLBARS_Y
)
{
  json ret = NuiElement("list", JsonNull(), JsonNull());
  ret = JsonObjectSet(ret, "row_template", jTemplate);
  ret = JsonObjectSet(ret, "row_count", jRowCount);
  ret = JsonObjectSet(ret, "row_height", JsonFloat(fRowHeight));
  ret = JsonObjectSet(ret, "border", JsonBool(bBorder));
  ret = JsonObjectSet(ret, "scrollbars", JsonInt(nScroll));
  return ret;
}

json
NuiListTemplateCell(
  json jElem,
  float fWidth,
  int bVariable
)
{
  json ret = JsonArray();
  ret = JsonArrayInsert(ret, jElem);
  ret = JsonArrayInsert(ret, JsonFloat(fWidth));
  ret = JsonArrayInsert(ret, JsonBool(bVariable));
  return ret;
}

json
NuiColorPicker(
  json jColor
)
{
  json ret = NuiElement("color_picker", JsonNull(), jColor);
  return ret;
}

json
NuiOptions(
  int nDirection,
  json jElements,
  json jValue
)
{
  json ret = NuiElement("options", JsonNull(), jValue);
  ret = JsonObjectSet(ret, "direction", JsonInt(nDirection));
  ret = JsonObjectSet(ret, "elements", jElements);
  return ret;
}

json
NuiToggles(
  int nDirection,
  json jElements,
  json jValue
)
{
  json ret = NuiElement("tabbar", JsonNull(), jValue);
  ret = JsonObjectSet(ret, "direction", JsonInt(nDirection));
  ret = JsonObjectSet(ret, "elements", jElements);
  return ret;
}

json
NuiChartSlot(
  int nType,
  json jLegend,
  json jColor,
  json jData
)
{
  json ret = JsonObject();
  ret = JsonObjectSet(ret, "type", JsonInt(nType));
  ret = JsonObjectSet(ret, "legend", jLegend);
  ret = JsonObjectSet(ret, "color", jColor);
  ret = JsonObjectSet(ret, "data", jData);
  return ret;
}

json
NuiChart(
  json jSlots
)
{
  json ret = NuiElement("chart", JsonNull(), jSlots);
  return ret;
}

json
NuiDrawListItem(
  int nType,
  json jEnabled,
  json jColor,
  json jFill,
  json jLineThickness,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = JsonObject();
  ret = JsonObjectSet(ret, "type", JsonInt(nType));
  ret = JsonObjectSet(ret, "enabled", jEnabled);
  ret = JsonObjectSet(ret, "color", jColor);
  ret = JsonObjectSet(ret, "fill", jFill);
  ret = JsonObjectSet(ret, "line_thickness", jLineThickness);
  ret = JsonObjectSet(ret, "order", JsonInt(nOrder));
  ret = JsonObjectSet(ret, "render", JsonInt(nRender));
  ret = JsonObjectSet(ret, "arrayBinds", JsonBool(nBindArrays));
  return ret;
}

json
NuiDrawListPolyLine(
  json jEnabled,
  json jColor,
  json jFill,
  json jLineThickness,
  json jPoints,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_POLYLINE, jEnabled, jColor, jFill, jLineThickness, nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "points", jPoints);
  return ret;
}

json
NuiDrawListCurve(
  json jEnabled,
  json jColor,
  json jLineThickness,
  json jA,
  json jB,
  json jCtrl0,
  json jCtrl1,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_CURVE, jEnabled, jColor, JsonBool(0), jLineThickness, nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "a", jA);
  ret = JsonObjectSet(ret, "b", jB);
  ret = JsonObjectSet(ret, "ctrl0", jCtrl0);
  ret = JsonObjectSet(ret, "ctrl1", jCtrl1);
  return ret;
}

json
NuiDrawListCircle(
  json jEnabled,
  json jColor,
  json jFill,
  json jLineThickness,
  json jRect,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_CIRCLE, jEnabled, jColor, jFill, jLineThickness, nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "rect", jRect);
  return ret;
}

json
NuiDrawListArc(
  json jEnabled,
  json jColor,
  json jFill,
  json jLineThickness,
  json jCenter,
  json jRadius,
  json jAMin,
  json jAMax,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_ARC, jEnabled, jColor, jFill, jLineThickness, nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "c", jCenter);
  ret = JsonObjectSet(ret, "radius", jRadius);
  ret = JsonObjectSet(ret, "amin", jAMin);
  ret = JsonObjectSet(ret, "amax", jAMax);
  return ret;
}

json
NuiDrawListText(
  json jEnabled,
  json jColor,
  json jRect,
  json jText,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE,
  json jFont = JSON_STRING
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_TEXT, jEnabled, jColor, JsonNull(), JsonNull(), nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "rect", jRect);
  ret = JsonObjectSet(ret, "text", jText);
  ret = NuiStyleFont(ret, jFont);
  return ret;
}

json
NuiDrawListImage(
  json jEnabled,
  json jResRef,
  json jRect,
  json jAspect,
  json jHAlign,
  json jVAlign,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_IMAGE, jEnabled, JsonNull(), JsonNull(), JsonNull(), nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "image", jResRef);
  ret = JsonObjectSet(ret, "rect", jRect);
  ret = JsonObjectSet(ret, "image_aspect", jAspect);
  ret = JsonObjectSet(ret, "image_halign", jHAlign);
  ret = JsonObjectSet(ret, "image_valign", jVAlign);
  return ret;
}

json
NuiDrawListImageRegion(
  json jDrawListImage,
  json jRegion
)
{
    return JsonObjectSet(jDrawListImage, "image_region", jRegion);
}

json
NuiDrawListLine(
  json jEnabled,
  json jColor,
  json jLineThickness,
  json jA,
  json jB,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_LINE, jEnabled, jColor, JsonNull(), jLineThickness, nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "a", jA);
  ret = JsonObjectSet(ret, "b", jB);
  return ret;
}

json
NuiDrawListRect(
  json jEnabled,
  json jColor,
  json jFill,
  json jLineThickness,
  json jRect,
  int nOrder = NUI_DRAW_LIST_ITEM_ORDER_AFTER,
  int nRender = NUI_DRAW_LIST_ITEM_RENDER_ALWAYS,
  int nBindArrays = FALSE
)
{
  json ret = NuiDrawListItem(NUI_DRAW_LIST_ITEM_TYPE_RECT, jEnabled, jColor, jFill, jLineThickness, nOrder, nRender, nBindArrays);
  ret = JsonObjectSet(ret, "rect", jRect);
  return ret;
}

json
NuiDrawList(
  json jElem,
  json jScissor,
  json jList
)
{
  json ret = JsonObjectSet(jElem, "draw_list", jList);
  ret = JsonObjectSet(ret, "draw_list_scissor", jScissor);
  return ret;
}

// json
// NuiCanvas(
//   json jList
// )
// {
//   json ret = NuiElement("canvas", JsonNull(), jList);
//   return ret;
// }

