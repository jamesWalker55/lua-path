local path = require("posixpath")
local test = require("test")

function test_join()
  test.strings(path.join("/foo", "bar", "/bar", "baz"), "/bar/baz")
  test.strings(path.join("/foo", "bar", "baz"), "/foo/bar/baz")
  test.strings(path.join("/foo/", "bar/", "baz/"), "/foo/bar/baz/")
end

test_join()
