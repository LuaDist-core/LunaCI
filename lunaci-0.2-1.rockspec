package = "lunaci"
version = "0.2-1"

source = {
    tag = "0.2-1",
    url = "git://github.com/smasty/LunaCI.git"
}

description = {
    summary = "Automated CI environment for the LuaDist project.",
    homepage = "http://github.com/smasty/LunaCI",
    license = "MIT"
}

supported_platforms = {"unix", "linux"}

dependencies = {
    "lua >= 5.1",
    "penlight >= 1.3.3.luadist",
    "lualogging >= 1.3.0",
}

build = {
    type = "cmake",
}
