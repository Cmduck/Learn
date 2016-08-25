

--组件基类，所有组件都要派生自它
local Component = class("Component")
--lua中的构造函数
--@参数 name      [string]  组件名字
--@参数 depends   [table]   为该组件需要依赖于哪些组件
--当某对象附加该组件时，会自动附加所有depends组件
function Component:ctor(name, depends)
    self.name_ = name
    self.depends_ = checktable(depends)
end

function Component:getName()
    return self.name_
end

function Component:getDepends()
    return self.depends_
end

function Component:getTarget()
    return self.target_
end
--将该组件某些的方法导出到target上
--methods为字符串数组，字符串名字就是函数名.
--有了这套机制，在调用addComponent后接着调用此函数,
--则以后想使用该组件的功能，直接通过target就能调用,无需先获取组件，再调用函数
--@methods      [string table]   需要导出的方法名称数组
function Component:exportMethods_(methods)
    self.exportedMethods_ = methods
    local target = self.target_
    local com = self
    for _, key in ipairs(methods) do
        if not target[key] then
            local m = com[key]
            target[key] = function(__, ...)
                return m(com, ...)
            end
        end
    end
    return self
end
--将该组件绑定到target对象上
function Component:bind_(target)
    self.target_ = target
    for _, name in ipairs(self.depends_) do
        if not target:checkComponent(name) then
            target:addComponent(name)
        end
    end
    self:onBind_(target)
end

--将一个组件解除绑定
function Component:unbind_()
    if self.exportedMethods_ then
        local target = self.target_
        for _, key in ipairs(self.exportedMethods_) do
            target[key] = nil
        end
    end
    self:onUnbind_()
end

function Component:onBind_()
end

function Component:onUnbind_()
end

return Component
