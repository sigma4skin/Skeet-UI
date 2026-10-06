local cloneref = cloneref or function(o) return o end
local gethui = gethui or function() return game:GetService("CoreGui") end

local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local Stats = cloneref(game:GetService("Stats"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local keys = {
	[Enum.KeyCode.LeftShift] = "LSHF",
	[Enum.KeyCode.RightShift] = "RSHF",
	[Enum.KeyCode.LeftControl] = "LCTRL",
	[Enum.KeyCode.RightControl] = "RCTRL",
	[Enum.KeyCode.Insert] = "INS",
	[Enum.KeyCode.Backspace] = "BS",
	[Enum.KeyCode.Return] = "Ent",
	[Enum.KeyCode.LeftAlt] = "LALT",
	[Enum.KeyCode.RightAlt] = "RALT",
	[Enum.KeyCode.CapsLock] = "CAPS",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.KeypadOne] = "Num1",
	[Enum.KeyCode.KeypadTwo] = "Num2",
	[Enum.KeyCode.KeypadThree] = "Num3",
	[Enum.KeyCode.KeypadFour] = "Num4",
	[Enum.KeyCode.KeypadFive] = "Num5",
	[Enum.KeyCode.KeypadSix] = "Num6",
	[Enum.KeyCode.KeypadSeven] = "Num7",
	[Enum.KeyCode.KeypadEight] = "Num8",
	[Enum.KeyCode.KeypadNine] = "Num9",
	[Enum.KeyCode.KeypadZero] = "Num0",
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Tilde] = "~",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.RightParenthesis] = ")",
	[Enum.KeyCode.LeftParenthesis] = "(",
	[Enum.KeyCode.Semicolon] = ";",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.Asterisk] = "*",
	[Enum.KeyCode.Plus] = "+",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Backquote] = "`",
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
	[Enum.KeyCode.Escape] = "ESC",
	[Enum.KeyCode.Space] = "SPC",
}

local fonts = {}; do
    function Register_Font(Name, Weight, Style, Asset)
        if not isfile(Asset.Id) then writefile(Asset.Id, Asset.Font) end
        if isfile(Name .. ".font") then delfile(Name .. ".font") end
        local Data = { name = Name, faces = {{ name = "Normal", weight = Weight, style = Style, assetId = getcustomasset(Asset.Id) }} }
        writefile(Name .. ".font", HttpService:JSONEncode(Data))
        return getcustomasset(Name .. ".font");
    end

    local SilkscreenAsset = Register_Font("Silkscreen", 400, "Normal", {
        Id = "slkscr.ttf",
        Font = game:HttpGet("https://github.com/joshistuff67/storage/raw/main/fonts/slkscr.ttf")
    })

    fonts = {
        font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        fontBold = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        fontkb = Font.new(SilkscreenAsset, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    }
end



local Library = {
    Tabs = {},
    Font = fonts.font,
    FontBold = fonts.fontBold,
    FontKeybind = fonts.fontkb,

    Flags = {},
    FolderName = "CatSense",
    AutoloadConfig = nil,

    MainColor = Color3.fromRGB(23, 23, 23),
    OutlineColor = Color3.fromRGB(50, 50, 50),

    TextColor = Color3.fromRGB(192, 192, 192),
    DimTextColor = Color3.fromRGB(192, 192, 192),

    AccentColor = Color3.fromRGB(153, 225, 1),
    AccentDarkColor = Color3.fromRGB(110, 160, 0),

    ToggleOffColor = Color3.fromHex("#434343"),
    SectionColor = Color3.fromHex("#171717"),
    SectionBorder = Color3.fromHex("#2c2c2c"),

    MaxSectionHeight = 30,
    AnimationEase = Enum.EasingStyle.Quint,
    AnimationSpeed = 0.25,
    ActivePicker = nil,
    ActiveDropdown = nil,

    NotifySettings = {
        Anchor = "Center",
        OffsetX = 0,
        OffsetY = 35,
        Duration = 4
    },

    Registry = { AccentFills = {}, AccentTexts = {}, Toggles = {} },
    Keybinds = {},
    ActiveKeybinds = {}
}

if not isfolder(Library.FolderName) then makefolder(Library.FolderName) end

function Library:SaveConfig(name)
    if not name or name == "" then return end
    local json = HttpService:JSONEncode(Library.Flags)
    writefile(Library.FolderName .. "/" .. name .. ".json", json)
end

function Library:SetAutoload(name)
    if not name or name == "" then return end
    local autoloadFile = Library.FolderName .. "/autoload.txt"
    writefile(autoloadFile, name)
    Library.AutoloadConfig = name
end

function Library:RemoveAutoload()
    local autoloadFile = Library.FolderName .. "/autoload.txt"
    if isfile(autoloadFile) then
        delfile(autoloadFile)
    end
    Library.AutoloadConfig = nil
end

function Library:GetAutoload()
    local autoloadFile = Library.FolderName .. "/autoload.txt"
    if isfile(autoloadFile) then
        return readfile(autoloadFile)
    end
    return nil
end

function Library:LoadConfig(name)
    local file = Library.FolderName .. "/" .. name .. ".json"
    if isfile(file) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
        if success and decoded then
            for flag, value in pairs(decoded) do
                Library.Flags[flag] = value
                if Library.Registry[flag] then Library.Registry[flag].Set(value) end
            end
        end
    end
end

function Library:DeleteConfig(name)
    local file = Library.FolderName .. "/" .. name .. ".json"
    if isfile(file) then delfile(file) end
end

function Library:GetConfigs()
    local files = listfiles(Library.FolderName)
    local names = {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            local name = file:match("([^\\/]+)%.json$")
            table.insert(names, name)
        end
    end
    return names
end

function Library:ImportConfig(str)
    local success, decoded = pcall(function() return HttpService:JSONDecode(str) end)
    if success and decoded then
        for flag, value in pairs(decoded) do
            Library.Flags[flag] = value
            if Library.Registry[flag] then Library.Registry[flag].Set(value) end
        end
    end
end

function Library:ExportConfig() return HttpService:JSONEncode(Library.Flags) end

local function ApplyGradient(instance, cTop, cBot)
    local gradient = instance:FindFirstChild("MainGradient") or Instance.new("UIGradient")
    gradient.Name = "MainGradient"
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, cTop),
        ColorSequenceKeypoint.new(1.00, cBot)
    }
    gradient.Parent = instance
    return gradient
end

