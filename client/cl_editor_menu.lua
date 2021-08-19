menuStyle = {titleColor = {255, 255, 255}, subTitleColor = {255, 255, 255}, --[[titleBackgroundSprite = {dict = 'commonmenu', name = 'interaction_bgd'}]]}


justifyItems = {"Center", "Left", "Right"}

_comboBoxIndex = 1
WarMenu.CreateMenu('editor.ProjectMenu.main', 'drawEditorV', 'Select a project', menuStyle)

WarMenu.CreateMenu('editor.DrawsMenu.main', 'drawEditorV', 'Main Menu')
WarMenu.CreateSubMenu('editor.DrawsMenu.textEditor', 'editor.DrawsMenu.main', 'Edit Text')

AddEventHandler('drawEditorV:OpenProjectMenu', function()
    if not WarMenu.IsAnyMenuOpened() and view == 'project' then
        WarMenu.CloseMenu()
        WarMenu.OpenMenu('editor.ProjectMenu.main')
    end

    while true do
        if WarMenu.Begin('editor.ProjectMenu.main') then
            if project.name ~= 'unk' then
                WarMenu.Button('Continue Existing Project')
                if WarMenu.IsItemSelected() then
                    view = 'draws'
                    clearInstructionalButtons()
                    setInstructionalButtons(instButtonText[view])
                    WarMenu.CloseMenu()
                end
            end

            WarMenu.Button('Start New Project')
            if WarMenu.IsItemSelected() then
                AddTextEntry('EDI_NEW_PRJ', "Project name (will also be the file name): ")
                DisplayOnscreenKeyboard(1, "EDI_NEW_PRJ", "", "", "", "", "", 50)
                while (UpdateOnscreenKeyboard() == 0) do
                    DisableAllControlActions(0);
                    Wait(0);
                end
                if (GetOnscreenKeyboardResult()) then
                    if GetOnscreenKeyboardResult() ~= "" then
                        view = 'draws'
                        clearInstructionalButtons()
                        setInstructionalButtons(instButtonText[view])
                        editorStartNewProject(GetOnscreenKeyboardResult())
                        WarMenu.CloseMenu()
                        notify(GetOnscreenKeyboardResult().." project started!", 116)
                    else
                        notify('Please add a name.', 6)
                    end
                end
            end
            WarMenu.End()
        else
            return
        end
        Citizen.Wait(0)
    end
end)

