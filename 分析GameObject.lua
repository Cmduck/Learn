
local Registry = import(".Registry")

local GameObject = {}

--负责为target对象拓展功能，使其能够附加各种组件
--游戏中所有的组件（所有类）都应该实现它。它实现了组件的继承链。
--@参数 target [cocos2dx node对象]
function GameObject.extend(target)
--定义target的组件链
    target.components_ = {}

    --检测组件是否存在
    function target:checkComponent(name)
        return self.components_[name] ~= nil
    end

    --添加组件
    function target:addComponent(name)
        local component = Registry.newObject(name)
        self.components_[name] = component
        component:bind_(self)
        return component
    end

    function target:removeComponent(name)
        local component = self.components_[name]
        if component then component:unbind_() end
        self.components_[name] = nil
    end

    function target:getComponent(name)
        return self.components_[name]
    end

    return target
end

return GameObject


cc.GameObject = import(".GameObject") 
local GameObject = cc.GameObject
local ccmt = {}
ccmt.__call = function(self, target)
    if target then
        return GameObject.extend(target)
    end
    printError("cc() - invalid target")
end
setmetatable(cc, ccmt)