function Library:Confirm(Config)
    local Title = Config.Title or "Confirm"
    local Message = Config.Message or "Are you sure?"
    local ConfirmText = Config.ConfirmText or "Yes"
    local CancelText = Config.CancelText or "No"
    local Callback = Config.Callback or function() end

    local Modal = Instance.new("Frame")
    Modal.Name = "ConfirmModal"
    Modal.Parent = gethui()
    Modal.BackgroundTransparency = 1
    Modal.BorderSizePixel = 0
    Modal.Size = UDim2.new(1, 0, 1, 0)
    Modal.ZIndex = 4000

    local Dialog = Instance.new("Frame")
    Dialog.Name = "Dialog"
    Dialog.Parent = Modal
    Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    Dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    Dialog.Size = UDim2.new(0, 350, 0, 150)
    Dialog.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    Dialog.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Dialog.BorderSizePixel = 1
    Dialog.ZIndex = 4001

    local DialogStroke = Instance.new("UIStroke", Dialog)
    DialogStroke.Color = Color3.fromRGB(89, 89, 89)
    DialogStroke.Thickness = 1

    local TitleBar = Instance.new("Frame", Dialog)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 4002

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.FontFace = Library.FontBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 4003

    local MessageLabel = Instance.new("TextLabel", Dialog)
    MessageLabel.Size = UDim2.new(1, -40, 0, 60)
    MessageLabel.Position = UDim2.new(0, 20, 0, 40)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MessageLabel.FontFace = Library.Font
    MessageLabel.TextSize = 13
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.ZIndex = 4003

    local ButtonContainer = Instance.new("Frame", Dialog)
    ButtonContainer.Size = UDim2.new(1, -40, 0, 30)
    ButtonContainer.Position = UDim2.new(0, 20, 1, -40)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 4003

    local CancelBtn = Instance.new("TextButton", ButtonContainer)
    CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
    CancelBtn.Position = UDim2.new(0, 0, 0, 0)
    CancelBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CancelBtn.BorderSizePixel = 0
    CancelBtn.Text = ""
    CancelBtn.AutoButtonColor = false
    CancelBtn.ZIndex = 4004

    ApplyGradient(CancelBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local CancelStroke = Instance.new("UIStroke", CancelBtn)
    CancelStroke.Color = Color3.new(0, 0, 0)
    CancelStroke.Thickness = 1

    local CancelInline = Instance.new("Frame", CancelBtn)
    CancelInline.BackgroundTransparency = 1
    CancelInline.Size = UDim2.new(1, -2, 1, -2)
    CancelInline.Position = UDim2.new(0, 1, 0, 1)
    CancelInline.ZIndex = 4005
    local CancelInlineStroke = Instance.new("UIStroke", CancelInline)
    CancelInlineStroke.Color = Color3.fromHex("#323232")
    CancelInlineStroke.Thickness = 1

    local CancelLabel = Instance.new("TextLabel", CancelBtn)
    CancelLabel.Size = UDim2.new(1, 0, 1, 0)
    CancelLabel.BackgroundTransparency = 1
    CancelLabel.Text = CancelText
    CancelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    CancelLabel.FontFace = Library.FontBold
    CancelLabel.TextSize = 13
    CancelLabel.ZIndex = 4006

    local ConfirmBtn = Instance.new("TextButton", ButtonContainer)
    ConfirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
    ConfirmBtn.Position = UDim2.new(0.52, 0, 0, 0)
    ConfirmBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmBtn.BorderSizePixel = 0
    ConfirmBtn.Text = ""
    ConfirmBtn.AutoButtonColor = false
    ConfirmBtn.ZIndex = 4004

    ApplyGradient(ConfirmBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local ConfirmStroke = Instance.new("UIStroke", ConfirmBtn)
    ConfirmStroke.Color = Color3.new(0, 0, 0)
    ConfirmStroke.Thickness = 1

    local ConfirmInline = Instance.new("Frame", ConfirmBtn)
    ConfirmInline.BackgroundTransparency = 1
    ConfirmInline.Size = UDim2.new(1, -2, 1, -2)
    ConfirmInline.Position = UDim2.new(0, 1, 0, 1)
    ConfirmInline.ZIndex = 4005
    local ConfirmInlineStroke = Instance.new("UIStroke", ConfirmInline)
    ConfirmInlineStroke.Color = Color3.fromHex("#323232")
    ConfirmInlineStroke.Thickness = 1

    local ConfirmLabel = Instance.new("TextLabel", ConfirmBtn)
    ConfirmLabel.Size = UDim2.new(1, 0, 1, 0)
    ConfirmLabel.BackgroundTransparency = 1
    ConfirmLabel.Text = ConfirmText
    ConfirmLabel.TextColor3 = Library.AccentColor
    ConfirmLabel.FontFace = Library.FontBold
    ConfirmLabel.TextSize = 13
    ConfirmLabel.ZIndex = 4006

    CancelBtn.MouseEnter:Connect(function()
        ApplyGradient(CancelBtn, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)
    CancelBtn.MouseLeave:Connect(function()
        ApplyGradient(CancelBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))
    end)

    ConfirmBtn.MouseEnter:Connect(function()
        ApplyGradient(ConfirmBtn, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)
    ConfirmBtn.MouseLeave:Connect(function()
        ApplyGradient(ConfirmBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))
    end)

    CancelBtn.MouseButton1Click:Connect(function()
        Modal:Destroy()
        Callback(false)
    end)

    ConfirmBtn.MouseButton1Click:Connect(function()
        Modal:Destroy()
        Callback(true)
    end)

    Modal.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Modal:Destroy()
            Callback(false)
        end
    end)
end


function Library:UpdateAccent(newColor)
    self.AccentColor = newColor
    local h, s, v = newColor:ToHSV()
    self.AccentDarkColor = Color3.fromHSV(h, s, math.clamp(v * 0.8, 0, 1))

    for _, obj in pairs(self.Registry.AccentFills) do
        if obj then
            if type(obj) == "table" and obj.Update then
                obj.Update()
            elseif obj.Parent then
                obj.BackgroundColor3 = self.AccentColor
            end
        end
    end

    for _, obj in pairs(self.Registry.AccentTexts) do
        if obj and obj.Parent then obj.TextColor3 = self.AccentColor end
    end

    for _, toggle in pairs(self.Registry.Toggles) do
        if toggle.Box then
            local isEnabled = toggle.GetValue and toggle.GetValue() or toggle.State
            if isEnabled then
                toggle.Box.BackgroundColor3 = self.AccentColor
                local h, s, v = self.AccentColor:ToHSV()
                local cTop = self.AccentColor
                local cBot = Color3.fromHSV(h, s, math.clamp(v * 0.8, 0, 1))
                ApplyGradient(toggle.Box, cTop, cBot)
            end
        end
    end
end

local function CreateShadowedLabel(props)
    local parent = props.Parent

    local shadow = Instance.new("TextLabel")
    shadow.Name = "Shadow"
    shadow.Text = props.Text
    shadow.FontFace = Library.Font
    shadow.TextSize = props.TextSize or 11
    shadow.TextColor3 = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 1
    shadow.Position = props.Position + UDim2.fromOffset(1, 1)
    shadow.Size = props.Size
    shadow.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    shadow.ZIndex = (props.ZIndex or 1) - 1
    shadow.Parent = parent

    local main = Instance.new("TextLabel")
    main.Name = "Label"
    main.Text = props.Text
    main.FontFace = Library.Font
    main.TextSize = props.TextSize or 11
    main.TextColor3 = props.TextColor3 or Color3.new(1, 1, 1)
    main.BackgroundTransparency = 1
    main.Position = props.Position
    main.Size = props.Size
    main.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    main.ZIndex = props.ZIndex or 1
    main.Parent = parent

    return main, shadow
end

local success, targetParent = pcall(function() return gethui() end)
if not success then success, targetParent = pcall(function() return cloneref(game:GetService("CoreGui")) end) end
if not success then targetParent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local skeet = Instance.new("ScreenGui")
skeet.Name = "skeet"
skeet.Parent = targetParent
skeet.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
skeet.ResetOnSpawn = false

function Library:Confirm(Config)
    local Title = Config.Title or "Confirm"
    local Message = Config.Message or "Are you sure?"
    local ConfirmText = Config.ConfirmText or "Yes"
    local CancelText = Config.CancelText or "No"
    local Callback = Config.Callback or function() end

    local Modal = Instance.new("TextButton")
    Modal.Name = "ConfirmModal"
    Modal.Parent = gethui()
    Modal.BackgroundTransparency = 1
    Modal.BorderSizePixel = 0
    Modal.Size = UDim2.new(1, 0, 1, 0)
    Modal.Text = ""
    Modal.AutoButtonColor = false
    Modal.ZIndex = 4000

    local Dialog = Instance.new("Frame")
    Dialog.Name = "Dialog"
    Dialog.Parent = Modal
    Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    Dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    Dialog.Size = UDim2.new(0, 400, 0, 160)
    Dialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Dialog.BorderColor3 = Color3.fromRGB(18, 18, 18)
    Dialog.BorderSizePixel = 2
    Dialog.ZIndex = 4001
    Dialog.Active = true

    local dragging = false
    local dragStart = nil
    local startPos = nil

    Dialog.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Dialog.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Dialog.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Dialog.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local DialogStroke = Instance.new("UIStroke", Dialog)
    DialogStroke.Color = Color3.fromRGB(89, 89, 89)
    DialogStroke.Thickness = 1.3
    DialogStroke.LineJoinMode = Enum.LineJoinMode.Round

    local InnerFrame = Instance.new("Frame", Dialog)
    InnerFrame.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    InnerFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    InnerFrame.Position = UDim2.new(0, 5, 0, 5)
    InnerFrame.Size = UDim2.new(1, -10, 1, -10)
    InnerFrame.ZIndex = 4002

    local backgroundPattern = Instance.new("ImageLabel", InnerFrame)
    backgroundPattern.BackgroundTransparency = 1
    backgroundPattern.Size = UDim2.new(1, 0, 1, 0)
    backgroundPattern.Image = "rbxassetid://8547666218"
    backgroundPattern.ImageColor3 = Color3.fromRGB(12, 12, 12)
    backgroundPattern.ScaleType = Enum.ScaleType.Tile
    backgroundPattern.TileSize = UDim2.new(0, 8, 0, 8)
    backgroundPattern.ZIndex = 4003

    local topGradientFrame = Instance.new("Frame", InnerFrame)
    topGradientFrame.Name = "TopGradient"
    topGradientFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    topGradientFrame.BackgroundTransparency = 0
    topGradientFrame.BorderSizePixel = 0
    topGradientFrame.Position = UDim2.new(0, 1, 0, 0)
    topGradientFrame.Size = UDim2.new(1, -3, 0, 2)
    topGradientFrame.ZIndex = 4010

    local gradientImage = Instance.new("ImageLabel", topGradientFrame)
    gradientImage.Name = "gradient"
    gradientImage.BackgroundTransparency = 1
    gradientImage.BorderSizePixel = 0
    gradientImage.Position = UDim2.new(0, 0, 0, 1)
    gradientImage.Size = UDim2.new(1, 0, 1, 0)
    gradientImage.Image = "rbxassetid://8508019876"
    gradientImage.ScaleType = Enum.ScaleType.Stretch
    gradientImage.ZIndex = 4010

    local glow = Instance.new("Frame", InnerFrame)
    glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.Position = UDim2.new(0, 0, 0, 4)
    glow.Size = UDim2.new(1, 0, 0, 1)
    glow.ZIndex = 4011


    local TitleLabel, TitleShadow = CreateShadowedLabel({
        Parent = InnerFrame,
        Text = Title,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 20),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        ZIndex = 4012
    })
    TitleLabel.FontFace = Library.FontBold
    TitleShadow.FontFace = Library.FontBold

    local MessageLabel = Instance.new("TextLabel", InnerFrame)
    MessageLabel.Size = UDim2.new(1, -40, 0, 50)
    MessageLabel.Position = UDim2.new(0, 20, 0, 32)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = Library.DimTextColor
    MessageLabel.FontFace = Library.Font
    MessageLabel.TextSize = 15
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Center
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Center
    MessageLabel.ZIndex = 4012

    local ButtonContainer = Instance.new("Frame", InnerFrame)
    ButtonContainer.Size = UDim2.new(1, -40, 0, 30)
    ButtonContainer.Position = UDim2.new(0, 20, 1, -40)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 4012

    local CancelBtn = Instance.new("TextButton", ButtonContainer)
    CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
    CancelBtn.Position = UDim2.new(0, 0, 0, 0)
    CancelBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CancelBtn.BorderSizePixel = 0
    CancelBtn.Text = ""
    CancelBtn.AutoButtonColor = false
    CancelBtn.ZIndex = 4013

    ApplyGradient(CancelBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local CancelStroke = Instance.new("UIStroke", CancelBtn)
    CancelStroke.Color = Color3.new(0, 0, 0)
    CancelStroke.Thickness = 1
    CancelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local CancelInline = Instance.new("Frame", CancelBtn)
    CancelInline.BackgroundTransparency = 1
    CancelInline.Size = UDim2.new(1, -2, 1, -2)
    CancelInline.Position = UDim2.new(0, 1, 0, 1)
    CancelInline.ZIndex = 4014
    local CancelInlineStroke = Instance.new("UIStroke", CancelInline)
    CancelInlineStroke.Color = Color3.fromHex("#323232")
    CancelInlineStroke.Thickness = 1

    local CancelLabel = Instance.new("TextLabel", CancelBtn)
    CancelLabel.Size = UDim2.new(1, 0, 1, 0)
    CancelLabel.Position = UDim2.new(0, 0, 0, -1)
    CancelLabel.BackgroundTransparency = 1
    CancelLabel.Text = CancelText
    CancelLabel.TextColor3 = Color3.fromHex("#d0d0d0")
    CancelLabel.FontFace = Library.FontBold
    CancelLabel.TextSize = 13
    CancelLabel.ZIndex = 4015

    local ConfirmBtn = Instance.new("TextButton", ButtonContainer)
    ConfirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
    ConfirmBtn.Position = UDim2.new(0.52, 0, 0, 0)
    ConfirmBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmBtn.BorderSizePixel = 0
    ConfirmBtn.Text = ""
    ConfirmBtn.AutoButtonColor = false
    ConfirmBtn.ZIndex = 4013

    ApplyGradient(ConfirmBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local ConfirmStroke = Instance.new("UIStroke", ConfirmBtn)
    ConfirmStroke.Color = Color3.new(0, 0, 0)
    ConfirmStroke.Thickness = 1
    ConfirmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ConfirmInline = Instance.new("Frame", ConfirmBtn)
    ConfirmInline.BackgroundTransparency = 1
    ConfirmInline.Size = UDim2.new(1, -2, 1, -2)
    ConfirmInline.Position = UDim2.new(0, 1, 0, 1)
    ConfirmInline.ZIndex = 4014
    local ConfirmInlineStroke = Instance.new("UIStroke", ConfirmInline)
    ConfirmInlineStroke.Color = Color3.fromHex("#323232")
    ConfirmInlineStroke.Thickness = 1

    local ConfirmLabel = Instance.new("TextLabel", ConfirmBtn)
    ConfirmLabel.Size = UDim2.new(1, 0, 1, 0)
    ConfirmLabel.Position = UDim2.new(0, 0, 0, -1)
    ConfirmLabel.BackgroundTransparency = 1
    ConfirmLabel.Text = ConfirmText
    ConfirmLabel.TextColor3 = Library.AccentColor
    ConfirmLabel.FontFace = Library.FontBold
    ConfirmLabel.TextSize = 13
    ConfirmLabel.ZIndex = 4015

    CancelBtn.MouseEnter:Connect(function()
        ApplyGradient(CancelBtn, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
        CancelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    CancelBtn.MouseLeave:Connect(function()
        ApplyGradient(CancelBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))
        CancelLabel.TextColor3 = Color3.fromRGB(205, 205, 205)
    end)
    CancelBtn.MouseButton1Down:Connect(function()
        ApplyGradient(CancelBtn, Color3.fromRGB(27, 27, 27), Color3.fromRGB(33, 33, 33))
    end)
    CancelBtn.MouseButton1Up:Connect(function()
        ApplyGradient(CancelBtn, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)

    ConfirmBtn.MouseEnter:Connect(function()
        ApplyGradient(ConfirmBtn, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)
    ConfirmBtn.MouseLeave:Connect(function()
        ApplyGradient(ConfirmBtn, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))
    end)
    ConfirmBtn.MouseButton1Down:Connect(function()
        ApplyGradient(ConfirmBtn, Color3.fromRGB(27, 27, 27), Color3.fromRGB(33, 33, 33))
    end)
    ConfirmBtn.MouseButton1Up:Connect(function()
        ApplyGradient(ConfirmBtn, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)

    CancelBtn.MouseButton1Click:Connect(function()
        Modal:Destroy()
        Callback(false)
    end)

    ConfirmBtn.MouseButton1Click:Connect(function()
        Modal:Destroy()
        Callback(true)
    end)

    Modal.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local dialogPos = Dialog.AbsolutePosition
            local dialogSize = Dialog.AbsoluteSize

            if mousePos.X < dialogPos.X or mousePos.X > dialogPos.X + dialogSize.X or
               mousePos.Y < dialogPos.Y or mousePos.Y > dialogPos.Y + dialogSize.Y then
                Modal:Destroy()
                Callback(false)
            end
        end
    end)
end

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "Notifications"
NotificationHolder.Parent = skeet
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.ZIndex = 3000
NotificationHolder.AnchorPoint = Vector2.new(0.5, 0)
NotificationHolder.Position = UDim2.new(0.5, 0, 0, 35)
NotificationHolder.Size = UDim2.new(0, 200, 1, 0)

local NotifyLayout = Instance.new("UIListLayout", NotificationHolder)
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.Padding = UDim.new(0, 5)
NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local DropdownHolder = Instance.new("Folder", skeet)
DropdownHolder.Name = "Dropdowns"

local ColorPickerFrame = Instance.new("Frame")
ColorPickerFrame.Name = "ColorPicker"
ColorPickerFrame.Parent = skeet
ColorPickerFrame.Size = UDim2.fromOffset(200, 258)
ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ColorPickerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
ColorPickerFrame.BorderSizePixel = 1
ColorPickerFrame.Visible = false
ColorPickerFrame.ZIndex = 1000

local ColorPickerTitle = Instance.new("TextButton", ColorPickerFrame)
ColorPickerTitle.Name = "Title"
ColorPickerTitle.Size = UDim2.new(1, 0, 0, 25)
ColorPickerTitle.Position = UDim2.new(0, 0, 0, 0)
ColorPickerTitle.BackgroundTransparency = 1
ColorPickerTitle.Text = "Color Picker"
ColorPickerTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
ColorPickerTitle.FontFace = fonts.fontBold
ColorPickerTitle.TextSize = 13
ColorPickerTitle.AutoButtonColor = false
ColorPickerTitle.ZIndex = 1005

local PickerInline = Instance.new("Frame", ColorPickerFrame)
PickerInline.Size = UDim2.new(1, -2, 1, -27)
PickerInline.Position = UDim2.new(0, 1, 0, 25)
PickerInline.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PickerInline.BorderSizePixel = 0
PickerInline.ZIndex = 1000

local SVMap = Instance.new("ImageButton", PickerInline)
SVMap.Name = "SVMap"
SVMap.Size = UDim2.new(1, -30, 1, -30)
SVMap.Position = UDim2.fromOffset(5, 5)
SVMap.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SVMap.BorderSizePixel = 1
SVMap.BorderColor3 = Color3.new(0,0,0)
SVMap.ZIndex = 1001
SVMap.AutoButtonColor = false
SVMap.Image = "rbxassetid://4155801252"

local HueBar = Instance.new("ImageButton", PickerInline)
HueBar.Name = "HueBar"
HueBar.Size = UDim2.new(0, 15, 1, -10)
HueBar.Position = UDim2.new(1, -20, 0, 5)
HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HueBar.BorderSizePixel = 1
HueBar.BorderColor3 = Color3.new(0,0,0)
HueBar.ZIndex = 1001
HueBar.AutoButtonColor = false
local HueGradient = Instance.new("UIGradient", HueBar)
HueGradient.Rotation = 90
HueGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})

local AlphaBg = Instance.new("Frame", PickerInline)
AlphaBg.Name = "AlphaBg"
AlphaBg.Size = UDim2.new(1, -30, 0, 15)
AlphaBg.Position = UDim2.new(0, 5, 1, -20)
AlphaBg.BackgroundColor3 = Color3.new(0,0,0)
AlphaBg.BorderSizePixel = 1
AlphaBg.BorderColor3 = Color3.new(0,0,0)
AlphaBg.ZIndex = 1001

local AlphaBar = Instance.new("ImageButton", AlphaBg)
AlphaBar.Name = "AlphaBar"
AlphaBar.Size = UDim2.new(1, 0, 1, 0)
AlphaBar.BackgroundTransparency = 0
AlphaBar.BackgroundColor3 = Color3.new(1,1,1)
AlphaBar.BorderSizePixel = 0
AlphaBar.ZIndex = 1002
AlphaBar.AutoButtonColor = false

local AlphaGradient = Instance.new("UIGradient", AlphaBar)
AlphaGradient.Transparency = NumberSequence.new(0, 1)

local PickerCursor = Instance.new("Frame", SVMap)
PickerCursor.Size = UDim2.fromOffset(4, 4)
PickerCursor.AnchorPoint = Vector2.new(0.5, 0.5)
PickerCursor.BackgroundColor3 = Color3.new(1,1,1)
PickerCursor.BorderColor3 = Color3.new(0,0,0)
PickerCursor.ZIndex = 1003

local HueCursor = Instance.new("Frame", HueBar)
HueCursor.Size = UDim2.new(1, 0, 0, 2)
HueCursor.BackgroundColor3 = Color3.new(1,1,1)
HueCursor.BorderSizePixel = 0
HueCursor.ZIndex = 1003

local AlphaCursor = Instance.new("Frame", AlphaBar)
AlphaCursor.Size = UDim2.new(0, 2, 1, 0)
AlphaCursor.BackgroundColor3 = Color3.new(1,1,1)
AlphaCursor.BorderSizePixel = 0
AlphaCursor.ZIndex = 1003
local HexInput = Instance.new("TextBox", PickerInline)
HexInput.Name = "HexInput"
HexInput.Size = UDim2.new(1, -10, 0, 18)
HexInput.Position = UDim2.new(0, 5, 1, -23)
HexInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HexInput.BorderColor3 = Color3.new(0, 0, 0)
HexInput.BorderSizePixel = 1
HexInput.Text = ""
HexInput.PlaceholderText = "Input hex code..."
HexInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
HexInput.TextColor3 = Color3.fromRGB(200, 200, 200)
HexInput.FontFace = Library.Font
HexInput.TextSize = 12
HexInput.ZIndex = 1001
HexInput.ClearTextOnFocus = false

local ClickCloser = Instance.new("TextButton", skeet)
ClickCloser.Size = UDim2.new(1,0,1,0)
ClickCloser.BackgroundTransparency = 1
ClickCloser.Text = ""
ClickCloser.Visible = false
ClickCloser.ZIndex = 999

local ContextMenu = Instance.new("Frame")
ContextMenu.Name = "ContextMenu"
ContextMenu.Parent = skeet
ContextMenu.Size = UDim2.fromOffset(110, 0)
ContextMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContextMenu.BorderColor3 = Color3.new(0,0,0)
ContextMenu.BorderSizePixel = 1
ContextMenu.Visible = false
ContextMenu.AutomaticSize = Enum.AutomaticSize.Y
ContextMenu.ZIndex = 3000

local ContextOutline = Instance.new("UIStroke", ContextMenu)
ContextOutline.Color = Color3.new(0,0,0)
ContextOutline.Thickness = 1
ContextOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local ContextInline = Instance.new("Frame", ContextMenu)
ContextInline.Name = "Inline"
ContextInline.BackgroundTransparency = 1
ContextInline.Size = UDim2.new(1, -2, 1, -2)
ContextInline.Position = UDim2.new(0, 1, 0, 1)
ContextInline.ZIndex = 3001
local ContextInlineStroke = Instance.new("UIStroke", ContextInline)
ContextInlineStroke.Color = Color3.fromHex("#323232")
ContextInlineStroke.Thickness = 1

local ButtonHolder = Instance.new("Frame", ContextMenu)
ButtonHolder.Name = "Holder"
ButtonHolder.BackgroundTransparency = 1
ButtonHolder.Size = UDim2.new(1, 0, 0, 0)
ButtonHolder.AutomaticSize = Enum.AutomaticSize.Y
ButtonHolder.ZIndex = 3002

local ContextLayout = Instance.new("UIListLayout", ButtonHolder)
ContextLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContextLayout.Padding = UDim.new(0, 0)

local function OpenKeybindMenu(currentMode, callback)
    local mouse = UserInputService:GetMouseLocation()
    local inset = game:GetService("GuiService"):GetGuiInset()
    ContextMenu.Position = UDim2.fromOffset(mouse.X + 5, mouse.Y - inset.Y + 5)

    ContextMenu.Visible = true
    ClickCloser.Visible = true

    for _, c in pairs(ButtonHolder:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local modes = {"Always On", "Toggle", "Hold"}

    for _, mode in ipairs(modes) do
        local btn = Instance.new("TextButton", ButtonHolder)
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 3003

        local lbl = Instance.new("TextLabel", btn)
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -10, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Text = mode
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextSize = 13
        lbl.ZIndex = 3004

        local isHovered = false

        local function UpdateVisuals()
            local isSelected = (mode == currentMode)

            if isSelected then
                lbl.TextColor3 = Library.AccentColor
                lbl.FontFace = Library.FontBold
            elseif isHovered then
                lbl.TextColor3 = Library.TextColor
                lbl.FontFace = Library.FontBold
            else
                lbl.TextColor3 = Library.DimTextColor
                lbl.FontFace = Library.Font
            end

            if isHovered then
                btn.BackgroundTransparency = 0
                btn.BackgroundColor3 = Color3.fromHex("#181818")
            else
                btn.BackgroundTransparency = 1
            end
        end

        UpdateVisuals()

        btn.MouseEnter:Connect(function() isHovered = true; UpdateVisuals() end)
        btn.MouseLeave:Connect(function() isHovered = false; UpdateVisuals() end)

        btn.MouseButton1Click:Connect(function()
            callback(mode)
            ContextMenu.Visible = false
            ClickCloser.Visible = false
        end)
    end
end

local CurrentColorCallback = nil
local CurrentHSV = {H = 0, S = 1, V = 1, A = 0}
local DraggingSV, DraggingHue, DraggingAlpha = false, false, false
local CopiedColor = nil

local function UpdateColor()
    local color = Color3.fromHSV(CurrentHSV.H, CurrentHSV.S, CurrentHSV.V)
    SVMap.BackgroundColor3 = Color3.fromHSV(CurrentHSV.H, 1, 1)

    AlphaGradient.Color = ColorSequence.new(color)

    if CurrentColorCallback then CurrentColorCallback(color, 1 - CurrentHSV.A) end

    PickerCursor.BackgroundColor3 = color
    HueCursor.BackgroundColor3 = Color3.fromHSV(CurrentHSV.H, 1, 1)
    local hex = string.format("#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
    HexInput.Text = hex

    PickerCursor.Size = UDim2.fromOffset(4, 4)

    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    TweenService:Create(HueCursor, tweenInfo, {
        Position = UDim2.new(0, 0, CurrentHSV.H, 0)
    }):Play()

    TweenService:Create(PickerCursor, tweenInfo, {
        Position = UDim2.new(CurrentHSV.S, 0, 1 - CurrentHSV.V, 0)
    }):Play()

    TweenService:Create(AlphaCursor, tweenInfo, {
        Position = UDim2.new(CurrentHSV.A, 0, 0, 0)
    }):Play()
end

ClickCloser.MouseButton1Click:Connect(function()
    ColorPickerFrame.Visible = false
    ContextMenu.Visible = false
    PlayerMenu.Visible = false
    ClickCloser.Visible = false
    if Library.ActiveDropdown then
        Library.ActiveDropdown.Visible = false
        Library.ActiveDropdown = nil
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if DraggingSV then
            local size = SVMap.AbsoluteSize; local pos = SVMap.AbsolutePosition
            CurrentHSV.S = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            CurrentHSV.V = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
            UpdateColor()
        elseif DraggingHue then
            local size = HueBar.AbsoluteSize; local pos = HueBar.AbsolutePosition
            CurrentHSV.H = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
            UpdateColor()
        elseif DraggingAlpha then
            local size = AlphaBar.AbsoluteSize; local pos = AlphaBar.AbsolutePosition
            CurrentHSV.A = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            UpdateColor()
        end
    end
end)

SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingSV = true; local size = SVMap.AbsoluteSize; local pos = SVMap.AbsolutePosition; CurrentHSV.S = math.clamp((input.Position.X - pos.X) / size.X, 0, 1); CurrentHSV.V = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1); UpdateColor(); input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then DraggingSV = false end end) end end)
HueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingHue = true; local size = HueBar.AbsoluteSize; local pos = HueBar.AbsolutePosition; CurrentHSV.H = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1); UpdateColor(); input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then DraggingHue = false end end) end end)
AlphaBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingAlpha = true; local size = AlphaBar.AbsoluteSize; local pos = AlphaBar.AbsolutePosition; CurrentHSV.A = math.clamp((input.Position.X - pos.X) / size.X, 0, 1); UpdateColor(); input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then DraggingAlpha = false end end) end end)

local function OpenColorPicker(triggerBtn, currentColor, title, callback)
    ColorPickerFrame.Position = UDim2.new(0, triggerBtn.AbsolutePosition.X + triggerBtn.AbsoluteSize.X + 5, 0, triggerBtn.AbsolutePosition.Y)
    ColorPickerFrame.Visible = true
    ClickCloser.Visible = true

    ColorPickerTitle.Text = title or "Color Picker"

    CurrentColorCallback = callback
    local h, s, v = currentColor:ToHSV()
    CurrentHSV.H, CurrentHSV.S, CurrentHSV.V, CurrentHSV.A = h, s, v, 0
    UpdateColor()
end

local draggingColorPicker = false
local dragStartColorPicker = nil
local startPosColorPicker = nil

ColorPickerTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingColorPicker = true
        dragStartColorPicker = Vector2.new(input.Position.X, input.Position.Y)
        startPosColorPicker = ColorPickerFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingColorPicker = false
            end
        end)
    end
end)

ColorPickerTitle.InputChanged:Connect(function(input)
    if draggingColorPicker and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentPos - dragStartColorPicker
        ColorPickerFrame.Position = UDim2.new(
            startPosColorPicker.X.Scale,
            startPosColorPicker.X.Offset + delta.X,
            startPosColorPicker.Y.Scale,
            startPosColorPicker.Y.Offset + delta.Y
        )
    end
end)

