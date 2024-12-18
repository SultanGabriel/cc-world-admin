-- Ensure first page is visible and main frame is attached
local basalt = require("basalt")

local formBuilder = {}

function formBuilder.createForm(configuration)
    local mainFrame = basalt.createFrame("main")
    mainFrame:setBackground(colors.black)

    -- Title bar
    local titleBar = mainFrame:addFrame("titleBar")
        :setSize("parent.w", 3)
        :setBackground(colors.blue)

    titleBar:addLabel()
        :setText(configuration.title or "Form Builder")
        :setPosition(2, 2)
        :setSize("parent.w-4", 1)
        :setAlignment("center")
        :setForeground(colors.white)

    local pages = {}
    local currentPage = 1

    -- Helper to create a page
    local function createPage(pageConfig)
        local page = mainFrame:addFlexbox("page" .. #pages + 1)
        page:setSize("parent.w", "parent.h-4")
        page:setPosition(1, 4)
        page:setBackground(colors.lightGray)
        page:setDirection("column")
        page:setSpacing(1)
        page:setJustifyContent("flex-start")
        page:setVisible(false)

        if pageConfig.title then
            page:addLabel()
                :setText(pageConfig.title)
                :setSize("parent.w-4", 1)
                :setAlignment("center")
                :setForeground(colors.black)
        end

        if pageConfig.description then
            page:addLabel()
                :setText(pageConfig.description)
                :setSize("parent.w-4", 2)
                :setAlignment("left")
                :setForeground(colors.gray)
        end

        pages[#pages + 1] = page
        return page
    end

    -- Add components to a page
    local function addComponent(page, componentConfig)
        local label = page:addLabel()
            :setText(componentConfig.label)
            :setSize(30, 1)
            :setForeground(colors.black)

        if componentConfig.type == "string" then
            page:addInput()
                :setSize(30, 1)
                :onChange(function(self, value)
                    componentConfig.value = value
                end)
        elseif componentConfig.type == "dropdown" then
            page:addDropdown()
                :setSize(30, 1)
                :setOptions(componentConfig.options)
                :onChange(function(self, value)
                    componentConfig.value = value
                end)
        elseif componentConfig.type == "checkbox" then
            page:addCheckbox()
                :setSize(30, 1)
                :onChange(function(self, checked)
                    componentConfig.value = checked
                end)
        else
            error("Unsupported component type: " .. componentConfig.type)
        end
    end

    -- Generate pages
    for _, pageConfig in ipairs(configuration.pages) do
        local page = createPage(pageConfig)
        for _, componentConfig in ipairs(pageConfig.components) do
            addComponent(page, componentConfig)
        end
    end

    -- Set visibility for the first page
    pages[1]:setVisible(true)

    -- Add navigation buttons
    mainFrame:addButton("Next")
        :setPosition("parent.w-12", "parent.h-1")
        :setSize(10, 1)
        :setText("Next")
        :onClick(function()
            if currentPage < #pages then
                pages[currentPage]:setVisible(false)
                currentPage = currentPage + 1
                pages[currentPage]:setVisible(true)
            end
        end)

    mainFrame:addButton("Back")
        :setPosition(2, "parent.h-1")
        :setSize(10, 1)
        :setText("Back")
        :onClick(function()
            if currentPage > 1 then
                pages[currentPage]:setVisible(false)
                currentPage = currentPage - 1
                pages[currentPage]:setVisible(true)
            end
        end)

    return mainFrame
end

return formBuilder
