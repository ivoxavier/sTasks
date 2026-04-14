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

One of the best ways to contribute is by adding new useful automation scripts to the default collection.

### 1. Create the script file
Add your shell script to the `data/scripts/` directory.

* **Naming:** Use `snake_case` (e.g., `update_flatpaks.sh`).
* **Header:** Ensure the file starts with `#!/bin/bash`.

### 2. Register in GResources
For the application to "see" and extract the script on the first run, you must add it to the resource manifest. 
Open `data/stasks.gresource.xml` and add a new line inside the `<gresource>` tag:

```xml
<file>scripts/your_new_script.sh</file>

## Building and Running

```bash
# Setup the build directory
meson setup build

# Compile the project
meson compile -C build

# Run the application
./build/src/stasks