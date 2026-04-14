using Gtk;
using Adw;
using GLib;

int main (string[] args) {
  
    Intl.setlocale (LocaleCategory.ALL, "");


    string local_path = Path.build_filename (Environment.get_current_dir (), "build", "po");
    
    
    if (FileUtils.test (local_path, FileTest.EXISTS)) {
        Intl.bindtextdomain ("stasks", local_path);
    } else {
    
        Intl.bindtextdomain ("stasks", "/usr/share/locale");
    }

    Intl.bind_textdomain_codeset ("stasks", "UTF-8");
    Intl.textdomain ("stasks");

    var app = new Adw.Application ("com.ixsvf.stasks", GLib.ApplicationFlags.FLAGS_NONE);
    
    app.startup.connect (() => {
        var display = Gdk.Display.get_default ();
        var icon_theme = Gtk.IconTheme.get_for_display (display);
        icon_theme.add_resource_path ("/com/ixsvf/stasks/icons");
    });
    
    app.activate.connect (() => {
        var window = new STasksWindow (app);
        window.present ();
    });
    
    return app.run (args);
}