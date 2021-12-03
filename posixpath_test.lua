local path = require("posixpath")
local test = require("test")

function test_join()
  test.strings(path.join("/foo", "bar", "/bar", "baz"), "/bar/baz")
  test.strings(path.join("/foo", "bar", "baz"), "/foo/bar/baz")
  test.strings(path.join("/foo/", "bar/", "baz/"), "/foo/bar/baz/")
end

function splitextTest(p, filename, ext)
  test.lists({ path.splitext(p) }, { filename, ext })
  test.lists({ path.splitext("/" .. p) }, { "/" .. filename, ext })
  test.lists({ path.splitext("abc/" .. p) }, { "abc/" .. filename, ext })
  test.lists({ path.splitext("abc.def/" .. p) }, { "abc.def/" .. filename, ext })
  test.lists({ path.splitext("/abc.def/" .. p) }, { "/abc.def/" .. filename, ext })
  test.lists({ path.splitext(p .. "/") }, { filename .. ext .. "/", "" })
end

function test_splitext()
  splitextTest("foo.bar", "foo", ".bar")
  splitextTest("foo.boo.bar", "foo.boo", ".bar")
  splitextTest("foo.boo.biff.bar", "foo.boo.biff", ".bar")
  splitextTest(".csh.rc", ".csh", ".rc")
  splitextTest("nodots", "nodots", "")
  splitextTest(".cshrc", ".cshrc", "")
  splitextTest("...manydots", "...manydots", "")
  splitextTest("...manydots.ext", "...manydots", ".ext")
  splitextTest(".", ".", "")
  splitextTest("..", "..", "")
  splitextTest("........", "........", "")
  splitextTest("", "", "")
end

function test_normpath()
  test.strings(path.normpath(""), ".")
  test.strings(path.normpath("/"), "/")
  test.strings(path.normpath("//"), "//")
  test.strings(path.normpath("///"), "/")
  test.strings(path.normpath("///foo/.//bar//"), "/foo/bar")
  test.strings(path.normpath("///foo/.//bar//.//..//.//baz"), "/foo/baz")
  test.strings(path.normpath("///..//./foo/.//bar"), "/foo/bar")
end

function test_split()
  test.lists({ path.split("/foo/bar") }, { "/foo", "bar" })
  test.lists({ path.split("/") }, { "/", "" })
  test.lists({ path.split("foo") }, { "", "foo" })
  test.lists({ path.split("////foo") }, { "////", "foo" })
  test.lists({ path.split("//foo//bar") }, { "//foo", "bar" })
end

test_join()
test_splitext()
test_normpath()
test_split()
