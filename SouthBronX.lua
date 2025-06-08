-- Script Tween Waypoint + UI + Durasi + Delay + Simulasi E + Tekan Tombol 3 + Keybind
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local waypoint1 = Vector3.new(-551.7, 3.5, -86.1)
local waypoint2 = Vector3.new(-401.3, 3.4, -71.3)
local tweenSpeed = 20 -- Kecepatan default dalam unit/detik
local delayStop = 2
local isTweening = false
local tweenLoop = false
local currentTween = nil

-- Tween ke posisi tertentu dengan kecepatan tertentu
function startTween(position)
    if isTweening then return end
    isTweening = true

    local distance = (hrp.Position - position).magnitude
    local duration = distance / tweenSpeed -- Durasi berdasarkan kecepatan
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(position)}

    currentTween = TweenService:Create(hrp, tweenInfo, goal)
    currentTween:Play()
    currentTween.Completed:Wait()

    isTweening = false
end

-- Simulasi tekan tombol E
local function simulateEKeypress(duration)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(duration)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Simulasi tekan tombol angka 3
local function simulate3Keypress()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
end

-- Tween loop bolak-balik + delay + E + tekan tombol 3 saat ke waypoint2
function startTweenLoop()
    while tweenLoop do
        startTween(waypoint1)
        if not tweenLoop then break end

        task.wait(0.1)
        simulateEKeypress(delayStop)
        task.wait(delayStop)

        simulate3Keypress()
        startTween(waypoint2)
        if not tweenLoop then break end

        task.wait(0.1)
        simulateEKeypress(delayStop)
        task.wait(delayStop)
    end
end

-- UI
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TweenWaypointUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 300)
    frame.Position = UDim2.new(1, -210, 1, -310)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = frame

    local function createButton(text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Position = UDim2.new(0, 5, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = text
        button.Parent = frame
        button.MouseButton1Click:Connect(callback)
        return button
    end

    local function createLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 30)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Text = text
        label.Parent = frame
        return label
    end

    local function createTextBox(placeholder, callback)
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(1, -10, 0, 30)
        textBox.Position = UDim2.new(0, 5, 0, 0)
        textBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textBox.PlaceholderText = placeholder
        textBox.Parent = frame
        textBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                callback(textBox.Text)
            end
        end)
        return textBox
    end

    createLabel("Tween Waypoint Controller")

    createButton("Set Waypoint 1", function()
        waypoint1 = hrp.Position
        print("Waypoint 1 disimpan:", waypoint1)
    end)

    createButton("Set Waypoint 2", function()
        waypoint2 = hrp.Position
        print("Waypoint 2 disimpan:", waypoint2)
    end)

    createButton("Tween ke Waypoint 1", function()
        if waypoint1 then
            startTween(waypoint1)
        else
            warn("Waypoint 1 belum di-set!")
        end
    end)

    createButton("Tween ke Waypoint 2", function()
        if waypoint2 then
            startTween(waypoint2)
        else
            warn("Waypoint 2 belum di-set!")
        end
    end)

    createButton("Start Tween Loop", function()
        if waypoint1 and waypoint2 then
            tweenLoop = true
            coroutine.wrap(startTweenLoop)()
        else
            warn("Set kedua waypoint dulu!")
        end
    end)

    createButton("Stop Tween", function()
        tweenLoop = false
        if currentTween then currentTween:Cancel() end
    end)

    createTextBox("Kecepatan Tween (unit/detik)", function(text)
        local speed = tonumber(text)
        if speed and speed > 0 then
            tweenSpeed = speed
            print("Kecepatan tween diatur ke:", tweenSpeed, "unit/detik")
        else
            warn("Masukkan angka yang valid (misal: 50)")
        end
    end)

    createTextBox("Delay Stop (detik)", function(text)
        local delay = tonumber(text)
        if delay and delay >= 0 then
            delayStop = delay
            print("Delay stop diatur ke:", delayStop, "detik")
        else
            warn("Masukkan angka yang valid (misal: 2)")
        end
    end)
end

-- Jalankan UI
createUI()

-- Keybind 1 dan 2 untuk manual tween
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.One then
        if waypoint1 then
            startTween(waypoint1)
        else
            warn("Waypoint 1 belum diset!")
        end
    elseif input.KeyCode == Enum.KeyCode.Two then
        if waypoint2 then
            startTween(waypoint2)
        else
            warn("Waypoint 2 belum diset!")
        end
    end
end)