local function OpenColorPickerMenu(colorBtn, currentCallback)
    local mouse = UserInputService:GetMouseLocation()
    local inset = game:GetService("GuiService"):GetGuiInset()

    for _, c in pairs(ButtonHolder:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local copyBtn = Instance.new("TextButton", ButtonHolder)
    copyBtn.Size = UDim2.new(1, 0, 0, 22)
    copyBtn.BackgroundTransparency = 1
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = ""
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 3003
    copyBtn.LayoutOrder = 1

    local copyLbl = Instance.new("TextLabel", copyBtn)
    copyLbl.BackgroundTransparency = 1
    copyLbl.Size = UDim2.new(1, -10, 1, 0)
    copyLbl.Position = UDim2.new(0, 10, 0, 0)
    copyLbl.Text = "Copy Color"
    copyLbl.TextXAlignment = Enum.TextXAlignment.Left
    copyLbl.TextSize = 13
    copyLbl.TextColor3 = Library.DimTextColor
    copyLbl.FontFace = Library.Font
    copyLbl.ZIndex = 3004

    local copyHovered = false
    copyBtn.MouseEnter:Connect(function()
        copyHovered = true
        copyBtn.BackgroundTransparency = 0
        copyBtn.BackgroundColor3 = Color3.fromHex("#181818")
        copyLbl.TextColor3 = Library.AccentColor
        copyLbl.FontFace = Library.FontBold
    end)
    copyBtn.MouseLeave:Connect(function()
        copyHovered = false
        copyBtn.BackgroundTransparency = 1
        copyLbl.TextColor3 = Library.DimTextColor
        copyLbl.FontFace = Library.Font
    end)
    copyBtn.MouseButton1Click:Connect(function()
        CopiedColor = colorBtn.BackgroundColor3
        Library:Notify("Color copied!")
        ContextMenu.Visible = false
        ClickCloser.Visible = false
    end)

    local pasteBtn = Instance.new("TextButton", ButtonHolder)
    pasteBtn.Size = UDim2.new(1, 0, 0, 22)
    pasteBtn.BackgroundTransparency = 1
    pasteBtn.BorderSizePixel = 0
    pasteBtn.Text = ""
    pasteBtn.AutoButtonColor = false
    pasteBtn.ZIndex = 3003
    pasteBtn.LayoutOrder = 2

    local pasteLbl = Instance.new("TextLabel", pasteBtn)
    pasteLbl.BackgroundTransparency = 1
    pasteLbl.Size = UDim2.new(1, -10, 1, 0)
    pasteLbl.Position = UDim2.new(0, 10, 0, 0)
    pasteLbl.Text = "Paste Color"
    pasteLbl.TextXAlignment = Enum.TextXAlignment.Left
    pasteLbl.TextSize = 13
    pasteLbl.ZIndex = 3004

    if CopiedColor then
        pasteLbl.TextColor3 = Library.DimTextColor
        pasteLbl.FontFace = Library.Font
    else
        pasteLbl.TextColor3 = Color3.fromRGB(80, 80, 80)
        pasteLbl.FontFace = Library.Font
        pasteBtn.Active = false
    end

    local pasteHovered = false
    if CopiedColor then
        pasteBtn.MouseEnter:Connect(function()
            pasteHovered = true
            pasteBtn.BackgroundTransparency = 0
            pasteBtn.BackgroundColor3 = Color3.fromHex("#181818")
            pasteLbl.TextColor3 = Library.AccentColor
            pasteLbl.FontFace = Library.FontBold
        end)
        pasteBtn.MouseLeave:Connect(function()
            pasteHovered = false
            pasteBtn.BackgroundTransparency = 1
            pasteLbl.TextColor3 = Library.DimTextColor
            pasteLbl.FontFace = Library.Font
        end)
        pasteBtn.MouseButton1Click:Connect(function()
            if CopiedColor then
                colorBtn.BackgroundColor3 = CopiedColor
                currentCallback(CopiedColor, 0)
                Library:Notify("Color pasted!")
            end
            ContextMenu.Visible = false
            ClickCloser.Visible = false
        end)
    end

    ContextMenu.Position = UDim2.fromOffset(mouse.X + 5, mouse.Y - inset.Y + 5)
    ContextMenu.Visible = true
    ClickCloser.Visible = true
end

local mainboxframe = Instance.new("Frame")
mainboxframe.Name = "mainboxframe"
mainboxframe.Parent = skeet
mainboxframe.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainboxframe.BorderColor3 = Color3.fromRGB(18, 18, 18)
mainboxframe.BorderSizePixel = 2
mainboxframe.Position = UDim2.new(0.246802106, 0, 0.156354889, 0)
mainboxframe.Size = UDim2.new(0, 750, 0, 660)
mainboxframe.Active = true
mainboxframe.Draggable = false

local realframe = Instance.new("Frame")
realframe.Name = "realframe"
realframe.Parent = skeet
realframe.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
realframe.BorderColor3 = Color3.fromRGB(60, 60, 60)
realframe.Position = UDim2.new(0.2495, 0, 0.163275376, 0)
realframe.Size = UDim2.new(0, 740, 0, 647)


local ToggleKey = Enum.KeyCode.Insert
local CursorEnabled = true

local ModalElement = Instance.new("TextButton")
ModalElement.Name = "Modal"
ModalElement.Parent = skeet
ModalElement.BackgroundTransparency = 1
ModalElement.BorderSizePixel = 0
ModalElement.Text = ""
ModalElement.Size = UDim2.new(0,0,0,0)
ModalElement.Modal = true

local MouseCursor = Drawing.new("Triangle")
MouseCursor.Thickness = 1
MouseCursor.Filled = true
MouseCursor.Color = Library.AccentColor
MouseCursor.Visible = true
MouseCursor.ZIndex = 100

local MouseCursorOutline = Drawing.new("Triangle")
MouseCursorOutline.Thickness = 1
MouseCursorOutline.Filled = false
MouseCursorOutline.Color = Color3.new(0,0,0)
MouseCursorOutline.Visible = true
MouseCursorOutline.ZIndex = 99

local isMenuOpen = true

local function ToggleUI()
    isMenuOpen = not isMenuOpen
    mainboxframe.Visible = isMenuOpen
    realframe.Visible = isMenuOpen
    ModalElement.Modal = isMenuOpen

    MouseCursor.Visible = isMenuOpen
    MouseCursorOutline.Visible = isMenuOpen

    if isMenuOpen then
        UserInputService.MouseIconEnabled = false
    else
        UserInputService.MouseIconEnabled = true
    end
end


RunService.RenderStepped:Connect(function()
    if isMenuOpen then
        UserInputService.MouseIconEnabled = false

        local m = UserInputService:GetMouseLocation()
        MouseCursor.PointA = Vector2.new(m.X, m.Y)
        MouseCursor.PointB = Vector2.new(m.X + 16, m.Y + 6)
        MouseCursor.PointC = Vector2.new(m.X + 6, m.Y + 16)

        MouseCursorOutline.PointA = MouseCursor.PointA
        MouseCursorOutline.PointB = MouseCursor.PointB
        MouseCursorOutline.PointC = MouseCursor.PointC

        MouseCursor.Color = Library.AccentColor
    end
end)

local PlayerMenu = Instance.new("Frame")
PlayerMenu.Name = "PlayerMenu"
PlayerMenu.Parent = skeet
getgenv().PlayerMenu = PlayerMenu
getgenv().ClickCloser = ClickCloser
PlayerMenu.Size = UDim2.fromOffset(150, 0)
PlayerMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PlayerMenu.BorderColor3 = Color3.new(0,0,0)
PlayerMenu.BorderSizePixel = 1
PlayerMenu.Visible = false
PlayerMenu.AutomaticSize = Enum.AutomaticSize.Y
PlayerMenu.ZIndex = 3000

local PlayerMenuOutline = Instance.new("UIStroke", PlayerMenu)
PlayerMenuOutline.Color = Color3.new(0,0,0)
PlayerMenuOutline.Thickness = 1
PlayerMenuOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local PlayerMenuInline = Instance.new("Frame", PlayerMenu)
PlayerMenuInline.BackgroundTransparency = 1
PlayerMenuInline.Size = UDim2.new(1, -2, 1, -2)
PlayerMenuInline.Position = UDim2.new(0, 1, 0, 1)
PlayerMenuInline.ZIndex = 3001
local PlayerMenuInlineStroke = Instance.new("UIStroke", PlayerMenuInline)
PlayerMenuInlineStroke.Color = Color3.fromHex("#323232")
PlayerMenuInlineStroke.Thickness = 1

local PlayerMenuHolder = Instance.new("Frame", PlayerMenu)
PlayerMenuHolder.BackgroundTransparency = 1
PlayerMenuHolder.Size = UDim2.new(1, 0, 0, 0)
PlayerMenuHolder.AutomaticSize = Enum.AutomaticSize.Y
PlayerMenuHolder.ZIndex = 3002

local PlayerMenuLayout = Instance.new("UIListLayout", PlayerMenuHolder)
PlayerMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerMenuLayout.Padding = UDim.new(0, 0)

local SelectedPlayer = nil
local Spectating = nil
local Following = nil

local function CreateMenuButton(text, callback)
    local btn = Instance.new("TextButton", PlayerMenuHolder)
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 3003

    local noSelect = Instance.new("Frame"); noSelect.Visible = false
    btn.SelectionImageObject = noSelect

    local lbl = Instance.new("TextLabel", btn)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Library.DimTextColor
    lbl.FontFace = Library.Font
    lbl.TextSize = 13
    lbl.ZIndex = 3004

    btn.MouseEnter:Connect(function()
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromHex("#181818")
        lbl.TextColor3 = Library.AccentColor
        lbl.FontFace = Library.FontBold
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundTransparency = 1
        lbl.TextColor3 = Library.DimTextColor
        lbl.FontFace = Library.Font
    end)

    btn.MouseButton1Click:Connect(function() callback() end)
    return lbl
end

local function CreateMenuToggle(text, getVal, setVal)
    local btn = Instance.new("TextButton", PlayerMenuHolder)
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 3003

    local noSelect = Instance.new("Frame"); noSelect.Visible = false
    btn.SelectionImageObject = noSelect

    local lbl = Instance.new("TextLabel", btn)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -25, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Library.DimTextColor
    lbl.FontFace = Library.Font
    lbl.TextSize = 13
    lbl.ZIndex = 3004

    local Outer = Instance.new("Frame", btn)
    Outer.Position = UDim2.new(1, -18, 0.5, -3)
    Outer.Size = UDim2.new(0, 6, 0, 6)
    Outer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Outer.BorderColor3 = Color3.fromHex("0e0c0d")
    Outer.BorderSizePixel = 1
    Outer.ZIndex = 3004

    local Inner = Instance.new("Frame", Outer)
    Inner.Size = UDim2.new(1, 0, 1, 0)
    Inner.BorderSizePixel = 0
    Inner.BackgroundColor3 = Color3.new(1,1,1)
    Inner.ZIndex = 3005

    local function UpdateState()
        local state = getVal()
        if state then
            Inner.BackgroundColor3 = Library.AccentColor
            local h, s, v = Library.AccentColor:ToHSV()
            ApplyGradient(Inner, Library.AccentColor, Color3.fromHSV(h, s, math.clamp(v * 0.8, 0, 1)))
            lbl.TextColor3 = Color3.new(1,1,1)
        else
            Inner.BackgroundColor3 = Color3.new(1,1,1)
            ApplyGradient(Inner, Color3.fromRGB(77, 77, 77), Color3.fromRGB(52, 52, 52))
            lbl.TextColor3 = Library.DimTextColor
        end
    end

    btn.MouseButton1Click:Connect(function()
        setVal(not getVal())
        UpdateState()
    end)

    btn.MouseEnter:Connect(function()
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromHex("#181818")
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundTransparency = 1
    end)

    btn.Name = "Update_"..text

    RunService.RenderStepped:Connect(function()
        if PlayerMenu.Visible then UpdateState() end
    end)
end

CreateMenuButton("Set Ragebot Target", function()
    if SelectedPlayer then
        Library.Flags["RageTarget"] = SelectedPlayer.Name
        Library:Notify("Target set to: " .. SelectedPlayer.DisplayName)
    end
end)

CreateMenuButton("Copy User ID", function()
    if SelectedPlayer then
        if setclipboard then
            setclipboard(tostring(SelectedPlayer.UserId))
            Library:Notify("Copied User ID: " .. SelectedPlayer.UserId)
        else
            Library:Notify("Clipboard not supported")
        end
    end
    PlayerMenu.Visible = false
    ClickCloser.Visible = false
end)

CreateMenuButton("Copy Profile Link", function()
    if SelectedPlayer then
        local profileLink = "https://www.roblox.com/users/" .. SelectedPlayer.UserId .. "/profile"
        if setclipboard then
            setclipboard(profileLink)
            Library:Notify("Copied profile link!")
        else
            Library:Notify("Clipboard not supported")
        end
    end
    PlayerMenu.Visible = false
    ClickCloser.Visible = false
end)

CreateMenuButton("Teleport To Player", function()
    if SelectedPlayer and SelectedPlayer.Character and LocalPlayer.Character then
        local targetRoot = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and myRoot then
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            Library:Notify("Teleported to " .. SelectedPlayer.DisplayName)
        else
            Library:Notify("Cannot teleport - character not loaded")
        end
    end
    PlayerMenu.Visible = false
    ClickCloser.Visible = false
end)

CreateMenuToggle("Spectate Player",
    function() return (Spectating == SelectedPlayer) end,
    function(state)
        if state then
            Spectating = SelectedPlayer
            workspace.CurrentCamera.CameraSubject = SelectedPlayer.Character.Humanoid
        else
            Spectating = nil
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
)

CreateMenuToggle("Go To Player (Loop)",
    function() return (Following == SelectedPlayer) end,
    function(state)
        if state then Following = SelectedPlayer else Following = nil end
    end
)

RunService.RenderStepped:Connect(function()
    if Following and Following.Character and Following.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Following.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
    end

    if Spectating then
        if Spectating.Character and Spectating.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = Spectating.Character.Humanoid
        elseif not Spectating.Parent then
            Spectating = nil
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if workspace.CurrentCamera.CameraSubject ~= LocalPlayer.Character.Humanoid then
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
    end
end)

local resizeHandle = Instance.new("ImageButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Parent = mainboxframe
resizeHandle.BackgroundTransparency = 1
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.Image = "rbxassetid://11396067695"
resizeHandle.ImageTransparency = 0.5
resizeHandle.ZIndex = 20

local resizing = false
local resizeStart = Vector2.new()
local startSizeMain = UDim2.new()

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStart = Vector2.new(input.Position.X, input.Position.Y)
        startSizeMain = mainboxframe.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentPos - resizeStart

        local newX = math.max(450, startSizeMain.X.Offset + delta.X)
        local newY = math.max(660, startSizeMain.Y.Offset + delta.Y)

        mainboxframe.Size = UDim2.new(0, newX, 0, newY)
        realframe.Size = UDim2.new(0, newX - 10, 0, newY - 13)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

local backgroundPattern = Instance.new("ImageLabel")
backgroundPattern.Name = "backgroundpattern"
backgroundPattern.Parent = realframe
backgroundPattern.BackgroundTransparency = 1
backgroundPattern.Position = UDim2.new(0, 0, 0, 0)
backgroundPattern.Size = UDim2.new(1, 0, 1, 0)
backgroundPattern.Image = "rbxassetid://8547666218"
backgroundPattern.ImageColor3 = Color3.fromRGB(12, 12, 12)
backgroundPattern.ScaleType = Enum.ScaleType.Tile
backgroundPattern.TileSize = UDim2.new(0, 8, 0, 8)
backgroundPattern.ZIndex = 1

local iocnframe = Instance.new("Frame")
iocnframe.Name = "iocnframe"
iocnframe.Parent = realframe
iocnframe.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
iocnframe.BackgroundTransparency = 1
iocnframe.BorderSizePixel = 0
iocnframe.Position = UDim2.new(0, 0, 0, 2)
iocnframe.Size = UDim2.new(0, 93, 1, -4)
iocnframe.ZIndex = 2

local SidebarFill = Instance.new("Frame")
SidebarFill.Name = "SidebarFill"
SidebarFill.Parent = iocnframe
SidebarFill.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
SidebarFill.BorderSizePixel = 0
SidebarFill.Position = UDim2.new(0, 0, 0, 624)
SidebarFill.Size = UDim2.new(1, 0, 1, -624)
SidebarFill.ZIndex = 2

local OutlineColor = Color3.fromRGB(0, 0, 0)
local InlineColor = Color3.fromRGB(85, 85, 85)

local SidebarLineTop = Instance.new("Frame")
SidebarLineTop.Name = "SidebarLineTop"
SidebarLineTop.Parent = iocnframe
SidebarLineTop.BackgroundColor3 = InlineColor
SidebarLineTop.BorderSizePixel = 0
SidebarLineTop.AnchorPoint = Vector2.new(1, 0)
SidebarLineTop.Position = UDim2.new(1, 0, 0, 0)
SidebarLineTop.Size = UDim2.new(0, 1, 0, 0)
SidebarLineTop.ZIndex = 20

local SidebarLineTopIn = Instance.new("Frame")
SidebarLineTopIn.Name = "SidebarLineTopIn"
SidebarLineTopIn.Parent = SidebarLineTop
SidebarLineTopIn.BackgroundColor3 = OutlineColor
SidebarLineTopIn.BorderSizePixel = 0
SidebarLineTopIn.Position = UDim2.new(0, -1, 0, 0)
SidebarLineTopIn.Size = UDim2.new(0, 1, 1, 0)
SidebarLineTopIn.ZIndex = 20

local SidebarLineBot = Instance.new("Frame")
SidebarLineBot.Name = "SidebarLineBot"
SidebarLineBot.Parent = iocnframe
SidebarLineBot.BackgroundColor3 = InlineColor
SidebarLineBot.BorderSizePixel = 0
SidebarLineBot.AnchorPoint = Vector2.new(1, 0)
SidebarLineBot.Position = UDim2.new(1, 0, 0, 0)
SidebarLineBot.Size = UDim2.new(0, 1, 0, 0)
SidebarLineBot.ZIndex = 20

local SidebarLineBotIn = Instance.new("Frame")
SidebarLineBotIn.Name = "SidebarLineBotIn"
SidebarLineBotIn.Parent = SidebarLineBot
SidebarLineBotIn.BackgroundColor3 = OutlineColor
SidebarLineBotIn.BorderSizePixel = 0
SidebarLineBotIn.Position = UDim2.new(0, -1, 0, 0)
SidebarLineBotIn.Size = UDim2.new(0, 1, 1, 0)
SidebarLineBotIn.ZIndex = 20

local function UpdateDivider(selectedIndex)
    local tabHeight = 78
    local topHeight = (selectedIndex - 1) * tabHeight
    local botOffset = selectedIndex * tabHeight

    SidebarLineTop.Size = UDim2.new(0, 1, 0, topHeight)

    SidebarLineBot.Position = UDim2.new(1, 0, 0, botOffset)
    SidebarLineBot.Size = UDim2.new(0, 1, 1, -botOffset)
end

local function addSelectionLines(frame)
    local inlineColor = Color3.fromRGB(85, 85, 85)
    local outlineColor = Color3.fromRGB(0, 0, 0)

    local topOut = Instance.new("Frame", frame) topOut.Name="TopOutline" topOut.BackgroundColor3=outlineColor topOut.BorderSizePixel=0 topOut.Size=UDim2.new(1,0,0,1) topOut.Visible=false
    local topIn = Instance.new("Frame", frame) topIn.Name="TopInline" topIn.BackgroundColor3=inlineColor topIn.BorderSizePixel=0 topIn.Size=UDim2.new(1,0,0,1) topIn.Position=UDim2.new(0,0,0,1) topIn.Visible=false topIn.ZIndex=2
    local topPatch = Instance.new("Frame", frame) topPatch.Name="TopPatch" topPatch.BackgroundColor3=inlineColor topPatch.BorderSizePixel=0 topPatch.Size=UDim2.new(0,1,0,1) topPatch.Position=UDim2.new(1,-1,0,0) topPatch.Visible=false topPatch.ZIndex=5
    local botOut = Instance.new("Frame", frame) botOut.Name="BotOutline" botOut.BackgroundColor3=outlineColor botOut.BorderSizePixel=0 botOut.Size=UDim2.new(1,0,0,1) botOut.Position=UDim2.new(0,0,1,-1) botOut.Visible=false
    local botIn = Instance.new("Frame", frame) botIn.Name="BotInline" botIn.BackgroundColor3=inlineColor botIn.BorderSizePixel=0 botIn.Size=UDim2.new(1,0,0,1) botIn.Position=UDim2.new(0,0,1,-2) botIn.Visible=false botIn.ZIndex=2
    local botPatch = Instance.new("Frame", frame) botPatch.Name="BotPatch" botPatch.BackgroundColor3=inlineColor botPatch.BorderSizePixel=0 botPatch.Size=UDim2.new(0,1,0,1) botPatch.Position=UDim2.new(1,-1,1,-1) botPatch.Visible=false botPatch.ZIndex=5

    local rightOut = Instance.new("Frame", frame) rightOut.Name="RightOutline" rightOut.BackgroundColor3=outlineColor rightOut.BorderSizePixel=0 rightOut.Size=UDim2.new(0,1,1,1) rightOut.Position=UDim2.new(1,-2,0,0)
    rightOut.Visible=false
    rightOut.ZIndex=2

    local rightIn = Instance.new("Frame", frame) rightIn.Name="RightInline" rightIn.BackgroundColor3=inlineColor rightIn.BorderSizePixel=0 rightIn.Size=UDim2.new(1,-1,0,0) rightIn.Position=UDim2.new(1,-1,0,0) rightIn.Visible=true rightIn.ZIndex=2
end

local function updateTabState(frame, isSelected)
    local outlines = {frame:FindFirstChild("TopOutline"), frame:FindFirstChild("TopInline"), frame:FindFirstChild("TopPatch"), frame:FindFirstChild("BotOutline"), frame:FindFirstChild("BotInline"), frame:FindFirstChild("BotPatch")}
    local rightInline = frame:FindFirstChild("RightInline")

    if isSelected then
        for _, line in pairs(outlines) do if line then line.Visible = true end end
        if rightInline then rightInline.Visible = false end
    else
        for _, line in pairs(outlines) do if line then line.Visible = false end end
        if rightInline then rightInline.Visible = true end
    end
end

local function createTabFrame(name, parent, orderIndex)
    local f = Instance.new("Frame")
    f.Name = name; f.Parent = parent;
    f.BackgroundColor3 = Color3.fromRGB(12, 12, 12);
    f.BorderSizePixel = 0;
    f.Position = UDim2.new(0, 0, 0, (orderIndex - 1) * 78);
    f.Size = UDim2.new(1, 0, 0, 78);
    f.BackgroundTransparency = 0;
    f.ZIndex = 3
    addSelectionLines(f)
    updateTabState(f, false)
    return f
end

local rageframe = createTabFrame("rageframe", iocnframe, 1)
local aaframe = createTabFrame("aaframe", iocnframe, 2)
local legitframe = createTabFrame("legitframe", iocnframe, 3)
local visualframe = createTabFrame("visualframe", iocnframe, 4)
local settingsframe = createTabFrame("settingsframe", iocnframe, 5)
local skinframe = createTabFrame("skinframe", iocnframe, 6)
local userframe = createTabFrame("userframe", iocnframe, 7)
local extraframe = createTabFrame("extraframe", iocnframe, 8)

rageframe.BackgroundTransparency = 1
updateTabState(rageframe, true)
rageframe.ZIndex = 10

local UIStroke_main = Instance.new("UIStroke")
UIStroke_main.Parent = mainboxframe
UIStroke_main.Color = Color3.fromRGB(89, 89, 89)
UIStroke_main.Thickness = 1.3
UIStroke_main.LineJoinMode = Enum.LineJoinMode.Round

local icons = {}
local containerFrames = {rageframe, aaframe, legitframe, visualframe, settingsframe, skinframe, userframe, extraframe}

local function setupIcon(btn, parent, imageId)
    btn.Parent = parent
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new(0.5, 0, 0.5, 0)
    btn.Size = UDim2.new(0, 59, 0, 65)
    btn.Image = imageId
    btn.ImageTransparency = 0
    btn.ImageColor3 = Color3.fromRGB(100, 100, 100)
    btn.ZIndex = 11
    table.insert(icons, btn)
    return btn
end

local btn1 = Instance.new("ImageButton") setupIcon(btn1, rageframe, "rbxassetid://127322341339146")
btn1.ImageColor3 = Color3.fromRGB(255, 255, 255)
btn1.Name = "Logo"; btn1.Position = UDim2.new(0.6, 0, 0.6, 0)

local btn7 = Instance.new("ImageButton") setupIcon(btn7, aaframe, "rbxassetid://71833091806293")
btn7.Position = UDim2.new(0.5, 0.3, 0.5, 3)

local btn2 = Instance.new("ImageButton") setupIcon(btn2, legitframe, "rbxassetid://109522202954909")
btn2.Position = UDim2.new(0.5, 0.3, 0.5, 3)

local btn3 = Instance.new("ImageButton") setupIcon(btn3, visualframe, "rbxassetid://134337510002621")
btn3.Position = UDim2.new(0.5, 0.3, 0.5, 3)

local btn4 = Instance.new("ImageButton") setupIcon(btn4, settingsframe, "rbxassetid://96057809454753")
btn4.Position = UDim2.new(0.5, 0, 0.5, 3)

local btn5 = Instance.new("ImageButton") setupIcon(btn5, skinframe, "rbxassetid://129738887148306")
btn5.Position = UDim2.new(0.5, 4, 0.5, 2)

local btn6 = Instance.new("ImageButton") setupIcon(btn6, userframe, "rbxassetid://115027436437851")
btn6.Position = UDim2.new(0.5, 3, 0.5, 4)

local btn8 = Instance.new("ImageButton") setupIcon(btn8, extraframe, "rbxassetid://88959969303399")
btn8.Position = UDim2.new(0.5, 3, 0.5, 6)

local function createContentFrame(name)
    local f = Instance.new("Frame")
    f.Name = name
    f.Parent = realframe
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Position = UDim2.new(0, 115, 0.03, 0)
    f.Size = UDim2.new(1, -125, 0.92, 0)
    f.Visible = false
    f.ZIndex = 5

    local Left = Instance.new("Frame", f)
    Left.Name = "Left"
    Left.BackgroundTransparency = 1
    Left.Size = UDim2.new(0.5, -10, 1, 0)
    Left.Position = UDim2.new(0, 0, 0, 0)

    local LeftPad = Instance.new("UIPadding", Left)
    LeftPad.PaddingTop = UDim.new(0, 8)
    LeftPad.PaddingLeft = UDim.new(0, 1)
    LeftPad.PaddingRight = UDim.new(0, 8)
    LeftPad.PaddingBottom = UDim.new(0, 10)

    local LeftLayout = Instance.new("UIListLayout", Left)
    LeftLayout.Padding = UDim.new(0, 20)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Right = Instance.new("Frame", f)
    Right.Name = "Right"
    Right.BackgroundTransparency = 1
    Right.Size = UDim2.new(0.5, -10, 1, 0)
    Right.Position = UDim2.new(0.5, 10, 0, 0)

    local RightPad = Instance.new("UIPadding", Right)
    RightPad.PaddingTop = UDim.new(0, 8)
    RightPad.PaddingLeft = UDim.new(0, 1)
    RightPad.PaddingRight = UDim.new(0, 8)
    RightPad.PaddingBottom = UDim.new(0, 10)

    local RightLayout = Instance.new("UIListLayout", Right)
    RightLayout.Padding = UDim.new(0, 20)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder

    return f
end

local ragecontentframe = createContentFrame("ragecontentframe")
local aacontentframe = createContentFrame("aacontentframe")
local legitcontentframe = createContentFrame("legitcontentframe")
local visualcontentframe = createContentFrame("visualcontentframe")
local settingscontentframe = createContentFrame("settingscontentframe")
local skincontentframe = createContentFrame("skincontentframe")
local usercontentframe = createContentFrame("usercontentframe")
local extracontentframe = createContentFrame("extracontentframe")

local ContentFrames = {
    ragecontentframe, aacontentframe, legitcontentframe,
    visualcontentframe, settingscontentframe, skincontentframe, usercontentframe, extracontentframe
}
ragecontentframe.Visible = true

local dragging, dragStart, startPosMain, startPosReal = false, nil, nil, nil
mainboxframe.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true;
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPosMain = mainboxframe.Position; startPosReal = realframe.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
mainboxframe.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentPos - dragStart
        mainboxframe.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        realframe.Position = UDim2.new(startPosReal.X.Scale, startPosReal.X.Offset + delta.X, startPosReal.Y.Scale, startPosReal.Y.Offset + delta.Y)
    end
end)

local selectedIcon, selectedIndex = btn1, 1
UpdateDivider(1)

local isAnimating = false

for i, icon in ipairs(icons) do
    icon.MouseButton1Click:Connect(function()
        if Library.ActiveDropdown then
            Library.ActiveDropdown.Visible = false
            Library.ActiveDropdown = nil
        end

        if ClickCloser then ClickCloser.Visible = false end

        if isAnimating then return end

        if selectedIcon and selectedIcon ~= icon then
            TweenService:Create(selectedIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
            TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()

            containerFrames[selectedIndex].BackgroundTransparency = 0
            updateTabState(containerFrames[selectedIndex], false)
            containerFrames[selectedIndex].ZIndex = 3

            containerFrames[i].BackgroundTransparency = 1
            updateTabState(containerFrames[i], true)
            containerFrames[i].ZIndex = 10
            UpdateDivider(i)

            local oldContent = ContentFrames[selectedIndex]
            local newContent = ContentFrames[i]

            if oldContent and newContent then
                isAnimating = true

                oldContent.Visible = false

                newContent.Visible = true
                newContent.Position = UDim2.new(0, 115, 0.03, 15)

                local animSpeed = Library.AnimationSpeed or 0.25
                local animStyle = Library.AnimationEase or Enum.EasingStyle.Quint

                local slideTween = TweenService:Create(
                    newContent,
                    TweenInfo.new(animSpeed, animStyle, Enum.EasingDirection.Out),
                    {Position = UDim2.new(0, 115, 0.03, 0)}
                )
                slideTween:Play()

                slideTween.Completed:Connect(function()
                    isAnimating = false
                end)
            else
                if oldContent then oldContent.Visible = false end
                if newContent then newContent.Visible = true end
                isAnimating = false
            end

            selectedIcon = icon
            selectedIndex = i
        end
    end)

    icon.MouseEnter:Connect(function()
        if icon ~= selectedIcon then
            TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(170, 170, 170)}):Play()
        end
    end)
    icon.MouseLeave:Connect(function()
        if icon ~= selectedIcon then
            TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end
    end)