AddEventHandler('drawEditorV:OpenDrawsMenu', function()
    if not WarMenu.IsAnyMenuOpened() and view == 'draws' then
        WarMenu.SetMenuTitle('editor.DrawsMenu.main', project.name)
        WarMenu.OpenMenu('editor.DrawsMenu.main')
    elseif not WarMenu.IsAnyMenuOpened() and view == 'drawEditor' then
        WarMenu.SetMenuTitle('editor.DrawsMenu.textEditor', project.draws[currentDraw].nick)
        WarMenu.OpenMenu('editor.DrawsMenu.textEditor')
    end

    while true do
        if WarMenu.Begin('editor.DrawsMenu.main') then
            for i,k in pairs(project.drawNicks) do
                WarMenu.Button('Edit "~y~'..k..'~s~" '..project.draws[k].type)
                if WarMenu.IsItemSelected() then
                    currentDraw = k
                    view = "drawEditor"
                    editedDraw = project.draws[currentDraw]
                    clearInstructionalButtons()
                    setInstructionalButtons(instButtonText[view])
                    WarMenu.CloseMenu()
                    WarMenu.OpenMenu('editor.DrawsMenu.textEditor')
                end
            end
            WarMenu.Button('Create new text draw')
            if WarMenu.IsItemSelected() then
                AddTextEntry('EDI_NEW_TXT', "Text nickname (NOT TEXT STRING / Will also be the function name): ")
                DisplayOnscreenKeyboard(1, "EDI_NEW_TXT", "", "", "", "", "", 50)
                while (UpdateOnscreenKeyboard() == 0) do
                    DisableAllControlActions(0);
                    Wait(0);
                end
                if (GetOnscreenKeyboardResult()) then
                    --view = 'draws'
                    --clearInstructionalButtons()
                    --setInstructionalButtons(instButtonText[view])
                    if project.draws[GetOnscreenKeyboardResult()] ~= nil then
                        notify('This nickname is already taken.', 6)
                    else
                        editorCreateNewTextDraw(GetOnscreenKeyboardResult())
                    end
                    --WarMenu.CloseMenu()
                end
            end
            WarMenu.Button('~g~Export Project.~s~')
            if WarMenu.IsItemSelected() then
                notify("can't do that now.", 6)
                TriggerServerEvent('drawEditorV:ExportProject', project)
                view = "project"
                WarMenu.CloseMenu()
            end
            WarMenu.Button('~r~Exit Project.~s~')
            if WarMenu.IsItemSelected() then
                view = "project"
                WarMenu.CloseMenu()
            end
            WarMenu.End()
        elseif WarMenu.Begin('editor.DrawsMenu.textEditor') then
            WarMenu.Button('Change Coords (Mouse)')
            if WarMenu.IsItemSelected() then
                editorView = 'changePos'
                clearInstructionalButtons()
                setInstructionalButtons(instButtonText['changePos'])
                WarMenu.CloseMenu()
            end

            WarMenu.Button('Change Size (Mouse)')
            if WarMenu.IsItemSelected() then
                editorView = 'changeSize'
                clearInstructionalButtons()
                setInstructionalButtons(instButtonText['changeSize'])
                WarMenu.CloseMenu()
            end

            WarMenu.Button('Change String')
            if WarMenu.IsItemSelected() then
                AddTextEntry('EDI_NEW_TXT', "Set String:")
                DisplayOnscreenKeyboard(1, "EDI_NEW_TXT", "", editedDraw.string, "", "", "", 50)
                while (UpdateOnscreenKeyboard() == 0) do
                    DisableAllControlActions(0);
                    Wait(0);
                end
                if (GetOnscreenKeyboardResult()) then
                    editedDraw.string = GetOnscreenKeyboardResult()
                end
            end

            local _, comboBoxIndex = WarMenu.ComboBox('Change Justification', justifyItems, _comboBoxIndex)
            if _comboBoxIndex ~= comboBoxIndex then
                _comboBoxIndex = comboBoxIndex
                editedDraw.justification = _comboBoxIndex - 1
            end
            if WarMenu.IsItemSelected() then
                AddTextEntry('EDI_NEW_TXT', "Set String:")
                DisplayOnscreenKeyboard(1, "EDI_NEW_TXT", "", editedDraw.string, "", "", "", 50)
                while (UpdateOnscreenKeyboard() == 0) do
                    DisableAllControlActions(0);
                    Wait(0);
                end
                if (GetOnscreenKeyboardResult()) then
                    editedDraw.string = GetOnscreenKeyboardResult()
                end
            end

            WarMenu.Button('Save')
            if WarMenu.IsItemSelected() then
                project.draws[currentDraw] = editedDraw
                currentDraw = 0
                editedDraw = {}
                clearInstructionalButtons()
                view = "draws"
                setInstructionalButtons(instButtonText[view])
                WarMenu.CloseMenu()
                WarMenu.OpenMenu('editor.DrawsMenu.main')
            end
            WarMenu.Button('Cancel')
            if WarMenu.IsItemSelected() then
                view = "draws"
                editedDraw = project.draws[currentDraw]
                currentDraw = 0
                clearInstructionalButtons()
                setInstructionalButtons(instButtonText[view])
                WarMenu.CloseMenu()
                WarMenu.OpenMenu('editor.DrawsMenu.main')
            end
            WarMenu.End()
        else
            return
        end
        Citizen.Wait(0)
    end
end)

function GetCursorPosition()
	if(true) then
		local cursorX, cursorY = GetControlNormal(0, 239), GetControlNormal(0, 240)
		return cursorX, cursorY
	end
end