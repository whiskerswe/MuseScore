set(ENV{QTDIR} "C:/Qt/6.10.1/msvc2022_64") # or wherever Qt is located
# build_overrides.cmake
set(ENV{QTDIR} "C:/Qt/6.10.1/msvc2022_64") # or wherever Qt is located
set(ENV{PATH} "C:/Qt/6.10.1/msvc2022_64/bin;$ENV{PATH}") # or wherever MinGW's binary directory is located

# build_overrides.cmake
list(APPEND CONFIGURE_ARGS -G Ninja) # build with Ninja