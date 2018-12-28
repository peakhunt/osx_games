--
-- a set of script to test lua/objective-c binding
--

function hello_world()
  print("Hello World")
end

function give_me_string(v1)
  print("got " .. v1 .. " from objective-c")
  return "This is your string!"
end

function callback_test(obj, str)
  print("running callback_test: " .. str)
  obj:helloWorld_(str)
end

function direct_property_access(obj)
  obj._label:setStringValue_("Label Set From Lua!")
end