end

local topGradientFrame = Instance.new("Frame")
topGradientFrame.Name = "TopGradient"
topGradientFrame.Parent = realframe
topGradientFrame.BackgroundTransparency = 1
topGradientFrame.BorderSizePixel = 0
topGradientFrame.Position = UDim2.new(0, 1, 0, 0)
topGradientFrame.Size = UDim2.new(1, -3, 0, 2)
topGradientFrame.ZIndex = 10

local gradientImage = Instance.new("ImageLabel")
gradientImage.Name = "gradient"
gradientImage.Parent = topGradientFrame
gradientImage.BackgroundTransparency = 1
gradientImage.BorderSizePixel = 0
gradientImage.Position = UDim2.new(0, 0, 0, 1)
gradientImage.Size = UDim2.new(1, 0, 1, 0)
gradientImage.Image = "rbxassetid://8508019876"
gradientImage.ScaleType = Enum.ScaleType.Stretch
gradientImage.ZIndex = 10

local glow = Instance.new("Frame", realframe)
glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255); glow.BackgroundTransparency = 0.8; glow.BorderSizePixel = 0; glow.Position = UDim2.new(0, 0, 0, 4); glow.Size = UDim2.new(1, 0, 0, 1); glow.ZIndex = 14

local SectionFunctions = {}
SectionFunctions.__index = SectionFunctions
local TabFunctions = {}
TabFunctions.__index = TabFunctions
local ToggleFunctions = {}
ToggleFunctions.__index = ToggleFunctions

function TabFunctions:AddSection(Name, Side, MaxSize)
    Side = Side or "Left"
    local ParentColumn = self.ContentFrame:FindFirstChild(Side) or self.ContentFrame:FindFirstChild("Left")

    if not self.Sections then self.Sections = {Left = {}, Right = {}} end

    local SectionBox = Instance.new("Frame")
    SectionBox.Name = "Section_" .. Name
    SectionBox.BackgroundColor3 = Library.SectionColor
    SectionBox.BackgroundTransparency = 0
    SectionBox.BorderSizePixel = 0
    SectionBox.ZIndex = 6
    SectionBox.Parent = ParentColumn
    SectionBox.ClipsDescendants = false
    SectionBox.Size = UDim2.new(1, 0, 0, 20)

    local SectionData = {
        Instance = SectionBox,
        MaxSize = MaxSize,
    }
    table.insert(self.Sections[Side], SectionData)

    local OuterStroke = Instance.new("UIStroke", SectionBox)
    OuterStroke.Color = Color3.new(0.007843, 0.007843, 0.007843)
    OuterStroke.Thickness = 1
    OuterStroke.LineJoinMode = Enum.LineJoinMode.Round
    OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local InlineFrame = Instance.new("Frame", SectionBox)
    InlineFrame.Name = "InlineFrame"
    InlineFrame.BackgroundTransparency = 1
    InlineFrame.Size = UDim2.new(1, -2, 1, -2)
    InlineFrame.Position = UDim2.new(0, 1, 0, 1)
    InlineFrame.BorderSizePixel = 0
    InlineFrame.ZIndex = 11

    local InnerStroke = Instance.new("UIStroke", InlineFrame)
    InnerStroke.Color = Library.SectionBorder
    InnerStroke.Thickness = 1
    InnerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TitleBg = Instance.new("Frame", SectionBox)
    TitleBg.BackgroundColor3 = Library.SectionColor
    TitleBg.BorderSizePixel = 0
    TitleBg.Position = UDim2.new(0, 10, 0, -2)
    TitleBg.Size = UDim2.new(0, 0, 0, 4)
    TitleBg.AutomaticSize = Enum.AutomaticSize.X
    TitleBg.ZIndex = 14
    TitleBg.ClipsDescendants = false

    local TitlePad = Instance.new("UIPadding", TitleBg)
    TitlePad.PaddingLeft = UDim.new(0, 2)
    TitlePad.PaddingRight = UDim.new(0, 2)

    local Title, Shadow = CreateShadowedLabel({
        Parent = TitleBg,
        Text = Name,
        Position = UDim2.new(0, 0, 0, -6),
        Size = UDim2.new(0, 0, 0, 14),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        ZIndex = 14
    })
    Title.AutomaticSize = Enum.AutomaticSize.X
    Shadow.AutomaticSize = Enum.AutomaticSize.X
    Title.ClipsDescendants = false
    Shadow.ClipsDescendants = false

    local BorderMask = Instance.new("Frame", SectionBox)
    BorderMask.Name = "BorderMask"
    BorderMask.BackgroundColor3 = Library.SectionColor
    BorderMask.BorderSizePixel = 0
    BorderMask.Size = UDim2.new(0, 9, 1, 0)
    BorderMask.Position = UDim2.new(1, -9, 0, 0)
    BorderMask.ZIndex = 6
    BorderMask.Visible = false

    local Container = Instance.new("ScrollingFrame", SectionBox)
    Container.Name = "Container"
    Container.BackgroundTransparency = 1
    Container.Size = UDim2.new(1, 0, 1, -1)
    Container.Position = UDim2.new(0, 0, 0, 0)
    Container.ZIndex = 8
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.CanvasSize = UDim2.new(0,0,0,0)
    Container.ScrollBarThickness = 8
    Container.ScrollBarImageColor3 = Color3.new(0.305882, 0.305882, 0.305882)
    Container.ScrollBarImageTransparency = 0
    Container.BorderSizePixel = 0
    Container.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Container.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Container.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Container.ClipsDescendants = true

    local ScrollTrack = Instance.new("Frame", SectionBox)
    ScrollTrack.Name = "ScrollTrack"
    ScrollTrack.BackgroundColor3 = Library.SectionBorder
    ScrollTrack.BorderSizePixel = 0
    ScrollTrack.Size = UDim2.new(0, 8, 1, -1)
    ScrollTrack.Position = UDim2.new(1, -8, 0, 0)
    ScrollTrack.ZIndex = 7
    ScrollTrack.Visible = false
    ScrollTrack.ClipsDescendants = true

    local FadeTop = Instance.new("ImageLabel", SectionBox)
    FadeTop.Name = "FadeTop"
    FadeTop.BackgroundTransparency = 1
    FadeTop.Image = "rbxassetid://7783533907"
    FadeTop.ImageColor3 = Library.SectionColor
    FadeTop.Rotation = 180
    FadeTop.Size = UDim2.new(1, -14, 0, 12)
    FadeTop.Position = UDim2.new(0, 3, 0, 0)
    FadeTop.ZIndex = 10
    FadeTop.Visible = false
    FadeTop.ClipsDescendants = true

    local FadeBot = Instance.new("ImageLabel", SectionBox)
    FadeBot.Name = "BotFade"
    FadeBot.BackgroundTransparency = 1
    FadeBot.Image = "rbxassetid://7783533907"
    FadeBot.ImageColor3 = Library.SectionColor
    FadeBot.Size = UDim2.new(1, -14, 0, 15)
    FadeBot.Position = UDim2.new(0, 3, 1, -15)
    FadeBot.ZIndex = 10
    FadeBot.Visible = false
    FadeBot.ClipsDescendants = true

    local ArrowUp = Instance.new("TextButton", SectionBox)
    ArrowUp.Name = "ArrowUp"
    ArrowUp.BackgroundTransparency = 1
    ArrowUp.Size = UDim2.new(0, 10, 0, 10)
    ArrowUp.Position = UDim2.new(1, -20, 0, 7)
    ArrowUp.Text = ""
    ArrowUp.Visible = false
    ArrowUp.ZIndex = 15

    local ArrowUpImg = Instance.new("ImageLabel", ArrowUp)
    ArrowUpImg.BackgroundTransparency = 1
    ArrowUpImg.Image = "rbxassetid://8548757311"
    ArrowUpImg.ImageColor3 = Color3.new(0.8,0.8,0.8)
    ArrowUpImg.Size = UDim2.new(0, 8, 0, 6)
    ArrowUpImg.Position = UDim2.new(0.5, -4, 0.5, -3)
    ArrowUpImg.ZIndex = 16

    local ArrowDown = Instance.new("TextButton", SectionBox)
    ArrowDown.Name = "ArrowDown"
    ArrowDown.BackgroundTransparency = 1
    ArrowDown.Size = UDim2.new(0, 10, 0, 10)
    ArrowDown.Position = UDim2.new(1, -20, 1, -15)
    ArrowDown.Text = ""
    ArrowDown.Visible = false
    ArrowDown.ZIndex = 15

    local ArrowDownImg = Instance.new("ImageLabel", ArrowDown)
    ArrowDownImg.BackgroundTransparency = 1
    ArrowDownImg.Image = "rbxassetid://8548723563"
    ArrowDownImg.ImageColor3 = Color3.new(0.8,0.8,0.8)
    ArrowDownImg.Size = UDim2.new(0, 8, 0, 6)
    ArrowDownImg.Position = UDim2.new(0.5, -4, 0.5, -3)
    ArrowDownImg.ZIndex = 16

    local List = Instance.new("UIListLayout", Container)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 2)

    local Pad = Instance.new("UIPadding", Container)
    Pad.PaddingBottom = UDim.new(0, 12)
    Pad.PaddingLeft = UDim.new(0, 20)
    Pad.PaddingRight = UDim.new(0, 18)
    Pad.PaddingTop = UDim.new(0, 15)

    local function UpdateSize()
        local TotalHeight = self.ContentFrame.AbsoluteSize.Y

        local Layout = ParentColumn:FindFirstChildWhichIsA("UIListLayout")
        local Gap = Layout and Layout.Padding.Offset or 6

        local ManualGapChange = 25
        local TotalMargins = Gap - ManualGapChange

        local UsedHeight = TotalMargins
        local DynamicCount = 0

        local SectionCount = #self.Sections[Side]
        if SectionCount > 1 then
            UsedHeight = UsedHeight + ((SectionCount - 1) * Gap)
        end

        for _, s in ipairs(self.Sections[Side]) do
            UsedHeight = UsedHeight + 22

            if s.MaxSize then
                UsedHeight = UsedHeight + s.MaxSize
            else
                DynamicCount = DynamicCount + 1
            end
        end

        local RemainingForContent = math.max(0, TotalHeight - UsedHeight)
        local DynamicContentLimit = RemainingForContent / math.max(1, DynamicCount)

        DynamicContentLimit = math.floor(DynamicContentLimit)

        local viewH
        local contentH = List.AbsoluteContentSize.Y + Pad.PaddingTop.Offset + Pad.PaddingBottom.Offset

        if MaxSize then
            viewH = math.min(contentH, MaxSize)
        else
            viewH = DynamicContentLimit
        end

        SectionBox.Size = UDim2.new(1, 0, 0, viewH + 22)

        local isScrolling = contentH > viewH

        ScrollTrack.Visible = isScrolling
        BorderMask.Visible = isScrolling

        local pos = Container.CanvasPosition.Y
        local actualWindowH = Container.AbsoluteWindowSize.Y

        FadeTop.Visible = pos > 5 and isScrolling
        FadeBot.Visible = (pos + actualWindowH) < (contentH - 5) and isScrolling

        ArrowUp.Visible = FadeTop.Visible
        ArrowDown.Visible = FadeBot.Visible
    end

    SectionData.Update = UpdateSize

    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
    Container:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateSize)
    Container:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(UpdateSize)
    self.ContentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)

    for _, s in ipairs(self.Sections[Side]) do
        if s.Update then task.spawn(s.Update) end
    end

    ArrowUp.MouseButton1Click:Connect(function()
        local newY = math.max(0, Container.CanvasPosition.Y - 20)
        TweenService:Create(Container, TweenInfo.new(0.1), {CanvasPosition = Vector2.new(0, newY)}):Play()
    end)

    ArrowDown.MouseButton1Click:Connect(function()
        local max = Container.AbsoluteCanvasSize.Y - Container.AbsoluteWindowSize.Y
        local newY = math.min(max, Container.CanvasPosition.Y + 20)
        TweenService:Create(Container, TweenInfo.new(0.1), {CanvasPosition = Vector2.new(0, newY)}):Play()
    end)

    task.delay(0.05, UpdateSize)

    local SectionObj = { Container = Container, Library = Library }
    setmetatable(SectionObj, SectionFunctions)
    return SectionObj
