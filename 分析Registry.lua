--定义Registry类,此类用于管理所有组件类。相当与一张注册表，所有的组件都要在这张表中注册.
--当然不用去显示地注册,newObject会根据组件的名字，自动加载并注册组件。
--实现继承链的辅助类。它是一个组件库，保存所有注册的组件，为继承链中的组件实例化提供帮助。
local Registry = class("Registry")

Registry.classes_ = {}
Registry.objects_ = {}

--注册组件，这里的组件实际上就是一个类，且要派生自Component.
function Registry.add(cls, name)
    assert(type(cls) == "table" and cls.__cname ~= nil, "Registry.add() - invalid class")
    if not name then name = cls.__cname end
    assert(Registry.classes_[name] == nil, string.format("Registry.add() - class \"%s\" already exists", tostring(name)))
    Registry.classes_[name] = cls
end

--删除组件
function Registry.remove(name)
    assert(Registry.classes_[name] ~= nil, string.format("Registry.remove() - class \"%s\" not found", name))
    Registry.classes_[name] = nil
end

function Registry.exists(name)
    return Registry.classes_[name] ~= nil
end

--实例化指定组件，并返回该实例化对象。若指定组件还未加载，则自动加载它。
function Registry.newObject(name, ...)
    local cls = Registry.classes_[name]
    if not cls then
        -- auto load
        pcall(function()
            cls = require(name)
            Registry.add(cls, name)
        end)
    end
    assert(cls ~= nil, string.format("Registry.newObject() - invalid class \"%s\"", tostring(name)))
    return cls.new(...)
end

function Registry.setObject(object, name)
    assert(Registry.objects_[name] == nil, string.format("Registry.setObject() - object \"%s\" already exists", tostring(name)))
    assert(object ~= nil, "Registry.setObject() - object \"%s\" is nil", tostring(name))
    Registry.objects_[name] = object
end

function Registry.getObject(name)
    assert(Registry.objects_[name] ~= nil, string.format("Registry.getObject() - object \"%s\" not exists", tostring(name)))
    return Registry.objects_[name]
end

function Registry.removeObject(name)
    assert(Registry.objects_[name] ~= nil, string.format("Registry.removeObject() - object \"%s\" not exists", tostring(name)))
    Registry.objects_[name] = nil
end

function Registry.isObjectExists(name)
    return Registry.objects_[name] ~= nil
end

return Registry
