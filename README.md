# sTasks

**A modern, lightweight script and task manager for the GNOME Desktop.**

sTasks is a simple utility designed to organize, edit, and execute your favorite shell scripts through a clean and native GTK4/Libadwaita interface. Built with Vala, it follows the Ubuntu Yaru design language and integrates seamlessly with the GNOME ecosystem.

---

##  Requirements

To build sTasks from source, you will need:
- `valac`
- `meson` and `ninja`
- `libadwaita-1` (>= 1.4)
- `gtk4`
- `gettext`

---

## Building and Running

```bash
# Setup the build directory
meson setup build

# Compile the project
meson compile -C build

# Run the application
./build/src/stasks