end

function SectionFunctions:AddToggle(Config)
    local Text = Config.Text or "Toggle"
    local Default = Config.Default or false
    local Callback = Config.Callback or function() end
    local Flag = Config.Flag or Text
    local Tooltip = Config.Tooltip or nil

    if Library.Flags[Flag] == nil then Library.Flags[Flag] = Default end

    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Name = Text
    ToggleFrame.Parent = self.Container
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
    ToggleFrame.AutoButtonColor = false
    ToggleFrame.Text = ""

    local Outer = Instance.new("Frame", ToggleFrame)
    Outer.Position = UDim2.new(0, 0, 0.5, -4)
    Outer.Size = UDim2.new(0, 6, 0, 6)
    Outer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Outer.BorderColor3 = Color3.fromHex("0e0c0d")
    Outer.BorderSizePixel = 1

    local Inner = Instance.new("Frame", Outer)
    Inner.Position = UDim2.new(0, 0, 0, 0)
    Inner.Size = UDim2.new(1, 0, 1, 0)
    Inner.BorderSizePixel = 0
    Inner.BackgroundColor3 = Color3.new(1,1,1)

    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Text = Text
    Label.FontFace = Library.Font
    Label.TextSize = 14
    Label.TextColor3 = Library.TextColor
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 20, 0, -3)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local WidgetHolder = Instance.new("Frame", ToggleFrame)
    WidgetHolder.BackgroundTransparency = 1
    WidgetHolder.Position = UDim2.new(0, 20, 0, 0)
    WidgetHolder.Size = UDim2.new(1, -20, 1, 0)
    WidgetHolder.ZIndex = 20
    local WidgetLayout = Instance.new("UIListLayout", WidgetHolder)
    WidgetLayout.FillDirection = Enum.FillDirection.Horizontal
    WidgetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    WidgetLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    WidgetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    WidgetLayout.Padding = UDim.new(0, 5)

    local State = Library.Flags[Flag]

    local function Update()
        if State then
            Inner.BackgroundColor3 = Library.AccentColor
            local h, s, v = Library.AccentColor:ToHSV()
            local cTop = Library.AccentColor
            local cBot = Color3.fromHSV(h, s, math.clamp(v * 0.8, 0, 1))
            ApplyGradient(Inner, cTop, cBot)
            Inner.BackgroundColor3 = Color3.new(1,1,1)
            Label.TextColor3 = Color3.fromRGB(205, 205, 205)
        else
            ApplyGradient(Inner, Color3.fromRGB(77, 77, 77), Color3.fromRGB(52, 52, 52))
            Inner.BackgroundColor3 = Color3.new(1,1,1)
            Label.TextColor3 = Library.DimTextColor
        end
        Library.Flags[Flag] = State
        pcall(Callback, State)
    end

    ToggleFrame.MouseButton1Click:Connect(function()
        State = not State
        Update()
        if Library.Keybinds[Text] then Library.Keybinds[Text].Active = State end
    end)

    local TooltipFrame = nil

    if Tooltip then
        ToggleFrame.MouseEnter:Connect(function()
            TooltipFrame = Instance.new("Frame")
            TooltipFrame.Name = "Tooltip"
            TooltipFrame.Parent = skeet
            TooltipFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            TooltipFrame.BorderSizePixel = 0
            TooltipFrame.AutomaticSize = Enum.AutomaticSize.XY
            TooltipFrame.ZIndex = 5000

            local TooltipOutline = Instance.new("UIStroke", TooltipFrame)
            TooltipOutline.Color = Color3.fromRGB(0, 0, 0)
            TooltipOutline.Thickness = 1

            local TooltipText = Instance.new("TextLabel", TooltipFrame)
            TooltipText.Text = Tooltip
            TooltipText.FontFace = Library.Font
            TooltipText.TextSize = 13
            TooltipText.TextColor3 = Color3.fromRGB(200, 200, 200)
            TooltipText.BackgroundTransparency = 1
            TooltipText.AutomaticSize = Enum.AutomaticSize.XY
            TooltipText.ZIndex = 5001

            local TooltipPad = Instance.new("UIPadding", TooltipFrame)
            TooltipPad.PaddingLeft = UDim.new(0, 6)
            TooltipPad.PaddingRight = UDim.new(0, 6)
            TooltipPad.PaddingTop = UDim.new(0, 4)
            TooltipPad.PaddingBottom = UDim.new(0, 4)

            RunService.RenderStepped:Connect(function()
                if TooltipFrame and TooltipFrame.Parent then
                    local mouse = UserInputService:GetMouseLocation()
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    TooltipFrame.Position = UDim2.fromOffset(mouse.X + 10, mouse.Y - inset.Y + 10)
                end
            end)
        end)

        ToggleFrame.MouseLeave:Connect(function()
            if TooltipFrame then
                TooltipFrame:Destroy()
                TooltipFrame = nil
            end
        end)
    end

    local ToggleObj = {
        Frame = ToggleFrame,
        Set = function(self, val) State = val; Update() end,
        GetValue = function() return State end,
        Box = Inner,
        Holder = WidgetHolder
    }

    table.insert(Library.Registry.Toggles, ToggleObj)
    Library.Registry[Flag] = { Set = function(val) ToggleObj:Set(val) end }

    Update()

    function ToggleObj:AddKeybind(KeyConfig)
        local KeyDefault = KeyConfig.Default or KeyConfig.Key or Enum.KeyCode.Unknown
        local KeyMode = KeyConfig.Mode or "Toggle"
        local KeyCallback = KeyConfig.Callback or function() end
        local Key = KeyDefault


        local KeybindActive = false

        Library.Keybinds[Text] = { Key = Key, Mode = KeyMode, Active = State }

        local Wrapper = Instance.new("Frame", self.Holder)
        Wrapper.BackgroundTransparency = 1
        Wrapper.AutomaticSize = Enum.AutomaticSize.X
        Wrapper.Size = UDim2.new(0, 0, 1, 0)
        Wrapper.LayoutOrder = 2

        local BindBtn = Instance.new("TextButton", Wrapper)
        BindBtn.BackgroundTransparency = 1
        BindBtn.AutomaticSize = Enum.AutomaticSize.X
        BindBtn.Size = UDim2.new(0, 0, 0, 9)
        BindBtn.AnchorPoint = Vector2.new(0, 0.5)
        BindBtn.Position = UDim2.new(0, 0, 1, -12)
        BindBtn.FontFace = fonts.fontkb
        BindBtn.TextSize = 8
        BindBtn.TextColor3 = Color3.fromHex("#747474")
        BindBtn.TextStrokeTransparency = 0
        BindBtn.TextStrokeColor3 = Color3.new(0,0,0)
        BindBtn.AutoButtonColor = false
        BindBtn.TextYAlignment = Enum.TextYAlignment.Center

        local function UpdateText()
            local n = keys[Key] or Key.Name
            if Key == Enum.KeyCode.Unknown then n = "None" end
            BindBtn.Text = "[" .. n .. "]"
            if Library.Keybinds[Text] then Library.Keybinds[Text].Key = Key end
        end
        UpdateText()

        local Binding = false
        BindBtn.MouseButton1Click:Connect(function()
            Binding = true;
            BindBtn.Text = "[...]";
            BindBtn.TextColor3 = Library.AccentColor
        end)

        BindBtn.MouseButton2Click:Connect(function()
            OpenKeybindMenu(KeyMode, function(newMode)
                KeyMode = newMode
                Library.Keybinds[Text].Mode = newMode

                if newMode == "Always On" then
                    KeybindActive = true
                    if State then
                        Library.Keybinds[Text].Active = true
                        pcall(KeyCallback, true)
                    end
                elseif newMode == "Hold" then
                    KeybindActive = false
                    Library.Keybinds[Text].Active = false
                    pcall(KeyCallback, false)
                end
            end)
        end)

        game:GetService("UserInputService").InputBegan:Connect(function(Input, Processed)
            if Binding then
                if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType == Enum.UserInputType.MouseButton2 then
                    local Blacklist = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}
                    if table.find(Blacklist, Input.KeyCode) then return end
                    Key = Input.KeyCode
                    UpdateText()
                    BindBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
                    Binding = false
                end
                return
            end
            if Processed then return end

            if not State then return end

            if KeyMode == "Always On" then
                KeybindActive = true
                Library.Keybinds[Text].Active = true
                return
            end

            if Input.KeyCode == Key then
                if KeyMode == "Toggle" then
                    KeybindActive = not KeybindActive
                    Library.Keybinds[Text].Active = KeybindActive
                elseif KeyMode == "Hold" then
                    KeybindActive = true
                    Library.Keybinds[Text].Active = true
                end
                pcall(KeyCallback, KeybindActive)
            end
        end)

        game:GetService("UserInputService").InputEnded:Connect(function(Input)
            if Binding then return end
            if KeyMode == "Always On" then return end
            if Input.KeyCode == Key and KeyMode == "Hold" then
                KeybindActive = false
                Library.Keybinds[Text].Active = false
                pcall(KeyCallback, false)
            end
        end)

        return self
    end

    function ToggleObj:AddColorpicker(ColorConfig)
        ColorConfig = ColorConfig or {}
        local DefaultColor = ColorConfig.Default or Color3.fromRGB(255, 255, 255)
        local CPFlag = ColorConfig.Flag or (Flag .. "_Color")
        local Title = ColorConfig.Title or Text
        local ColorCallback = ColorConfig.Callback or function() end

        if Library.Flags[CPFlag] == nil then Library.Flags[CPFlag] = DefaultColor end

        local Wrapper = Instance.new("Frame", self.Holder)
        Wrapper.BackgroundTransparency = 1
        Wrapper.Size = UDim2.new(0, 16, 1, 0)
        Wrapper.LayoutOrder = 1

        local ColorPickerBtn = Instance.new("TextButton", Wrapper)
        ColorPickerBtn.Size = UDim2.new(0, 16, 0, 6)
        ColorPickerBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        ColorPickerBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
        ColorPickerBtn.BackgroundColor3 = Library.Flags[CPFlag]
        ColorPickerBtn.BorderColor3 = Color3.new(0,0,0)
        ColorPickerBtn.BorderSizePixel = 1
        ColorPickerBtn.Text = ""
        ColorPickerBtn.AutoButtonColor = false
        ColorPickerBtn.ZIndex = 12

        ColorPickerBtn.MouseButton1Click:Connect(function()
            OpenColorPicker(ColorPickerBtn, ColorPickerBtn.BackgroundColor3, Title, function(newColor, alpha)
                ColorPickerBtn.BackgroundColor3 = newColor
                Library.Flags[CPFlag] = newColor
                ColorCallback(newColor, alpha)
            end)
        end)

        ColorPickerBtn.MouseButton2Click:Connect(function()
            OpenColorPickerMenu(ColorPickerBtn, function(newColor, alpha)
                ColorPickerBtn.BackgroundColor3 = newColor
                Library.Flags[CPFlag] = newColor
                ColorCallback(newColor, alpha)
            end)
        end)
        return self
    end

    return ToggleObj
end

function SectionFunctions:AddKeybind(Config)
    local Text = Config.Text or "Keybind"
    local Default = Config.Default or Enum.KeyCode.Unknown
    local Mode = Config.Mode or "Toggle"
    local Callback = Config.Callback or function() end

    local Key = Default
    local Active = false

    Library.Keybinds[Text] = { Key = Key, Mode = Mode, Active = false }

    local Frame = Instance.new("Frame", self.Container)
    Frame.Name = "Keybind"
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 20)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Text
    Label.FontFace = Library.FontKeybind
    Label.TextSize = 13
    Label.TextColor3 = Library.TextColor
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextStrokeTransparency = 0

    local Button = Instance.new("TextButton", Frame)
    Button.Size = UDim2.new(0, 60, 0, 14)
    Button.Position = UDim2.new(1, -65, 0.5, -7)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Button.FontFace = fonts.fontkb
    Button.TextSize = 13
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.AutoButtonColor = false

    local function UpdateText()
        local n = keys[Key] or Key.Name
        if Key == Enum.KeyCode.Unknown then n = "None" end
        Button.Text = "[" .. n .. "]"

        if Library.Keybinds[Text] then Library.Keybinds[Text].Key = Key end
    end
    UpdateText()

    local Binding = false

    Button.MouseButton1Click:Connect(function()
        Binding = true
        Button.Text = "[ ... ]"
    end)

    Button.MouseButton2Click:Connect(function()
        OpenKeybindMenu(Mode, function(newMode)
            Mode = newMode
            Library.Keybinds[Text].Mode = newMode

            if newMode == "Always On" then
                Active = true
                Library.Keybinds[Text].Active = true
                Callback(true)
            elseif newMode == "Hold" then
                Active = false
                Library.Keybinds[Text].Active = false
                Callback(false)
            end
        end)
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(Input, Processed)
        if Binding then
            if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType == Enum.UserInputType.MouseButton2 then
                local Blacklist = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}
                if table.find(Blacklist, Input.KeyCode) then return end

                Key = Input.KeyCode
                if Key == Enum.KeyCode.Unknown then Key = Input.UserInputType end

                UpdateText()
                Binding = false
            end
            return
        end

        if Processed then return end

        if Mode == "Always On" then return end

        if Input.KeyCode == Key or Input.UserInputType == Key then
            if Mode == "Toggle" then
                Active = not Active
                Library.Keybinds[Text].Active = Active
                Callback(Active)
            elseif Mode == "Hold" then
                Active = true
                Library.Keybinds[Text].Active = true
                Callback(true)
            end
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(Input)
        if Binding then return end
        if Mode == "Always On" then return end

        if Input.KeyCode == Key or Input.UserInputType == Key then
            if Mode == "Hold" then
                Active = false
                Library.Keybinds[Text].Active = false
                Callback(false)
            end
        end
    end)
end

function SectionFunctions:AddSlider(Config)
    local Text = Config.Text or "Slider"
    local Min = Config.Min or 0
    local Max = Config.Max or 100
    local Default = Config.Default or Min
    local Indent = Config.Indent or false
    local Suffix = Config.Suffix or ""
    local Decimals = Config.Decimals or 0
    local Flag = Config.Flag or Text
    local Callback = Config.Callback or function() end

    if Library.Flags[Flag] == nil then Library.Flags[Flag] = Default end

    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    if Indent then
        local p = Instance.new("UIPadding", Frame)
        p.PaddingLeft = UDim.new(0, 20)
    end

    local TitleLabel = Instance.new("TextLabel", Frame)
    TitleLabel.Text = Text
    TitleLabel.FontFace = Library.Font
    TitleLabel.TextSize = 14
    TitleLabel.TextColor3 = Library.TextColor
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, -4)
    TitleLabel.Size = UDim2.new(1, 0, 0, 12)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextStrokeTransparency = 1
    TitleLabel.ZIndex = 11

    local MinusBtn = Instance.new("TextButton", Frame)
    MinusBtn.Size = UDim2.new(0, 10, 0, 10)
    MinusBtn.Position = UDim2.new(0, 0, 0, 12.5)
    MinusBtn.AnchorPoint = Vector2.new(0, 0)
    MinusBtn.BackgroundTransparency = 1
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
    MinusBtn.FontFace = Library.FontBold
    MinusBtn.TextSize = 18
    MinusBtn.TextYAlignment = Enum.TextYAlignment.Center
    MinusBtn.ZIndex = 11
    MinusBtn.AutoButtonColor = false

    local SlideBg = Instance.new("TextButton", Frame)
    SlideBg.Size = UDim2.new(0.85, -24, 0, 6)
    SlideBg.Position = UDim2.new(0, 12, 0, 15)
    SlideBg.Text = ""
    SlideBg.AutoButtonColor = false
    SlideBg.BackgroundColor3 = Color3.new(1,1,1)
    SlideBg.BorderColor3 = Color3.fromRGB(12, 12, 12)
    SlideBg.BorderSizePixel = 1
    SlideBg.ZIndex = 11

    local BgGrad = ApplyGradient(SlideBg, Color3.fromRGB(52, 52, 52), Color3.fromRGB(72, 72, 72))

    local Fill = Instance.new("Frame", SlideBg)
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.ZIndex = 12
    Fill.BackgroundColor3 = Color3.new(1,1,1)

    local FillGrad = Instance.new("UIGradient", Fill)
    FillGrad.Rotation = 90



    local ValueShadow = Instance.new("TextLabel", SlideBg)
    ValueShadow.FontFace = Library.FontBold
    ValueShadow.TextSize = 14
    ValueShadow.TextColor3 = Color3.new(0, 0, 0)
    ValueShadow.BackgroundTransparency = 1
    ValueShadow.Size = UDim2.new(0, 20, 0, 10)
    ValueShadow.TextXAlignment = Enum.TextXAlignment.Center
    ValueShadow.TextStrokeTransparency = 1
    ValueShadow.ZIndex = 12
    ValueShadow.AnchorPoint = Vector2.new(0.5, 0)

    local ValueLabel = Instance.new("TextLabel", SlideBg)
    ValueLabel.FontFace = Library.FontBold
    ValueLabel.TextSize = 14
    ValueLabel.TextColor3 = Library.TextColor
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Size = UDim2.new(0, 20, 0, 10)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Center
    ValueLabel.TextStrokeTransparency = 0
    ValueLabel.ZIndex = 13
    ValueLabel.AnchorPoint = Vector2.new(0.5, 0)

    local Value = Library.Flags[Flag]
    local dragging = false

    local function UpdateFillColor()
        local h, s, v = Library.AccentColor:ToHSV()
        local cTop = Library.AccentColor
        local cBot = Color3.fromHSV(h, s, math.clamp(v * 0.6, 0, 1))

        FillGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, cTop),
            ColorSequenceKeypoint.new(1, cBot)
        }
    end

    table.insert(Library.Registry.AccentFills, { Update = UpdateFillColor })
    UpdateFillColor()

    local function Set(val)
        local num = tonumber(val) or Default
        Value = math.clamp(num, Min, Max)

        local p = 0
        if Max > Min then p = (Value - Min) / (Max - Min) end
        Fill.Size = UDim2.fromScale(p, 1)

        local displayVal = Value
        if Decimals > 0 then
            local power = 10 ^ Decimals
            displayVal = math.round(Value * power) / power
        else
            displayVal = math.round(Value)
        end

        local txt = displayVal .. Suffix
        ValueLabel.Text = txt
        ValueShadow.Text = txt

        ValueLabel.Position = UDim2.new(math.clamp(p, 0, 1), 0, 1, -5)
        ValueShadow.Position = ValueLabel.Position + UDim2.fromOffset(1, 1)

        Library.Flags[Flag] = Value
        Callback(Value)
    end

    Library.Registry[Flag] = { Set = Set }

    SlideBg.MouseEnter:Connect(function()
        BgGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 72, 72)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(92, 92, 92))
        }
    end)
    SlideBg.MouseLeave:Connect(function()
        BgGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 52, 52)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(72, 72, 72))
        }
    end)

    SlideBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local sizeX = SlideBg.AbsoluteSize.X
            local newVal = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / sizeX, 0, 1)
            Set(Min + (newVal * (Max - Min)))
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sizeX = SlideBg.AbsoluteSize.X
            local newVal = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / sizeX, 0, 1)
            Set(Min + (newVal * (Max - Min)))
        end
    end)

    Set(Value)

    local PlusBtn = Instance.new("TextButton", Frame)
    PlusBtn.Size = UDim2.new(0, 10, 0, 10)
    PlusBtn.Position = UDim2.new(0.85, -10, 0, 12.5)
    PlusBtn.AnchorPoint = Vector2.new(0, 0)
    PlusBtn.BackgroundTransparency = 1
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
    PlusBtn.FontFace = Library.FontBold
    PlusBtn.TextSize = 18
    PlusBtn.TextYAlignment = Enum.TextYAlignment.Center
    PlusBtn.ZIndex = 11
    PlusBtn.AutoButtonColor = false

    MinusBtn.MouseButton1Click:Connect(function()
        local step = (Decimals > 0) and (1 / (10 ^ Decimals)) or 1
        Set(math.max(Min, Value - step))
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        local step = (Decimals > 0) and (1 / (10 ^ Decimals)) or 1
        Set(math.min(Max, Value + step))
    end)

    MinusBtn.MouseEnter:Connect(function() MinusBtn.TextColor3 = Library.AccentColor end)
    MinusBtn.MouseLeave:Connect(function() MinusBtn.TextColor3 = Color3.fromRGB(100, 100, 100) end)
    PlusBtn.MouseEnter:Connect(function() PlusBtn.TextColor3 = Library.AccentColor end)
    PlusBtn.MouseLeave:Connect(function() PlusBtn.TextColor3 = Color3.fromRGB(100, 100, 100) end)

    Set(Value)
