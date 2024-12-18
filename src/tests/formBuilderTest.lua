-- -- Add the directory containing the formBuilder.lua file to package.path
-- package.path = package.path .. ";../common/utils/?.lua"

-- -- Import the formBuilder library
-- local formBuilder = require("formBuilder")
-- local basalt = require("basalt")

-- -- Attach Basalt to the monitor
-- local main = basalt.createFrame("main")
-- -- main:setBackground(colors.black)

-- -- Example configuration for the formBuilder
-- local testConfig = {
--     title = "Node Configuration",
--     pages = {
--         {
--             title = "Node Setup",
--             description = "Configure the node settings.",
--             components = {
--                 { label = "Node Name", type = "string" },
--                 { label = "Node Mode", type = "dropdown", options = { "Energy Monitor", "Unit Monitor" } }
--             }
--         },
--         {
--             title = "Energy Monitor Setup",
--             description = "Configure energy monitor specifics.",
--             components = {
--                 { label = "Energy Storage Name", type = "string" },
--                 { label = "Enable Redstone Control", type = "checkbox" },
--                 { label = "Set Threshold (5%)", type = "checkbox" },
--                 { label = "Set Threshold (95%)", type = "checkbox" }
--             }
--         }
--     }
-- }

-- -- Create and attach the form to the main frame
-- local form = formBuilder.createForm(testConfig)
-- form:setParent(main)

-- -- Start the Basalt main loop
-- basalt.autoUpdate()