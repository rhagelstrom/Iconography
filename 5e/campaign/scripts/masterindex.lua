--    Author: Ryan Hagelstrom
--    Copyright © 2024
--    This work is licensed under a Creative Commons license 3.0.
--    http://creativecommons.org/licenses/by/3.0/
-- luacheck: globals onInit update Iconography
function onInit()
    if super and super.onInit then
        super.onInit();
    end
    update()
end

function update()
    local sIcon = IconographyManager.parseEffectLabelGetIcon(name.getValue(), true)
    if sIcon == 'blank_Iconography' then
        local node = name.getDatabaseNode();
        local sSchool = DB.getValue(DB.getChild(node, '..school', ''));
        sIcon = IconographyManager.parseEffectLabelGetIcon(sSchool, true);
    end
    Iconography.setIcon(sIcon);
    if sIcon == 'blank_Iconography' then
        name.setAnchor('right', 'rightanchor', 'left', 'relative', -5);
        Iconography.setVisible(false);
        Iconography.setEnabled(false);
        -- Debug.chat("Here")
    else
        Iconography.setVisible(true);
        Iconography.setEnabled(true);
        name.setAnchor('right', 'rightanchor', 'left', 'relative', 55);

    end
--     <anchored position="insidetopleft" offset="30,2" height="20">
--     <right parent="rightanchor" anchor="left" relation="relative" offset="-5" />
end