end

function SectionFunctions:AddDropdown(Config)
    local Text = Config.Text
    local Options = Config.Options or {}
    local Indent = Config.Indent or false
    local Callback = Config.Callback or function() end
    local Flag = Config.Flag or Text or "Dropdown"..math.random(1,9999)
    local Default = Config.Default or Options[1] or ""
    local Search = Config.Search or false

    if Library.Flags[Flag] == nil then Library.Flags[Flag] = Default end

    local showTitle = (Text ~= nil and Text ~= "")
    local frameHeight = showTitle and 38 or 22

    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, frameHeight)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    if Indent then
        local p = Instance.new("UIPadding", Frame)
        p.PaddingLeft = UDim.new(0, 15)
    end

    if showTitle then
        local Label = Instance.new("TextLabel", Frame)
        Label.Text = Text
        Label.FontFace = Library.Font
        Label.TextSize = 13
        Label.TextColor3 = Library.DimTextColor
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 12)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 11
    end

    local Button = Instance.new("TextButton", Frame)
    Button.Size = UDim2.new(0.7, 0, 0, 20)
    Button.Position = showTitle and UDim2.new(0, 0, 0, 14) or UDim2.new(0, 6, 0, -3)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.BackgroundTransparency = 1
    Button.ZIndex = 11

    local BgFrame = Instance.new("Frame", Button)
    BgFrame.Size = UDim2.new(1, 0, 1, 0)
    BgFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BgFrame.BorderSizePixel = 0
    BgFrame.Active = false
    BgFrame.ZIndex = 11

    ApplyGradient(BgFrame, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local OuterStroke = Instance.new("UIStroke", BgFrame)
    OuterStroke.Color = Color3.new(0, 0, 0)
    OuterStroke.Thickness = 1
    OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local InlineFrame = Instance.new("Frame", BgFrame)
    InlineFrame.BackgroundTransparency = 1
    InlineFrame.Size = UDim2.new(1, -2, 1, -2)
    InlineFrame.Position = UDim2.new(0, 1, 0, 1)
    InlineFrame.ZIndex = 12
    local InnerStroke = Instance.new("UIStroke", InlineFrame)
    InnerStroke.Color = Color3.fromHex("#323232")
    InnerStroke.Thickness = 1

    local ValueLabel = Instance.new("TextLabel", Button)
    ValueLabel.Size = UDim2.new(1, -8, 1, 0)
    ValueLabel.Position = UDim2.new(0, 8, 0, -1.5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = ""
    ValueLabel.TextColor3 = Library.TextColor
    ValueLabel.FontFace = Library.Font
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValueLabel.ZIndex = 13
    local Arrow = Instance.new("TextLabel", Button)
    Arrow.Size = UDim2.new(0, 10, 0, 10)
    Arrow.Position = UDim2.new(1, -14, 0.5, -5)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Color3.fromRGB(100, 100, 100)
    Arrow.FontFace = Library.Font
    Arrow.TextSize = 8
    Arrow.TextXAlignment = Enum.TextXAlignment.Center
    Arrow.TextYAlignment = Enum.TextYAlignment.Center
    Arrow.ZIndex = 13

    Button.MouseEnter:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33)) end)
    Button.MouseLeave:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30)) end)
    Button.MouseButton1Down:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(27, 27, 27), Color3.fromRGB(33, 33, 33)) end)
    Button.MouseButton1Up:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33)) end)

    local DropFrame = Instance.new("Frame", DropdownHolder)
    DropFrame.Visible = false
    DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DropFrame.BorderSizePixel = 0
    DropFrame.ZIndex = 2000

    local ListOuterStroke = Instance.new("UIStroke", DropFrame)
    ListOuterStroke.Color = Color3.new(0, 0, 0)
    ListOuterStroke.Thickness = 1
    ListOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ListInner = Instance.new("Frame", DropFrame)
    ListInner.BackgroundTransparency = 1
    ListInner.Size = UDim2.new(1, -2, 1, -2)
    ListInner.Position = UDim2.new(0, 1, 0, 1)
    ListInner.ZIndex = 2002
    ListInner.Active = false
    local ListInnerStroke = Instance.new("UIStroke", ListInner)
    ListInnerStroke.Color = Color3.fromHex("#323232")
    ListInnerStroke.Thickness = 1
    ListInnerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ButtonContainer = Instance.new("Frame", ListInner)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Size = UDim2.new(1, 0, 1, 0)
    ButtonContainer.ZIndex = 2003

    local Pad = Instance.new("UIPadding", ButtonContainer)
    Pad.PaddingTop = UDim.new(0, 0)
    Pad.PaddingBottom = UDim.new(0, 0)

    local DropLayout = Instance.new("UIListLayout", ButtonContainer)
    DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local currentSelection = Library.Flags[Flag]

    local function Set(val)
        if type(val) == "table" then val = Options[1] or "" end
        currentSelection = val
        ValueLabel.Text = " " .. tostring(val)
        Library.Flags[Flag] = val
        Callback(val)
    end

    Library.Registry[Flag] = { Set = Set }

    if type(currentSelection) == "table" then currentSelection = Default end
    Set(currentSelection)

    local function refreshList()
        for _, child in ipairs(ButtonContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for i, opt in ipairs(Options) do
            local b = Instance.new("TextButton", ButtonContainer)
            b.LayoutOrder = i
            b.Size = UDim2.new(1, 0, 0, 18)
            b.BackgroundTransparency = 1

            local TextL = Instance.new("TextLabel", b)
            TextL.Size = UDim2.new(1, 0, 1, 0)
            TextL.Position = UDim2.new(0, 0, 0, -1)
            TextL.BackgroundTransparency = 1
            TextL.Text = "  " .. opt
            TextL.TextXAlignment = Enum.TextXAlignment.Left
            TextL.TextSize = 13
            TextL.TextColor3 = Library.DimTextColor
            TextL.ZIndex = b.ZIndex + 1
            TextL.FontFace = Library.Font

            b.Text = ""
            b.BorderSizePixel = 0
            b.AutoButtonColor = false

            local isHovered = false

            local function UpdateVisuals()
                local isSelected = (opt == currentSelection)

                if isSelected or isHovered then
                    TextL.FontFace = Library.FontBold
                else
                    TextL.FontFace = Library.Font
                end

                if isSelected then
                    TextL.TextColor3 = Library.AccentColor
                else
                    TextL.TextColor3 = Library.DimTextColor
                end

                if isHovered then
                    b.BackgroundTransparency = 0
                    b.BackgroundColor3 = Color3.fromHex("#181818")
                else
                    b.BackgroundTransparency = 1
                end
            end

            UpdateVisuals()

            b.MouseEnter:Connect(function()
                isHovered = true
                UpdateVisuals()
            end)

            b.MouseLeave:Connect(function()
                isHovered = false
                UpdateVisuals()
            end)

            b.MouseButton1Click:Connect(function()
                DropFrame.Visible = false
                Library.ActiveDropdown = nil
                ClickCloser.Visible = false
                if SearchBox then SearchBox.Text = "" end
                Set(opt)
                refreshList()
            end)
        end
    end

    refreshList()

   Button.MouseButton1Click:Connect(function()
        if DropFrame.Visible then
            DropFrame.Visible = false
            Library.ActiveDropdown = nil
            ClickCloser.Visible = false
            Arrow.Rotation = 0
        else
            if Library.ActiveDropdown then
                Library.ActiveDropdown.Visible = false
            end
            Library.ActiveDropdown = DropFrame

            DropFrame.Visible = true
            ClickCloser.Visible = true
            local btnSize = Button.AbsoluteSize
            local dropHeight = Search and (#Options * 18 + 30) or (#Options * 18 + 4)
            DropFrame.Size = UDim2.new(0, btnSize.X - 4, 0, dropHeight)
            DropFrame.Position = UDim2.fromOffset(Button.AbsolutePosition.X + 3, Button.AbsolutePosition.Y + btnSize.Y)

            Arrow.Rotation = 180

            refreshList()
        end
    end)

    RunService.RenderStepped:Connect(function()
        if DropFrame.Visible then
            Arrow.Rotation = 180
        else
            Arrow.Rotation = 0
        end
    end)

    RunService.RenderStepped:Connect(function()
        if DropFrame.Visible then
             local btnSize = Button.AbsoluteSize
             DropFrame.Position = UDim2.fromOffset(Button.AbsolutePosition.X + 3, Button.AbsolutePosition.Y + btnSize.Y)
        end
    end)

    return {
        SetValues = function(self, newValues)
            Options = newValues
            refreshList()
        end
    }
end

function SectionFunctions:AddMultiDropdown(Config)
    local Text = Config.Text
    local Options = Config.Options or {}
    local Indent = Config.Indent or false
    local Flag = Config.Flag or Text or "MultiDropdown"..math.random(1,9999)
    local Callback = Config.Callback or function() end

    if Library.Flags[Flag] == nil then Library.Flags[Flag] = {} end

    local showTitle = (Text ~= nil and Text ~= "")
    local frameHeight = showTitle and 38 or 22

    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, frameHeight)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    if Indent then
        local p = Instance.new("UIPadding", Frame)
        p.PaddingLeft = UDim.new(0, 15)
    end

    if showTitle then
        local Label = Instance.new("TextLabel", Frame)
        Label.Text = Text
        Label.FontFace = Library.Font
        Label.TextSize = 13
        Label.TextColor3 = Library.DimTextColor
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 12)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 11
    end


    local Button = Instance.new("TextButton", Frame)
    Button.Size = UDim2.new(0.7, 0, 0, 20)

    Button.Position = showTitle and UDim2.new(0, 0, 0, 14) or UDim2.new(0, 6, 0, -3)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.ZIndex = 11

    local BgFrame = Instance.new("Frame", Button)
    BgFrame.Size = UDim2.new(1, 0, 1, 0)
    BgFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BgFrame.BorderSizePixel = 0
    BgFrame.Active = false
    BgFrame.ZIndex = 11
    ApplyGradient(BgFrame, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local OuterStroke = Instance.new("UIStroke", BgFrame)
    OuterStroke.Color = Color3.new(0, 0, 0)
    OuterStroke.Thickness = 1
    OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local InlineFrame = Instance.new("Frame", BgFrame)
    InlineFrame.BackgroundTransparency = 1
    InlineFrame.Size = UDim2.new(1, -2, 1, -2)
    InlineFrame.Position = UDim2.new(0, 1, 0, 1)
    InlineFrame.ZIndex = 12
    local InnerStroke = Instance.new("UIStroke", InlineFrame)
    InnerStroke.Color = Color3.fromHex("#323232")
    InnerStroke.Thickness = 1

    local ValueLabel = Instance.new("TextLabel", Button)
    ValueLabel.Size = UDim2.new(1, -8, 1, 0)
    ValueLabel.Position = UDim2.new(0, 8, 0, -2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = ""
    ValueLabel.TextColor3 = Library.TextColor
    ValueLabel.FontFace = Library.Font
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValueLabel.ZIndex = 13

    Button.MouseEnter:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33)) end)
    Button.MouseLeave:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30)) end)
    Button.MouseButton1Down:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(27, 27, 27), Color3.fromRGB(33, 33, 33)) end)
    Button.MouseButton1Up:Connect(function() ApplyGradient(BgFrame, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33)) end)

    local DropFrame = Instance.new("Frame", DropdownHolder)
    DropFrame.Visible = false
    DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DropFrame.BorderSizePixel = 0
    DropFrame.ZIndex = 2000


    local ListOuterStroke = Instance.new("UIStroke", DropFrame)
    ListOuterStroke.Color = Color3.new(0, 0, 0)
    ListOuterStroke.Thickness = 1
    ListOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ListInner = Instance.new("Frame", DropFrame)
    ListInner.BackgroundTransparency = 1
    ListInner.Size = UDim2.new(1, -2, 1, -2)
    ListInner.Position = UDim2.new(0, 1, 0, 1)
    ListInner.ZIndex = 2001
    ListInner.Active = false

    local ListInnerStroke = Instance.new("UIStroke", ListInner)
    ListInnerStroke.Color = Color3.fromHex("#323232")
    ListInnerStroke.Thickness = 1
    ListInnerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border



    local ButtonContainer = Instance.new("Frame", DropFrame)
    ButtonContainer.Name = "Holder"
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Size = UDim2.new(1, -2, 1, -2)
    ButtonContainer.Position = UDim2.new(0, 1, 0, 1)
    ButtonContainer.ZIndex = 2003

    local Pad = Instance.new("UIPadding", ButtonContainer)
    Pad.PaddingTop = UDim.new(0, 0)
    Pad.PaddingBottom = UDim.new(0, 0)

    local DropLayout = Instance.new("UIListLayout", ButtonContainer)
    DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local selectedItems = Library.Flags[Flag] or {}

    local function UpdateDisplay()
        local keys = {}
        for k,v in pairs(selectedItems) do if v then table.insert(keys, k) end end
        local str = table.concat(keys, ", ")
        if str == "" then str = "..." end
        if string.len(str) > 25 then str = string.sub(str, 1, 22) .. "..." end
        ValueLabel.Text = " " .. str
    end

    local function Set(tbl)
        selectedItems = tbl
        Library.Flags[Flag] = tbl
        UpdateDisplay()
        Callback(tbl)
    end

    Library.Registry[Flag] = { Set = Set }
    UpdateDisplay()

    local function refreshList()
        for _, child in ipairs(ButtonContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for i, opt in ipairs(Options) do
            local b = Instance.new("TextButton", ButtonContainer)
            b.LayoutOrder = i
            b.Size = UDim2.new(1, 0, 0, 18)
            b.BackgroundTransparency = 1

            local TextL = Instance.new("TextLabel", b)
            TextL.Size = UDim2.new(1, 0, 1, 0)
            TextL.Position = UDim2.new(0, 0, 0, -1)
            TextL.BackgroundTransparency = 1
            TextL.Text = "  " .. opt
            TextL.TextXAlignment = Enum.TextXAlignment.Left
            TextL.TextSize = 13
            TextL.TextColor3 = Library.DimTextColor
            TextL.ZIndex = b.ZIndex + 1
            TextL.FontFace = Library.Font

            b.Text = ""
            b.BorderSizePixel = 0
            b.AutoButtonColor = false

            local isHovered = false

            local function UpdateVisuals()
                local isSelected = selectedItems[opt]

                if isHovered or isSelected then
                    TextL.FontFace = Library.FontBold
                else
                    TextL.FontFace = Library.Font
                end

                if isSelected then
                    TextL.TextColor3 = Library.AccentColor
                else
                    TextL.TextColor3 = Library.DimTextColor
                end

                if isHovered then
                    b.BackgroundTransparency = 0
                    b.BackgroundColor3 = Color3.fromHex("#181818")
                else
                    b.BackgroundTransparency = 1
                end
            end

            UpdateVisuals()

            b.MouseEnter:Connect(function()
                isHovered = true
                UpdateVisuals()
            end)

            b.MouseLeave:Connect(function()
                isHovered = false
                UpdateVisuals()
            end)

            b.MouseButton1Click:Connect(function()
                if selectedItems[opt] then
                    selectedItems[opt] = nil
                else
                    selectedItems[opt] = true
                end
                Library.Flags[Flag] = selectedItems
                UpdateDisplay()
                Callback(selectedItems)
                UpdateVisuals()
            end)
        end
    end

    refreshList()

    Button.MouseButton1Click:Connect(function()
        if DropFrame.Visible then
            DropFrame.Visible = false
            Library.ActiveDropdown = nil
            ClickCloser.Visible = false
        else
            if Library.ActiveDropdown then Library.ActiveDropdown.Visible = false end
            Library.ActiveDropdown = DropFrame

            DropFrame.Visible = true
            ClickCloser.Visible = true
            local btnSize = Button.AbsoluteSize
            DropFrame.Size = UDim2.new(0, btnSize.X - 4, 0, (#Options * 18) + 4)
            DropFrame.Position = UDim2.fromOffset(Button.AbsolutePosition.X + 3, Button.AbsolutePosition.Y + btnSize.Y)
            refreshList()
        end
    end)

    RunService.RenderStepped:Connect(function()
        if DropFrame.Visible then
             local btnSize = Button.AbsoluteSize
             DropFrame.Position = UDim2.fromOffset(Button.AbsolutePosition.X + 3, Button.AbsolutePosition.Y + btnSize.Y)
        end
    end)
end

function SectionFunctions:AddInputBox(Config)
    local Text = Config.Text or "Input"
    local Default = Config.Default or ""
    local Placeholder = Config.Placeholder or "Type here..."
    local ClearOnFocus = Config.ClearOnFocus or false
    local Flag = Config.Flag or Text
    local Callback = Config.Callback or function() end

    if Library.Flags[Flag] == nil then Library.Flags[Flag] = Default end

    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 24)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    local Box = Instance.new("TextBox", Frame)
    Box.AnchorPoint = Vector2.new(0.5, 0.5)
    Box.Position = UDim2.new(0.5, 0, 0.5, 0)
    Box.Size = UDim2.new(0.75, 0, 0, 18)
    Box.BackgroundColor3 = Color3.fromHex("1a1a1a")
    Box.BorderSizePixel = 0
    Box.Text = Library.Flags[Flag]
    Box.PlaceholderText = Placeholder
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Box.TextColor3 = Library.TextColor
    Box.FontFace = Library.Font
    Box.TextSize = 13
    Box.ZIndex = 11
    Box.TextXAlignment = Enum.TextXAlignment.Center
    Box.ClearTextOnFocus = ClearOnFocus

    local OuterStroke = Instance.new("UIStroke", Box)
    OuterStroke.Name = "OuterStroke"
    OuterStroke.Color = Color3.new(0.000000, 0.000000, 0.000000)
    OuterStroke.Thickness = 1.2
    OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local InlineFrame = Instance.new("Frame", Box)
    InlineFrame.Name = "InlineFrame"
    InlineFrame.BackgroundTransparency = 1
    InlineFrame.BorderSizePixel = 0
    InlineFrame.Size = UDim2.new(1, -2, 1, -2)
    InlineFrame.Position = UDim2.new(0, 1, 0, 1)
    InlineFrame.ZIndex = 12

    local InnerStroke = Instance.new("UIStroke", InlineFrame)
    InnerStroke.Name = "InnerStroke"
    InnerStroke.Color = Color3.fromHex("#323232")
    InnerStroke.Thickness = 1

    Box.FocusLost:Connect(function(enterPressed)
        Library.Flags[Flag] = Box.Text
        Callback(Box.Text, enterPressed)
    end)

    Library.Registry[Flag] = {
        Set = function(val)
            Box.Text = val
            Library.Flags[Flag] = val
            pcall(Callback, val, false)
        end
    }

    return {
        Frame = Frame,
        Box = Box,
        SetText = function(str)
            Box.Text = str
            Library.Flags[Flag] = str
        end,
        GetText = function() return Box.Text end
    }
end

function SectionFunctions:AddListBox(Config)
    local Values = Config.Values or {}
    local Callback = Config.Callback or function() end

    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 300)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    local ListOuter = Instance.new("Frame", Frame)
    ListOuter.AnchorPoint = Vector2.new(0.5, 0)
    ListOuter.Position = UDim2.new(0.5, 0, 0, 5)
    ListOuter.Size = UDim2.new(0.75, 0, 1, -10)
    ListOuter.BackgroundColor3 = Color3.fromHex("#232323")
    ListOuter.BorderColor3 = Color3.new(0.000000, 0.000000, 0.000000)
    ListOuter.BorderSizePixel = 1
    ListOuter.ZIndex = 11

    local Scroller = Instance.new("ScrollingFrame", ListOuter)
    Scroller.BackgroundTransparency = 1
    Scroller.Size = UDim2.new(1, 0, 1, 0)
    Scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroller.ScrollBarThickness = 2
    Scroller.ScrollBarImageColor3 = Library.AccentColor
    Scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroller.BorderSizePixel = 0

    local Layout = Instance.new("UIListLayout", Scroller)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local currentSelected = nil
    local hoveredBtn = nil
    local ButtonObjects = {}

    local function UpdateButtonVisuals(btn, val)
        local isSelected = (currentSelected == val)
        local isHovered = (hoveredBtn == btn)


        if isHovered then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = Color3.fromHex("#181818")
        else
            btn.BackgroundTransparency = 1
        end


        if isHovered or isSelected then
            btn.FontFace = Library.FontBold
        else
            btn.FontFace = Library.Font
        end


        if isSelected then
            btn.TextColor3 = Library.AccentColor
        else
            btn.TextColor3 = Library.DimTextColor
        end
    end


    local function UpdateAll()
        for _, obj in ipairs(ButtonObjects) do
            UpdateButtonVisuals(obj.Btn, obj.Val)
        end
    end

    local function Refresh(newValues)
        for _, c in pairs(Scroller:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        ButtonObjects = {}

        for _, val in ipairs(newValues) do
            local Btn = Instance.new("TextButton", Scroller)
            Btn.Size = UDim2.new(1, 0, 0, 16)
            Btn.BackgroundTransparency = 1
            Btn.Text = "  " .. val
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.TextColor3 = Library.DimTextColor
            Btn.FontFace = Library.Font
            Btn.TextSize = 13
            Btn.ZIndex = 12
            Btn.BorderSizePixel = 0


            Btn.MouseEnter:Connect(function()
                hoveredBtn = Btn
                UpdateButtonVisuals(Btn, val)
            end)

            Btn.MouseLeave:Connect(function()
                hoveredBtn = nil
                UpdateButtonVisuals(Btn, val)
            end)

            Btn.MouseButton1Click:Connect(function()
                currentSelected = val
                UpdateAll()
                Callback(val)
            end)

            table.insert(ButtonObjects, {Btn = Btn, Val = val})
        end
        UpdateAll()
    end

    Refresh(Values)

    return {
        Frame = Frame,
        Refresh = Refresh,
        Get = function() return currentSelected end
    }
end

function SectionFunctions:AddButton(Config)
    local Text = Config.Text or "Button"
    local Callback = Config.Callback or function() end
    local DoubleClick = Config.DoubleClick or false

    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    local Button = Instance.new("TextButton", Frame)
    Button.AnchorPoint = Vector2.new(0.5, 0.5)
    Button.Position = UDim2.new(0.5, 0, 0.5, 0)
    Button.Size = UDim2.new(0.75, 0, 0, 22)
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.ZIndex = 11


    ApplyGradient(Button, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))


    local OuterStroke = Instance.new("UIStroke", Button)
    OuterStroke.Color = Color3.new(0, 0, 0)
    OuterStroke.Thickness = 1
    OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border


    local InlineFrame = Instance.new("Frame", Button)
    InlineFrame.BackgroundTransparency = 1
    InlineFrame.Size = UDim2.new(1, -2, 1, -2)
    InlineFrame.Position = UDim2.new(0, 1, 0, 1)
    InlineFrame.ZIndex = 12
    local InnerStroke = Instance.new("UIStroke", InlineFrame)
    InnerStroke.Color = Color3.fromHex("#323232")
    InnerStroke.Thickness = 1

    local MainLabel = Instance.new("TextLabel", Button)
    MainLabel.BackgroundTransparency = 1
    MainLabel.Size = UDim2.new(1, 0, 1, 0)
    MainLabel.Position = UDim2.new(0, 0, 0, -1)
    MainLabel.Text = Text
    MainLabel.TextColor3 = Color3.fromHex("#d0d0d0")
    MainLabel.FontFace = Library.FontBold
    MainLabel.TextSize = 13
    MainLabel.ZIndex = 14

    Button.MouseEnter:Connect(function()

        ApplyGradient(Button, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
        MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Button.MouseLeave:Connect(function()

        ApplyGradient(Button, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))
        MainLabel.TextColor3 = Color3.fromRGB(205, 205, 205)
    end)

    Button.MouseButton1Down:Connect(function()

        ApplyGradient(Button, Color3.fromRGB(27, 27, 27), Color3.fromRGB(33, 33, 33))
    end)

    Button.MouseButton1Up:Connect(function()
        ApplyGradient(Button, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)

    Button.MouseButton1Click:Connect(function() Callback() end)
end

function SectionFunctions:AddDualButton(Config)
    local LeftText = Config.LeftText or "Button 1"
    local RightText = Config.RightText or "Button 2"
    local LeftCallback = Config.LeftCallback or function() end
    local RightCallback = Config.RightCallback or function() end

    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    local LeftButton = Instance.new("TextButton", Frame)
    LeftButton.AnchorPoint = Vector2.new(0, 0.5)
    LeftButton.Position = UDim2.new(0.125, 0, 0.5, 0)
    LeftButton.Size = UDim2.new(0.355, 0, 0, 22)
    LeftButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LeftButton.BorderSizePixel = 0
    LeftButton.Text = ""
    LeftButton.AutoButtonColor = false
    LeftButton.ZIndex = 11

    ApplyGradient(LeftButton, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local LeftOuterStroke = Instance.new("UIStroke", LeftButton)
    LeftOuterStroke.Color = Color3.new(0, 0, 0)
    LeftOuterStroke.Thickness = 1
    LeftOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local LeftInlineFrame = Instance.new("Frame", LeftButton)
    LeftInlineFrame.BackgroundTransparency = 1
    LeftInlineFrame.Size = UDim2.new(1, -2, 1, -2)
    LeftInlineFrame.Position = UDim2.new(0, 1, 0, 1)
    LeftInlineFrame.ZIndex = 12
    local LeftInnerStroke = Instance.new("UIStroke", LeftInlineFrame)
    LeftInnerStroke.Color = Color3.fromHex("#323232")
    LeftInnerStroke.Thickness = 1

    local LeftLabel = Instance.new("TextLabel", LeftButton)
    LeftLabel.Size = UDim2.new(1, 0, 1, 0)
    LeftLabel.Position = UDim2.new(0, 0, 0, -1)
    LeftLabel.BackgroundTransparency = 1
    LeftLabel.Text = LeftText
    LeftLabel.TextColor3 = Color3.fromHex("#d0d0d0")
    LeftLabel.FontFace = Library.FontBold
    LeftLabel.TextSize = 13
    LeftLabel.ZIndex = 14

    local RightButton = Instance.new("TextButton", Frame)
    RightButton.AnchorPoint = Vector2.new(1, 0.5)
    RightButton.Position = UDim2.new(0.875, 0, 0.5, 0)
    RightButton.Size = UDim2.new(0.355, 0, 0, 22)
    RightButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RightButton.BorderSizePixel = 0
    RightButton.Text = ""
    RightButton.AutoButtonColor = false
    RightButton.ZIndex = 11

    ApplyGradient(RightButton, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))

    local RightOuterStroke = Instance.new("UIStroke", RightButton)
    RightOuterStroke.Color = Color3.new(0, 0, 0)
    RightOuterStroke.Thickness = 1
    RightOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local RightInlineFrame = Instance.new("Frame", RightButton)
    RightInlineFrame.BackgroundTransparency = 1
    RightInlineFrame.Size = UDim2.new(1, -2, 1, -2)
    RightInlineFrame.Position = UDim2.new(0, 1, 0, 1)
    RightInlineFrame.ZIndex = 12
    local RightInnerStroke = Instance.new("UIStroke", RightInlineFrame)
    RightInnerStroke.Color = Color3.fromHex("#323232")
    RightInnerStroke.Thickness = 1

    local RightLabel = Instance.new("TextLabel", RightButton)
    RightLabel.Size = UDim2.new(1, 0, 1, 0)
    RightLabel.Position = UDim2.new(0, 0, 0, -1)
    RightLabel.BackgroundTransparency = 1
    RightLabel.Text = RightText
    RightLabel.TextColor3 = Color3.fromHex("#d0d0d0")
    RightLabel.FontFace = Library.FontBold
    RightLabel.TextSize = 13
    RightLabel.ZIndex = 14

    LeftButton.MouseEnter:Connect(function()
        ApplyGradient(LeftButton, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
        LeftLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    LeftButton.MouseLeave:Connect(function()
        ApplyGradient(LeftButton, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))
        LeftLabel.TextColor3 = Color3.fromRGB(205, 205, 205)
    end)
    LeftButton.MouseButton1Down:Connect(function()
        ApplyGradient(LeftButton, Color3.fromRGB(27, 27, 27), Color3.fromRGB(33, 33, 33))
    end)
    LeftButton.MouseButton1Up:Connect(function()
        ApplyGradient(LeftButton, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)

    RightButton.MouseEnter:Connect(function()
        ApplyGradient(RightButton, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
        RightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    RightButton.MouseLeave:Connect(function()
        ApplyGradient(RightButton, Color3.fromRGB(34, 34, 34), Color3.fromRGB(30, 30, 30))
        RightLabel.TextColor3 = Color3.fromRGB(205, 205, 205)
    end)
    RightButton.MouseButton1Down:Connect(function()
        ApplyGradient(RightButton, Color3.fromRGB(27, 27, 27), Color3.fromRGB(33, 33, 33))
    end)
    RightButton.MouseButton1Up:Connect(function()
        ApplyGradient(RightButton, Color3.fromRGB(39, 39, 39), Color3.fromRGB(33, 33, 33))
    end)

    LeftButton.MouseButton1Click:Connect(function() LeftCallback() end)
    RightButton.MouseButton1Click:Connect(function() RightCallback() end)
end

function SectionFunctions:AddLabel(Config)
    local Text = (type(Config) == "string" and Config) or Config.Text or "Label"
    local TextColor = Config.Color or Library.TextColor

    local Frame = Instance.new("Frame")
    Frame.Name = "Label"
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 20)
    Frame.Parent = self.Container
    Frame.ZIndex = 10

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Text
    Label.FontFace = Library.Font
    Label.TextSize = 14
    Label.TextColor3 = TextColor
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 20, 0, -3)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 11

    local WidgetHolder = Instance.new("Frame", Frame)
    WidgetHolder.BackgroundTransparency = 1
    WidgetHolder.Position = UDim2.new(0, 20, 0, 0)
    WidgetHolder.Size = UDim2.new(1, -20, 1, 0)
    WidgetHolder.ZIndex = 20

    local WidgetLayout = Instance.new("UIListLayout", WidgetHolder)
    WidgetLayout.FillDirection = Enum.FillDirection.Horizontal
    WidgetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    WidgetLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    WidgetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    WidgetLayout.Padding = UDim.new(0, 5)

    local LabelObj = {
        Frame = Frame,
        Label = Label,
        Holder = WidgetHolder,
        SetText = function(self, str) Label.Text = str end
    }

    function LabelObj:AddKeybind(KeyConfig)
        local KeyDefault = KeyConfig.Default or KeyConfig.Key or Enum.KeyCode.Unknown
        local KeyMode = KeyConfig.Mode or "Toggle"
        local KeyCallback = KeyConfig.Callback or function() end
        local Key = KeyDefault
        local TextKey = Text .. ""

        Library.Keybinds[TextKey] = { Key = Key, Mode = KeyMode, Active = false }

        local Wrapper = Instance.new("Frame", self.Holder)
        Wrapper.BackgroundTransparency = 1
        Wrapper.AutomaticSize = Enum.AutomaticSize.X
        Wrapper.Size = UDim2.new(0, 0, 1, 0)
        Wrapper.LayoutOrder = 2

        local BindBtn = Instance.new("TextButton", Wrapper)
        BindBtn.BackgroundTransparency = 1
        BindBtn.AutomaticSize = Enum.AutomaticSize.X
        BindBtn.Size = UDim2.new(0, 0, 0, 9)
        BindBtn.AnchorPoint = Vector2.new(0, 0.5)
        BindBtn.Position = UDim2.new(0, 0, 1, -10)
        BindBtn.FontFace = fonts.fontkb
        BindBtn.TextSize = 8
        BindBtn.TextColor3 = Color3.fromHex("#747474")
        BindBtn.TextStrokeTransparency = 0
        BindBtn.TextStrokeColor3 = Color3.new(0,0,0)
        BindBtn.AutoButtonColor = false
        BindBtn.TextYAlignment = Enum.TextYAlignment.Center

        local function UpdateText()
            local n = keys[Key] or Key.Name
            if Key == Enum.KeyCode.Unknown then n = "None" end
            BindBtn.Text = "[" .. n .. "]"
            if Library.Keybinds[TextKey] then Library.Keybinds[TextKey].Key = Key end
        end
        UpdateText()

        local Binding = false
        BindBtn.MouseButton1Click:Connect(function()
            Binding = true;
            BindBtn.Text = "[...]";
            BindBtn.TextColor3 = Library.AccentColor
        end)

        BindBtn.MouseButton2Click:Connect(function()
            OpenKeybindMenu(KeyMode, function(newMode)
                KeyMode = newMode
                Library.Keybinds[TextKey].Mode = newMode
            end)
        end)

        game:GetService("UserInputService").InputBegan:Connect(function(Input, Processed)
            if Binding then
                if Input.UserInputType == Enum.UserInputType.Keyboard or Input.UserInputType == Enum.UserInputType.MouseButton2 then
                    local Blacklist = {Enum.KeyCode.Unknown, Enum.KeyCode.Escape}
                    if table.find(Blacklist, Input.KeyCode) then return end
                    Key = Input.KeyCode
                    UpdateText()
                    BindBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
                    Binding = false
                end
                return
            end
            if Processed then return end

            if Input.KeyCode == Key then
                local State = (KeyMode == "Toggle" and not Library.Keybinds[TextKey].Active) or true
                Library.Keybinds[TextKey].Active = State
                pcall(KeyCallback, State)
            end
        end)

        game:GetService("UserInputService").InputEnded:Connect(function(Input)
            if Binding then return end
            if Input.KeyCode == Key and KeyMode == "Hold" then
                Library.Keybinds[TextKey].Active = false
                pcall(KeyCallback, false)
            end
        end)
        return self
    end

    function LabelObj:AddColorpicker(ColorConfig)
        ColorConfig = ColorConfig or {}
        local DefaultColor = ColorConfig.Default or Color3.fromRGB(255, 255, 255)
        local CPFlag = ColorConfig.Flag or (Text .. "_Color")
        local Title = ColorConfig.Title or Text
        local ColorCallback = ColorConfig.Callback or function() end

        if Library.Flags[CPFlag] == nil then Library.Flags[CPFlag] = DefaultColor end

        local Wrapper = Instance.new("Frame", self.Holder)
        Wrapper.BackgroundTransparency = 1
        Wrapper.Size = UDim2.new(0, 16, 1, 0)
        Wrapper.LayoutOrder = 1

        local ColorPickerBtn = Instance.new("TextButton", Wrapper)
        ColorPickerBtn.Size = UDim2.new(0, 16, 0, 6)
        ColorPickerBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        ColorPickerBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
        ColorPickerBtn.BackgroundColor3 = Library.Flags[CPFlag]
        ColorPickerBtn.BorderColor3 = Color3.new(0,0,0)
        ColorPickerBtn.BorderSizePixel = 1
        ColorPickerBtn.Text = ""
        ColorPickerBtn.AutoButtonColor = false
        ColorPickerBtn.ZIndex = 12

        ColorPickerBtn.MouseButton1Click:Connect(function()
            OpenColorPicker(ColorPickerBtn, ColorPickerBtn.BackgroundColor3, Title, function(newColor, alpha)
                ColorPickerBtn.BackgroundColor3 = newColor
                Library.Flags[CPFlag] = newColor
                ColorCallback(newColor, alpha)
            end)
        end)

        ColorPickerBtn.MouseButton2Click:Connect(function()
            OpenColorPickerMenu(ColorPickerBtn, function(newColor, alpha)
                ColorPickerBtn.BackgroundColor3 = newColor
                Library.Flags[CPFlag] = newColor
                ColorCallback(newColor, alpha)
            end)
        end)
        return self
    end

    return LabelObj
end

function SectionFunctions:AddPlayerList(Config)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local Library = self.Library

    local Pad = self.Container:FindFirstChild("Pad") or self.Container:FindFirstChildWhichIsA("UIPadding")
    if Pad then
        Pad.PaddingLeft = UDim.new(0, 0)
        Pad.PaddingRight = UDim.new(0, 0)
        Pad.PaddingTop = UDim.new(0, 0)
        Pad.PaddingBottom = UDim.new(0, 0)
    else
        Pad = Instance.new("UIPadding", self.Container)
        Pad.PaddingLeft = UDim.new(0, 0)
        Pad.PaddingRight = UDim.new(0, 0)
    end

    local SectionBox = self.Container.Parent

    local SectionBox = self.Container.Parent

    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchContainer"
    SearchContainer.Parent = SectionBox
    SearchContainer.Size = UDim2.new(1, -2, 0, 25)
    SearchContainer.Position = UDim2.new(0, 1, 0, 0)
    SearchContainer.BackgroundColor3 = Library.SectionColor
    SearchContainer.BorderSizePixel = 0
    SearchContainer.ZIndex = 12

    local SearchDivider = Instance.new("Frame", SearchContainer)
    SearchDivider.Size = UDim2.new(1, 0, 0, 1)
    SearchDivider.Position = UDim2.new(0, 0, 1, -1)
    SearchDivider.BackgroundColor3 = Library.SectionBorder
    SearchDivider.BorderSizePixel = 0
    SearchDivider.ZIndex = 13

local searchQuery = ""

local SearchBox = Instance.new("TextBox", SearchContainer)
SearchBox.Size = UDim2.new(1, -10, 1, -6)
SearchBox.Position = UDim2.new(0, 5, 0, 3)
SearchBox.BackgroundColor3 = Color3.fromHex("1a1a1a")
SearchBox.BorderSizePixel = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search players..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
SearchBox.TextColor3 = Library.TextColor
SearchBox.FontFace = Library.Font
SearchBox.TextSize = 12
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ZIndex = 13
SearchBox.ClearTextOnFocus = false

local SearchBoxPadding = Instance.new("UIPadding", SearchBox)
SearchBoxPadding.PaddingLeft = UDim.new(0, 5)

local SearchOuterStroke = Instance.new("UIStroke", SearchBox)
SearchOuterStroke.Color = Color3.new(0, 0, 0)
SearchOuterStroke.Thickness = 1
SearchOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local SearchInlineFrame = Instance.new("Frame", SearchBox)
SearchInlineFrame.BackgroundTransparency = 1
SearchInlineFrame.Size = UDim2.new(1, -2, 1, -2)
SearchInlineFrame.Position = UDim2.new(0, 1, 0, 1)
SearchInlineFrame.ZIndex = 14
local SearchInnerStroke = Instance.new("UIStroke", SearchInlineFrame)
SearchInnerStroke.Color = Color3.fromHex("#323232")
SearchInnerStroke.Thickness = 1

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchQuery = SearchBox.Text
    Refresh()
end)

    local StatsFrame = Instance.new("Frame")

    local StatsFrame = Instance.new("Frame")
    StatsFrame.Name = "StatsFrame"
    StatsFrame.Parent = SectionBox

    StatsFrame.Size = UDim2.new(1, -2, 0, 100)
    StatsFrame.Position = UDim2.new(0, 1, 1, -100)

    StatsFrame.BackgroundColor3 = Library.SectionColor
    StatsFrame.BorderSizePixel = 0
    StatsFrame.Visible = true
    StatsFrame.ZIndex = 12

    local StatDivider = Instance.new("Frame", StatsFrame)
    StatDivider.Size = UDim2.new(1, 0, 0, 1)
    StatDivider.Position = UDim2.new(0, 0, 0, 0)
    StatDivider.BackgroundColor3 = Library.SectionBorder
    StatDivider.BorderSizePixel = 0
    StatDivider.ZIndex = 13

    self.Container.Size = UDim2.new(1, 0, 1, -125)
    self.Container.Position = UDim2.new(0, 0, 0, 25)

    local StatsPadding = Instance.new("UIPadding", StatsFrame)
    StatsPadding.PaddingTop = UDim.new(0, 0)
    StatsPadding.PaddingLeft = UDim.new(0, 5)
    StatsPadding.PaddingBottom = UDim.new(0, 0)

    local StatsContainer = Instance.new("Frame", StatsFrame)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.Position = UDim2.new(0, 0, 0, 0)
    StatsContainer.Size = UDim2.new(1, 0, 1, 0)
    StatsContainer.ZIndex = 13

    local StatsLayout = Instance.new("UIListLayout", StatsContainer)
    StatsLayout.Padding = UDim.new(0, 0)
    StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateStatLabel(order)
    local container = Instance.new("Frame", StatsContainer)
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 16)
    container.LayoutOrder = order
    container.ZIndex = 14

    local icon = Instance.new("Frame", container)
    icon.Size = UDim2.new(0, 3, 0, 10)
    icon.Position = UDim2.new(0, 0, 0.5, -5)
    icon.BackgroundColor3 = Color3.fromRGB(153, 225, 1)
    icon.BorderSizePixel = 0
    icon.ZIndex = 15

    local lbl = Instance.new("TextLabel", container)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.TextColor3 = Library.DimTextColor
    lbl.FontFace = Library.Font
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 15

    return lbl, icon
end

   local LblHealth, IconHealth = CreateStatLabel(1)
   local LblArmor, IconArmor = CreateStatLabel(2)
   local LblTool, IconTool = CreateStatLabel(3)
   local LblMoney, IconMoney = CreateStatLabel(4)
   local LblWanted, IconWanted = CreateStatLabel(5)
   local LblStatus, IconStatus = CreateStatLabel(6)

    local CurrentSelectedPlr = nil

    local function UpdateStats()
        if CurrentSelectedPlr and CurrentSelectedPlr.Parent then
            local char = CurrentSelectedPlr.Character
            local hum = char and char:FindFirstChild("Humanoid")

if hum then
    LblHealth.Text = string.format("Health: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
    LblHealth.TextColor3 = Library.DimTextColor
else
    LblHealth.Text = "Health: N/A"
    LblHealth.TextColor3 = Library.DimTextColor
end

            local armorVal = 0
            if char then
                local a = char:FindFirstChild("Armor") or char:FindFirstChild("BodyArmor")
                if a and (a:IsA("IntValue") or a:IsA("NumberValue")) then armorVal = a.Value end
            end
            LblArmor.Text = "Armor: " .. armorVal

            local tool = char and char:FindFirstChildWhichIsA("Tool")
            if tool then LblTool.Text = "Tool: " .. tool.Name else LblTool.Text = "Tool: None" end

            local moneyText = "N/A"
            local df = CurrentSelectedPlr:FindFirstChild("DataFolder")
            local currency = df and df:FindFirstChild("Currency")
            if currency then
                moneyText = "$" .. tostring(currency.Value)
            else
                local walletName = "[Wallet]"
                local walletItem = CurrentSelectedPlr.Backpack:FindFirstChild(walletName)
                if not walletItem and char then walletItem = char:FindFirstChild(walletName) end

                if walletItem then
                    local h = walletItem:FindFirstChild("Handle")
                    if h then
                        local bb = h:FindFirstChild("BillboardGui")
                        if bb then
                            local tl = bb:FindFirstChild("TextLabel")
                            if tl and tl.Text ~= "" and tl.Text ~= "???" and tl.Text ~= "Label" then
                                moneyText = tl.Text
                            end
                        end
                    end

                    if moneyText == "N/A" then
                        local valObj = walletItem:FindFirstChild("Value")
                        if valObj then moneyText = "$" .. tostring(valObj.Value) end
                    end
                end
            end
            LblMoney.Text = "Money: " .. moneyText

            local wantedVal = "0"
            local ls = CurrentSelectedPlr:FindFirstChild("leaderstats")
            if ls then
                local w = ls:FindFirstChild("Wanted")
                if w then wantedVal = tostring(w.Value) end
            end
            LblWanted.Text = "Wanted: " .. wantedVal

if hum and hum.Health <= 0 then
    LblStatus.Text = "Status: Dead"
    LblStatus.TextColor3 = Library.DimTextColor
else
    LblStatus.Text = "Status: Alive"
    LblStatus.TextColor3 = Library.DimTextColor
end

if char and (char:GetAttribute("Knocked") == true or char:FindFirstChild("Knocked")) then
    LblStatus.Text = "Status: Knocked"
    LblStatus.TextColor3 = Library.DimTextColor
end
        else
            LblHealth.Text = "Select a player..."
            LblHealth.TextColor3 = Library.DimTextColor
            LblArmor.Text = ""
            LblTool.Text = ""
            LblMoney.Text = ""
            LblWanted.Text = ""
            LblStatus.Text = ""
        end
    end

RunService.RenderStepped:Connect(function()
    self.Container.Size = UDim2.new(1, 0, 1, -125)
    if StatsFrame.Visible then UpdateStats() end
end)

    local function AddPlayerEntry(plr)
        task.spawn(function()
            local Entry = Instance.new("TextButton", self.Container)
            Entry.Name = plr.Name
            Entry.Size = UDim2.new(1, 0, 0, 40)
            Entry.BackgroundColor3 = Library.SectionColor
            Entry.BackgroundTransparency = 0
            Entry.BorderSizePixel = 0
            Entry.AutoButtonColor = false
            Entry.Text = ""
            Entry.ZIndex = 13

            local AvatarImage = Instance.new("ImageLabel", Entry)
            AvatarImage.Size = UDim2.new(0, 32, 0, 32)
            AvatarImage.Position = UDim2.new(0, 8, 0, 4)
            AvatarImage.BackgroundTransparency = 1
            AvatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            AvatarImage.ZIndex = 14

            task.spawn(function()
                local content, isReady = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                if isReady then AvatarImage.Image = content end
            end)

            local DisplayLbl = Instance.new("TextLabel", Entry)
            DisplayLbl.BackgroundTransparency = 1
            DisplayLbl.Position = UDim2.new(0, 50, 0, 4)
            DisplayLbl.Size = UDim2.new(1, -50, 0, 12)
            DisplayLbl.Text = plr.DisplayName
            DisplayLbl.TextColor3 = Color3.new(1,1,1)
            DisplayLbl.FontFace = Library.FontBold
            DisplayLbl.TextSize = 13
            DisplayLbl.TextXAlignment = Enum.TextXAlignment.Left
            DisplayLbl.ZIndex = 14

local NameLbl = Instance.new("TextLabel", Entry)
NameLbl.BackgroundTransparency = 1
NameLbl.Position = UDim2.new(0, 50, 0, 16)
NameLbl.Size = UDim2.new(1, -50, 0, 12)
NameLbl.Text = "@" .. plr.Name
NameLbl.TextColor3 = Library.DimTextColor
NameLbl.FontFace = Library.Font
NameLbl.TextSize = 12
NameLbl.TextXAlignment = Enum.TextXAlignment.Left
NameLbl.ZIndex = 14

            local IdLbl = Instance.new("TextLabel", Entry)
IdLbl.BackgroundTransparency = 1
IdLbl.Position = UDim2.new(0, 50, 0, 28)
IdLbl.Size = UDim2.new(1, -50, 0, 10)
IdLbl.Text = "ID: " .. plr.UserId
IdLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
IdLbl.FontFace = Library.Font
IdLbl.TextSize = 10
IdLbl.TextXAlignment = Enum.TextXAlignment.Left
IdLbl.ZIndex = 14

if plr == LocalPlayer then
    local YouLabel = Instance.new("TextLabel", Entry)
    YouLabel.BackgroundTransparency = 1
    YouLabel.Position = UDim2.new(1, -50, 0, 3)
    YouLabel.Size = UDim2.new(0, 35, 0, 12)
    YouLabel.Text = "YOU"
    YouLabel.TextColor3 = Library.AccentColor
    YouLabel.FontFace = Library.FontBold
    YouLabel.TextSize = 9
    YouLabel.TextXAlignment = Enum.TextXAlignment.Right
    YouLabel.ZIndex = 14

    table.insert(Library.Registry.AccentTexts, YouLabel)
end

            Entry.MouseButton1Click:Connect(function()

            for _, child in pairs(self.Container:GetChildren()) do
        if child:IsA("TextButton") and child ~= Entry then
            child.BackgroundColor3 = Library.SectionColor
        end
    end

            CurrentSelectedPlr = plr
            Entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
       UpdateStats()
    end)

            Entry.MouseButton2Click:Connect(function()
              CurrentSelectedPlr = plr
              SelectedPlayer = plr
              UpdateStats()
              if getgenv().PlayerMenu then
         local m = UserInputService:GetMouseLocation()
         local inset = game:GetService("GuiService"):GetGuiInset()
         getgenv().PlayerMenu.Position = UDim2.fromOffset(m.X + 5, m.Y - inset.Y + 5)
         getgenv().PlayerMenu.Visible = true
         getgenv().ClickCloser.Visible = true
    end
end)

            Entry.MouseEnter:Connect(function()
    if CurrentSelectedPlr ~= plr then
        Entry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
end)

Entry.MouseLeave:Connect(function()
    if CurrentSelectedPlr == plr then
        Entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    else
        Entry.BackgroundColor3 = Library.SectionColor
    end
end)
        end)
    end

local searchQuery = ""

    local function MatchesSearch(player)
        if searchQuery == "" then return true end
        local query = searchQuery:lower()
        return player.Name:lower():find(query) or player.DisplayName:lower():find(query) or tostring(player.UserId):find(query)
    end

local function Refresh()
    for _, c in pairs(self.Container:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if MatchesSearch(p) then
            AddPlayerEntry(p)
        end
    end
end

    Players.PlayerAdded:Connect(Refresh)
    Players.PlayerRemoving:Connect(Refresh)
    Refresh()

    return { Refresh = Refresh }
end

function Library:UpdateNotifyPos()
    local mode = Library.NotifySettings.Anchor
    local x = Library.NotifySettings.OffsetX
    local y = Library.NotifySettings.OffsetY

    if mode == "Top" then
        NotificationHolder.AnchorPoint = Vector2.new(0.5, 0)
        NotificationHolder.Position = UDim2.new(0.5, x, 0, y)
        NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    elseif mode == "Center" then
        NotificationHolder.AnchorPoint = Vector2.new(0.5, 0.5)
        NotificationHolder.Position = UDim2.new(0.5, x, 0.5, y)
        NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    elseif mode == "Bottom" then
        NotificationHolder.AnchorPoint = Vector2.new(0.5, 1)
        NotificationHolder.Position = UDim2.new(0.5, x, 1, -y)
        NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end
end

function Library:Notify(text, duration)
    local Duration = duration or Library.NotifySettings.Duration or 4

    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "NotifyFrame"
    NotifyFrame.Parent = NotificationHolder
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    NotifyFrame.BorderSizePixel = 1
    NotifyFrame.Size = UDim2.new(0, 0, 0, 22)
    NotifyFrame.ClipsDescendants = true
    NotifyFrame.BackgroundTransparency = 1

    local TopLine = Instance.new("Frame", NotifyFrame)
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = Library.AccentColor
    TopLine.BorderSizePixel = 0
    TopLine.ZIndex = 3002
    table.insert(Library.Registry.AccentFills, TopLine)

    local Label = Instance.new("TextLabel", NotifyFrame)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 2)
    Label.Size = UDim2.new(1, 0, 1, -2)
    Label.FontFace = Library.Font
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.ZIndex = 3003

    local TextBounds = game:GetService("TextService"):GetTextSize(
        text,
        13,
        Enum.Font.SourceSans,
        Vector2.new(999, 999)
    )
    local TargetSize = UDim2.new(0, TextBounds.X + 20, 0, 22)

    local TweenIn = TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = TargetSize,
        BackgroundTransparency = 0.1
    })

    local TweenOut = TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 22),
        BackgroundTransparency = 1
    })

    TweenIn:Play()

    task.delay(Duration, function()
        TweenOut:Play()
        TweenOut.Completed:Connect(function()
            NotifyFrame:Destroy()
        end)
    end)
