--  	Author: Ryan Hagelstrom
--	  	Copyright © 2024
--	  	This work is licensed under a Creative Commons license 3.0.
--      http://creativecommons.org/licenses/by/3.0/
-- luacheck: globals onInit onClose onUpdate ct_Iconography
function onInit()
    if super and super.onInit then
        super.onInit();
    end
    DB.addHandler(DB.getPath(label.getDatabaseNode()), 'onAdd', onUpdate);
    DB.addHandler(DB.getPath(label.getDatabaseNode()), 'onUpdate', onUpdate);
    onUpdate();
end

function onClose()
    if super and super.onClose then
        super.onClose();
    end
    DB.removeHandler(DB.getPath(label.getDatabaseNode()), 'onAdd', onUpdate);
    DB.removeHandler(DB.getPath(label.getDatabaseNode()), 'onUpdate', onUpdate);
end

function onUpdate()
    ct_Iconography.setIcon(IconographyManager.parseEffectLabelGetIcon(label.getValue()));
end
