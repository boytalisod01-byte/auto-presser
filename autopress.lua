-- STANDALONE AUTO-PRESSER (Space key only - CONTINUOUS WITH CYCLES)
-- 20 second delay before first execution
-- Presses Space continuously for 5 seconds, then waits 3 seconds, then repeats
-- 20ms delay between each press cycle
-- Press P to manually stop/start anytime

local function startAutoPresser()
    print("⏰ Script loaded! Waiting 20 seconds before starting...")
    wait(20)
    print("✅ 20 seconds passed! Starting auto-presser...")

    local autoPressActive = true
    local pressing = false
    local screenGui = nil
    local pressCount = 0
    local cycleCount = 0
    local isCycling = true

    -- Create on-screen display
    local function createDisplay()
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoPressDisplay"
        screenGui.Parent = game:GetService("CoreGui")
        
        -- Main frame
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 320, 0, 155)
        frame.Position = UDim2.new(0.5, -160, 0.85, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        frame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        -- Title
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "🤖 Auto Presser (Space key - Cyclic)"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.GothamBold
        title.Parent = frame
        
        -- Status text
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(1, 0, 0, 30)
        statusText.Position = UDim2.new(0, 0, 0, 28)
        statusText.BackgroundTransparency = 1
        statusText.Text = "✅ ACTIVE (Pressing for 5s)"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusText.TextSize = 14
        statusText.Font = Enum.Font.Gotham
        statusText.Name = "StatusText"
        statusText.Parent = frame
        
        -- Timer display
        local timerText = Instance.new("TextLabel")
        timerText.Size = UDim2.new(1, 0, 0, 25)
        timerText.Position = UDim2.new(0, 0, 0, 50)
        timerText.BackgroundTransparency = 1
        timerText.Text = "⏱️ Pressing: 5s left"
        timerText.TextColor3 = Color3.fromRGB(255, 255, 100)
        timerText.TextSize = 14
        timerText.Font = Enum.Font.GothamBold
        timerText.Name = "TimerText"
        timerText.Parent = frame
        
        -- Press counter display
        local counterText = Instance.new("TextLabel")
        counterText.Size = UDim2.new(1, 0, 0, 25)
        counterText.Position = UDim2.new(0, 0, 0, 72)
        counterText.BackgroundTransparency = 1
        counterText.Text = "📊 Total Presses: 0"
        counterText.TextColor3 = Color3.fromRGB(100, 200, 255)
        counterText.TextSize = 13
        counterText.Font = Enum.Font.Gotham
        counterText.Name = "CounterText"
        counterText.Parent = frame
        
        -- Cycle counter display
        local cycleText = Instance.new("TextLabel")
        cycleText.Size = UDim2.new(1, 0, 0, 20)
        cycleText.Position = UDim2.new(0, 0, 0, 95)
        cycleText.BackgroundTransparency = 1
        cycleText.Text = "🔄 Cycle: 0"
        cycleText.TextColor3 = Color3.fromRGB(200, 150, 255)
        cycleText.TextSize = 12
        cycleText.Font = Enum.Font.Gotham
        cycleText.Name = "CycleText"
        cycleText.Parent = frame
        
        -- Status dot
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.Position = UDim2.new(0, 10, 0, 38)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        dot.BorderSizePixel = 0
        dot.Name = "StatusDot"
        dot.Parent = frame
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        -- Key display
        local keyDisplay = Instance.new("TextLabel")
        keyDisplay.Size = UDim2.new(1, 0, 0, 30)
        keyDisplay.Position = UDim2.new(0, 0, 0, 115)
        keyDisplay.BackgroundTransparency = 1
        keyDisplay.Text = "⚡ PRESSING SPACE..."
        keyDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
        keyDisplay.TextSize = 12
        keyDisplay.Font = Enum.Font.GothamBold
        keyDisplay.Name = "KeyDisplay"
        keyDisplay.Parent = frame
        
        return statusText, dot, keyDisplay, timerText, counterText, cycleText
    end

    -- Update key display
    local function updateKeyDisplay(keyDisplay)
        if keyDisplay then
            keyDisplay.Text = "🔘 PRESSING: SPACE"
            keyDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end

    -- Reset key display
    local function resetKeyDisplay(keyDisplay)
        if keyDisplay then
            keyDisplay.Text = "⚡ PRESSING SPACE..."
            keyDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end

    -- Function to press Space key only
    local function pressSpaceKey()
        -- Press Space
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "Space", false, game)
        
        wait(0.02) -- 20ms hold time
        
        -- Release Space
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "Space", false, game)
    end

    -- Main continuous press function (runs for 5 seconds)
    local function startContinuousPress(keyDisplay, counterText, timerText, statusText, dot, cycleText)
        pressing = true
        local startTime = tick()
        local endTime = startTime + 5 -- 5 seconds of pressing
        
        print("🔴 Cycle " .. (cycleCount + 1) .. " - Pressing Space for 5 seconds (20ms delay)")
        
        while pressing and tick() < endTime do
            -- Calculate remaining time
            local remaining = math.ceil(endTime - tick())
            if timerText then
                timerText.Text = "⏱️ Pressing: " .. remaining .. "s left"
            end
            
            -- Press Space key
            updateKeyDisplay(keyDisplay)
            pressSpaceKey()
            
            pressCount = pressCount + 1
            if counterText then
                counterText.Text = "📊 Total Presses: " .. pressCount
            end
            
            wait(0.02) -- 20ms delay between presses
        end
        
        return pressing
    end

    -- Cycle function (press 5s, wait 3s, repeat)
    local function startCycling(statusText, dot, keyDisplay, timerText, counterText, cycleText)
        isCycling = true
        
        while isCycling and autoPressActive do
            cycleCount = cycleCount + 1
            if cycleText then
                cycleText.Text = "🔄 Cycle: " .. cycleCount
            end
            
            -- Update status to pressing
            if statusText then
                statusText.Text = "✅ PRESSING (Cycle " .. cycleCount .. ")"
                statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
            if dot then
                dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            end
            if keyDisplay then
                keyDisplay.Text = "⚡ PRESSING SPACE..."
                keyDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
            
            -- Press for 5 seconds
            local pressed = startContinuousPress(keyDisplay, counterText, timerText, statusText, dot, cycleText)
            
            -- If stopped manually, break the cycle
            if not pressed or not isCycling then
                break
            end
            
            -- Wait 3 seconds before next cycle
            if isCycling and autoPressActive then
                if statusText then
                    statusText.Text = "⏸ WAITING (3 sec delay before next cycle)"
                    statusText.TextColor3 = Color3.fromRGB(255, 165, 0)
                end
                if dot then
                    dot.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                end
                if timerText then
                    timerText.Text = "⏱️ Waiting: 3s until next press"
                end
                if keyDisplay then
                    keyDisplay.Text = "⏸ Waiting 3 seconds..."
                    keyDisplay.TextColor3 = Color3.fromRGB(255, 165, 0)
                end
                
                print("⏸ Waiting 3 seconds before next cycle...")
                
                -- Countdown for 3 seconds
                for i = 3, 1, -1 do
                    if not isCycling or not autoPressActive then break end
                    if timerText then
                        timerText.Text = "⏱️ Waiting: " .. i .. "s until next press"
                    end
                    wait(1)
                end
                
                wait(0.1) -- Small buffer
            end
        end
    end

    -- Stop function
    local function stopPressing(statusText, dot, keyDisplay, timerText, counterText, cycleText)
        isCycling = false
        pressing = false
        autoPressActive = false
        
        if statusText then
            statusText.Text = "💤 STOPPED (" .. pressCount .. " presses, " .. cycleCount .. " cycles)"
            statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if dot then
            dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        if timerText then
            timerText.Text = "⏱️ Stopped"
            timerText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if keyDisplay then
            keyDisplay.Text = "⏸ Stopped - " .. pressCount .. " Space presses"
            keyDisplay.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        
        print("🟢 Auto-press STOPPED after " .. pressCount .. " Space presses in " .. cycleCount .. " cycles")
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto-Presser",
            Text = "STOPPED! " .. pressCount .. " Space presses in " .. cycleCount .. " cycles",
            Duration = 3
        })
    end

    -- Start function
    local function startPressing(statusText, dot, keyDisplay, timerText, counterText, cycleText)
        if isCycling or pressing then
            stopPressing(statusText, dot, keyDisplay, timerText, counterText, cycleText)
            wait(0.5)
        end
        
        -- Reset variables
        pressCount = 0
        cycleCount = 0
        autoPressActive = true
        pressing = false
        isCycling = true
        
        -- Update UI
        statusText.Text = "✅ ACTIVE (Pressing for 5s)"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        timerText.Text = "⏱️ Pressing: 5s left"
        timerText.TextColor3 = Color3.fromRGB(255, 255, 100)
        counterText.Text = "📊 Total Presses: 0"
        cycleText.Text = "🔄 Cycle: 0"
        keyDisplay.Text = "⚡ PRESSING SPACE..."
        keyDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Start cycling in a separate thread
        spawn(function()
            startCycling(statusText, dot, keyDisplay, timerText, counterText, cycleText)
        end)
        
        print("🔴 Auto-press STARTED - Cycling: 5 seconds press (Space), 3 seconds wait, repeat")
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto-Presser",
            Text = "STARTED! Space: 5s press → 3s wait → repeat | Press P to stop",
            Duration = 3
        })
    end

    -- Initialize the script
    local function initialize()
        local statusText, dot, keyDisplay, timerText, counterText, cycleText = createDisplay()
        
        -- Setup P key toggle
        local UserInputService = game:GetService("UserInputService")
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.P then
                if isCycling or pressing then
                    stopPressing(statusText, dot, keyDisplay, timerText, counterText, cycleText)
                else
                    startPressing(statusText, dot, keyDisplay, timerText, counterText, cycleText)
                end
            end
        end)
        
        -- AUTO-START AFTER 20 SECOND DELAY
        wait(20) -- 20 second delay before starting
        startPressing(statusText, dot, keyDisplay, timerText, counterText, cycleText)
        
        print("====================================")
        print("🤖 Auto-Presser Loaded!")
        print("📌 Pressing: SPACE key only")
        print("⚡ Delay: 20ms between each press cycle")
        print("⏱️ Cycle: 5 seconds press → 3 seconds wait → repeat")
        print("🎮 Press 'P' to manually stop/start")
        print("✅ AUTO-STARTED after 20s delay")
        print("====================================")
    end

    -- Run the script
    initialize()
end

-- Execute the auto-presser
startAutoPresser()
