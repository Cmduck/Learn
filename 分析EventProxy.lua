--通过代理注册事件的好处：可以方便的在视图删除时，清理所有通过该代理注册的事件，同时不影响目标对象上注册的其他事件
--EventProxy.new()第一个参数是要注册事件的对象，第二个参数是绑定的视图。如果指定了第二个参数，那么在视图删除时，会自动清理注册的事件.
--实际上还是通过EventProtocol去操作
local EventProxy = class("EventProxy")

function EventProxy:ctor(eventDispatcher, view)
    self.eventDispatcher_ = eventDispatcher
    self.handles_ = {}

    --这里注册了view节点的退出事件,删除所有的事件监听
    --避免了view被注销时，由事件dispatch造成的内存泄露
    if view then
        cc(view):addNodeEventListener(cc.NODE_EVENT, function(event)
            if event.name == "exit" then
                self:removeAllEventListeners()
            end
        end)
    end
end

function EventProxy:addEventListener(eventName, listener, data)
	--这里的self.eventDispatcher对象,实际上是扩展了EventProtocol方法的对象.
	--注意返回的是handle,当前绑定事件的索引
    local handle = self.eventDispatcher_:addEventListener(eventName, listener, data)
    --将事件添加到EventProxy的事件管理器中统一管理
    self.handles_[#self.handles_ + 1] = {eventName, handle}
    return self, handle
end

function EventProxy:removeEventListener(eventHandle)
    if not self.eventDispatcher_ or not self.eventDispatcher_.removeEventListener then
        return self
    end
    self.eventDispatcher_:removeEventListener(eventHandle)
    for index, handle in pairs(self.handles_) do
        if handle[2] == eventHandle then
            table.remove(self.handles_, index)
            break
        end
    end
    return self
end

function EventProxy:removeAllEventListenersForEvent(eventName)
    if not self.eventDispatcher_ or not self.eventDispatcher_.removeEventListenersByEvent then
        return self
    end
    for key, handle in pairs(self.handles_) do
        if handle[1] == eventName then
            self.eventDispatcher_:removeEventListenersByEvent(eventName)
            self.handles_[key] = nil
        end
    end
    return self
end

function EventProxy:getEventHandle(eventName)
    for key, handle in pairs(self.handles_) do
        if handle[1] == eventName then
            return handle[2]
        end
    end
end

function EventProxy:removeAllEventListeners()
    if not self.eventDispatcher_ or not self.eventDispatcher_.removeEventListener then
        return self
    end
    for _, handle in pairs(self.handles_) do
        self.eventDispatcher_:removeEventListener(handle[2])
    end
    self.handles_ = {}
    return self
end

return EventProxy
