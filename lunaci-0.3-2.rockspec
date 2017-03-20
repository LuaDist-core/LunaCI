package = "lunaci"
version = "0.3-2"

source = {
    tag = "0.3-2",
    url = "git://github.com/LuaDist-core/LunaCI.git"
}

description = {
    summary = "Automated CI environment for the LuaDist project.",
    homepage = "http://github.com/smasty/LunaCI",
    license = "MIT"
}

supported_platforms = {"unix", "linux"}

dependencies = {
    "lua >= 5.1",
    "penlight >= 1.4",
    "lualogging >= 1.3.0",
}

build = {
    type = "cmake",
}
