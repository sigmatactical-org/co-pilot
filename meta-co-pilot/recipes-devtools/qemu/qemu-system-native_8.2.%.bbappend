# co-pilot-qemu needs a display backend for runqemu (gtk/sdl).
PACKAGECONFIG:append = " sdl"
DEPENDS:append = " libsdl2-native"
