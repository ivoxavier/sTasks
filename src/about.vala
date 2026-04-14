using Gtk;
using Adw;

namespace STasks {
    
    public static void show_about (Gtk.Window parent) {
        var about = new Adw.AboutWindow ();
        
        about.transient_for = parent;
        about.application_name = "sTasks";
        about.developer_name = "Ivo Xavier";
        about.version = "0.0.1";
        about.copyright = "© 2026 Ivo Xavier";
        about.license_type = Gtk.License.MIT_X11;
        
        about.website = "https://github.com/ivoxavier/sTasks";
        about.issue_url = "https://github.com/ivoxavier/sTasks/issues";
        
      
        about.application_icon = "com.ixsvf.stasks"; 
        
        about.present ();
    }
}