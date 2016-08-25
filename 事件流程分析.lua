jw.EventUtils.create(	self, obj, self, {	{obj.COMPLAT_SHARE_CLICKED, handler(self, self.onListViewItemShareClicked_)	}	}	)

	function EventUtils.create(parent, dispatcher, view, listeners)
	    local listeners = listeners or {}
	    if DEBUG > 0 then
	        EventUtils.debugOnCreate_(parent, dispatcher, view, listeners)
	    end
	    local proxy = cc.EventProxy.new(dispatcher, view)
--[[
    	【
			function EventProxy:ctor(eventDispatcher, view)
			    self.eventDispatcher_ = eventDispatcher
			    self.handles_ = {}

			    if view then
			        cc(view):addNodeEventListener(cc.NODE_EVENT, function(event)
			            if event.name == "exit" then
			                self:removeAllEventListeners()

			                【
								function EventProtocol:removeAllEventListeners()
								    self.listeners_ = {}
								    if DEBUG > 1 then
								        printInfo("%s [EventProtocol] removeAllEventListeners() - remove all listeners", tostring(self.target_))
								    end
								    return self.target_
								end
			                】

			            end
			        end)
			    end
			end
		】
--]]
	    parent.eventProxys__ = parent.eventProxys__ or {}
	    table.insert(parent.eventProxys__, proxy)
	    for _,v in pairs(listeners) do
	        proxy:addEventListener(v[1], v[2])
	        --[[
	        【
	        	function EventProxy:addEventListener(eventName, listener, data)
				    local handle = self.eventDispatcher_:addEventListener(eventName, listener, data)
				    【
				    	function EventProtocol:addEventListener(eventName, listener, tag)
						    assert(type(eventName) == "string" and eventName ~= "",
						        "EventProtocol:addEventListener() - invalid eventName")
						    eventName = string.upper(eventName)
						    if self.listeners_[eventName] == nil then
						        self.listeners_[eventName] = {}
						    end

						    local ttag = type(tag)
						    if ttag == "table" or ttag == "userdata" then
						        PRINT_DEPRECATED("EventProtocol:addEventListener(eventName, listener, target) is deprecated, please use EventProtocol:addEventListener(eventName, handler(target, listener), tag)")
						        listener = handler(tag, listener)
						        tag = ""
						    end

						    self.nextListenerHandleIndex_ = self.nextListenerHandleIndex_ + 1
						    local handle = tostring(self.nextListenerHandleIndex_)
						    tag = tag or ""
						    self.listeners_[eventName][handle] = {listener, tag}

						    if DEBUG > 1 then
						        printInfo("%s [EventProtocol] addEventListener() - event: %s, handle: %s, tag: %s", tostring(self.target_), eventName, handle, tostring(tag))
						    end

						    return handle
						end
				    】

				    self.handles_[#self.handles_ + 1] = {eventName, handle}
				    return self, handle
				end
	        】
	        --]]
	    end
	    return proxy
	end