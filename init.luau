local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BASE_WAIT_TIME = 5

local __RemoteFolder do
    if RunService:IsClient() then 
        __RemoteFolder = ReplicatedStorage:WaitForChild("__RemoteFolder")
    elseif RunService:IsServer() then 
        __RemoteFolder = Instance.new("Folder")
        __RemoteFolder.Name = "__RemoteFolder"
        __RemoteFolder.Parent = ReplicatedStorage

        local __RemoteEvent = Instance.new("Folder")
        __RemoteEvent.Name = "RemoteEvent"
        __RemoteEvent.Parent = __RemoteFolder

        local __RemoteFunction = Instance.new("Folder")
        __RemoteFunction.Name = "RemoteFunction"
        __RemoteFunction.Parent = __RemoteFolder

        local __UnreliableRemoteEvent = Instance.new("Folder")
        __UnreliableRemoteEvent.Name = "UnreliableRemoteEvent"
        __UnreliableRemoteEvent.Parent = __RemoteFolder
    end
end

type NetworkInstance = RemoteEvent & RemoteFunction & UnreliableRemoteEvent

local Remote = {}
export type Remote = typeof(Remote)

-- Server Private
function createRemote(className: string, name: string): NetworkInstance
    local networkingInstance = Instance.new(className) :: NetworkInstance
    networkingInstance.Name = name
    networkingInstance.Parent = __RemoteFolder:FindFirstChild(className)
    print(networkingInstance)
    return networkingInstance
end

function handleRemoteRequest(className: string, name: string): NetworkInstance
    if RunService:IsServer() then
        return __RemoteFolder
            :FindFirstChild(className)
            :FindFirstChild(name) 
            or createRemote(className, name)
    elseif RunService:IsClient() then
        return waitForRemote(className, name)
    end
    error("Code not run on client or server, something has gone terribly wrong!") -- Removes type warning
end

-- Client Private
function waitForRemote(className: string, name: string): NetworkInstance
    local folderOfInstances = __RemoteFolder:FindFirstChild(className)
    print(folderOfInstances)
    local time = 0
    while time < BASE_WAIT_TIME do
        local remoteInstance = folderOfInstances:FindFirstChild(name) :: NetworkInstance
        print(remoteInstance)
        if remoteInstance then
            return remoteInstance
        end
        time += task.wait()
    end
    warn("Infinite yield possible waiting for NetworkInstance " .. name .. " of Class " .. className .. ".")
    while true do
        local remoteInstance = folderOfInstances:FindFirstChild(name) :: NetworkInstance
        if remoteInstance then
            return remoteInstance
        end
        task.wait()
    end
end

function Remote:Event(name: string): RemoteEvent
    return handleRemoteRequest("RemoteEvent", name)
end

function Remote:Function(name: string): RemoteFunction
    return handleRemoteRequest("RemoteFunction", name)
end

function Remote:UnreliableEvent(name: string): UnreliableRemoteEvent
    return handleRemoteRequest("UnreliableRemoteEvent", name)
end

return Remote