end

function Library:Watermark(Config)
    local Name = Config.Name or "Cheat Name"
    local Enabled = Config.Enabled or true

    local TextService = game:GetService("TextService")
    local OutlineColor = Color3.fromRGB(89, 89, 89)

    local Screen = gethui():FindFirstChild("SkeetWatermark") or Instance.new("ScreenGui", gethui())
    Screen.Name = "SkeetWatermark"
    Screen.Enabled = Enabled
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Library.WatermarkScreen = Screen

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    Main.BorderColor3 = Color3.fromRGB(18, 18, 18)
    Main.BorderSizePixel = 2
    Main.Position = UDim2.new(0.01, 0, 0.01, 0)
    Main.Size = UDim2.new(0, 100, 0, 28)
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true

    local OuterStroke = Instance.new("UIStroke", Main)
    OuterStroke.Color = OutlineColor
    OuterStroke.Thickness = 1.3
    OuterStroke.LineJoinMode = Enum.LineJoinMode.Round
    OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local SIDE_GAP = 2

    local GradientImage = Instance.new("ImageLabel", Main)
    GradientImage.Name = "TopGradient"
    GradientImage.BackgroundTransparency = 1
    GradientImage.BorderSizePixel = 0
    GradientImage.Position = UDim2.new(0, SIDE_GAP, 0, 1)
    GradientImage.Size = UDim2.new(1, -(SIDE_GAP * 2), 0, 2)
    GradientImage.Image = "rbxassetid://8508019876"
    GradientImage.ScaleType = Enum.ScaleType.Stretch
    GradientImage.ZIndex = 4

    local BottomLine = Instance.new("Frame", Main)
    BottomLine.Name = "BottomLine"
    BottomLine.BackgroundColor3 = OutlineColor
    BottomLine.BorderSizePixel = 0
    BottomLine.Position = UDim2.new(0, 0, 0, 4)
    BottomLine.Size = UDim2.new(1, 0, 0, 1)
    BottomLine.ZIndex = 3

    local Label = Instance.new("TextLabel", Main)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 6, 0, 6)
    Label.Size = UDim2.new(1, -12, 0, 18)
    Label.FontFace = Library.Font
    Label.Text = Name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.TextStrokeTransparency = 0
    Label.TextStrokeColor3 = Color3.new(0, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.ZIndex = 5

    RunService.RenderStepped:Connect(function()
        if Screen.Enabled then
            local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))
            local ping = 0
            if game:GetService("Stats").Network then
                ping = math.floor(tonumber(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1]) or 0)
            end

            local text = string.format("%s | %s FPS | %s ms", Name, fps, ping)
            Label.Text = text

            local textSize = TextService:GetTextSize(
                text,
                15,
                Enum.Font.SourceSans,
                Vector2.new(math.huge, math.huge)
            )

            local finalWidth = textSize.X + 20
            Main.Size = UDim2.new(0, finalWidth, 0, 28)
        end
    end)
end

function Library:KeybindList()
    local Screen = gethui():FindFirstChild("SkeetKeybinds") or Instance.new("ScreenGui", gethui())
    Screen.Name = "SkeetKeybinds"
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ShowOnlyActive = false

    local Main = Instance.new("Frame", Screen)
    Main.Name = "KeybindList"
    Main.BackgroundColor3 = Library.SectionColor
    Main.Size = UDim2.new(0, 200, 0, 0)
    Main.Position = UDim2.new(0, 10, 0.4, 0)
    Main.Visible = false
    Main.Active = true
    Main.Draggable = true
    Main.AutomaticSize = Enum.AutomaticSize.Y

    local OuterStroke = Instance.new("UIStroke", Main)
    OuterStroke.Color = Color3.new(0, 0, 0)
    OuterStroke.Thickness = 1
    OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local InlineFrame = Instance.new("Frame", Main)
    InlineFrame.BackgroundTransparency = 1
    InlineFrame.Size = UDim2.new(1, -2, 1, -2)
    InlineFrame.Position = UDim2.new(0, 1, 0, 1)
    InlineFrame.ZIndex = 2

    local InnerStroke = Instance.new("UIStroke", InlineFrame)
    InnerStroke.Color = Library.SectionBorder
    InnerStroke.Thickness = 1

    local topGradientFrame = Instance.new("Frame", Main)
    topGradientFrame.Name = "TopGradient"
    topGradientFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    topGradientFrame.BackgroundTransparency = 0
    topGradientFrame.BorderSizePixel = 0
    topGradientFrame.Position = UDim2.new(0, 1, 0, 0)
    topGradientFrame.Size = UDim2.new(1, -3, 0, 2)
    topGradientFrame.ZIndex = 3

    local gradientImage = Instance.new("ImageLabel", topGradientFrame)
    gradientImage.Name = "gradient"
    gradientImage.BackgroundTransparency = 1
    gradientImage.BorderSizePixel = 0
    gradientImage.Position = UDim2.new(0, 0, 0, 1)
    gradientImage.Size = UDim2.new(1, 0, 1, 0)
    gradientImage.Image = "rbxassetid://8508019876"
    gradientImage.ScaleType = Enum.ScaleType.Stretch
    gradientImage.ZIndex = 3

    local glow = Instance.new("Frame", Main)
    glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.Position = UDim2.new(0, 0, 0, 4)
    glow.Size = UDim2.new(1, 0, 0, 1)
    glow.ZIndex = 4

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 22)
    Title.Position = UDim2.new(0, 0, 0, 3)
    Title.BackgroundTransparency = 1
    Title.Text = "Keybinds"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.FontFace = Library.FontBold
    Title.TextSize = 13
    Title.ZIndex = 4

    local Container = Instance.new("Frame", Main)
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 0, 0, 24)
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.ZIndex = 4

    local Layout = Instance.new("UIListLayout", Container)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pad = Instance.new("UIPadding", Container)
    Pad.PaddingBottom = UDim.new(0, 6)

    RunService.RenderStepped:Connect(function()
        local isEnabled = Library.Flags["Keybind List"]
        if isEnabled == nil then isEnabled = true end

        ShowOnlyActive = Library.Flags["Hide Inactive Keybinds"] or false

        if not isEnabled then
            Main.Visible = false
            return
        end

        for _, c in pairs(Container:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        local hasBinds = false

        for name, data in pairs(Library.Keybinds) do
            if data.Key ~= Enum.KeyCode.Unknown then
                if ShowOnlyActive and not data.Active then
                    continue
                end
                hasBinds = true
                local Row = Instance.new("Frame", Container)
                Row.Size = UDim2.new(1, 0, 0, 18)
                Row.BackgroundTransparency = 1

                local displayColor = data.Active and Library.AccentColor or Library.DimTextColor

                local NameLbl = Instance.new("TextLabel", Row)
                NameLbl.Size = UDim2.new(0.6, -5, 1, 0)
                NameLbl.Position = UDim2.new(0, 8, 0, 0)
                NameLbl.BackgroundTransparency = 1
                NameLbl.Text = name
                NameLbl.TextColor3 = displayColor
                NameLbl.FontFace = Library.Font
                NameLbl.TextSize = 13
                NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                NameLbl.ZIndex = 5

                local keyName = keys[data.Key] or data.Key.Name

                local ModeLbl = Instance.new("TextLabel", Row)
                ModeLbl.Size = UDim2.new(0.4, -5, 1, 0)
                ModeLbl.Position = UDim2.new(0.6, 0, 0, 0)
                ModeLbl.BackgroundTransparency = 1
                ModeLbl.Text = "[" .. data.Mode .. "] [" .. keyName .. "]"
                ModeLbl.TextColor3 = displayColor
                ModeLbl.FontFace = Library.Font
                ModeLbl.TextSize = 13
                ModeLbl.TextXAlignment = Enum.TextXAlignment.Right
                ModeLbl.ZIndex = 5
            end
        end

        Main.Visible = hasBinds
    end)
end
return Library
