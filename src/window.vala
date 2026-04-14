using Gtk;
using Adw;
using GLib;

public class STasksWindow : Adw.ApplicationWindow {
    
    private Gtk.ListBox list_box;
    private Adw.ToastOverlay toast_overlay;
    private Gtk.TextView log_view;
    private Gtk.Expander log_expander;
    private Gtk.ScrolledWindow scroll;
    private Adw.StatusPage empty_state;

    public STasksWindow (Gtk.Application app) {
        Object (application: app, title: "sTasks");
        this.set_default_size (600, 500);

        toast_overlay = new Adw.ToastOverlay ();
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        
        var header = new Adw.HeaderBar ();
        box.append (header);

        var btn_add = new Gtk.Button.from_icon_name ("list-add-symbolic");
        btn_add.tooltip_text = "Add new script";
        header.pack_start (btn_add);
        btn_add.clicked.connect (() => {
            var dialog = new TaskDialog (this);
            dialog.present ();
        });

        var btn_about = new Gtk.Button.from_icon_name ("dialog-information-symbolic");
        btn_about.tooltip_text = "About sTasks";
        header.pack_end (btn_about);
        btn_about.clicked.connect (() => {
            STasks.show_about (this);
        });

        scroll = new Gtk.ScrolledWindow ();
        scroll.vexpand = true;
        
        list_box = new Gtk.ListBox ();
        list_box.margin_top = 24; list_box.margin_bottom = 24;
        list_box.margin_start = 24; list_box.margin_end = 24;
        list_box.add_css_class ("boxed-list");
        list_box.selection_mode = Gtk.SelectionMode.NONE;

        scroll.set_child (list_box);
        box.append (scroll);

        empty_state = new Adw.StatusPage ();
        empty_state.icon_name = "utilities-terminal-symbolic";
        empty_state.title = _("No Tasks Found");
        empty_state.description = _("Click the '+' button to add your first script.");
        empty_state.vexpand = true;
        empty_state.visible = false; 
        box.append (empty_state);

        log_expander = new Gtk.Expander (_("Execution Console"));
        log_expander.margin_start = 12; log_expander.margin_end = 12; log_expander.margin_bottom = 12;

        log_view = new Gtk.TextView ();
        log_view.editable = false;
        log_view.monospace = true;
        log_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        log_view.add_css_class ("view");
        
        var log_scroll = new Gtk.ScrolledWindow ();
        log_scroll.set_size_request (-1, 150);
        log_scroll.set_child (log_view);
        
        log_expander.set_child (log_scroll);
        box.append (log_expander);
        
        toast_overlay.child = box;
        this.content = toast_overlay;

        load_tasks ();
    }

    public void load_tasks () {
        var child = list_box.get_first_child ();
        while (child != null) {
            var next = child.get_next_sibling ();
            list_box.remove (child);
            child = next;
        }

        string stasks_dir = Path.build_filename (Environment.get_user_config_dir (), "sTasks");
        if (!FileUtils.test (stasks_dir, FileTest.EXISTS)) {
            DirUtils.create_with_parents (stasks_dir, 0755);
            extract_default_scripts (stasks_dir);
        }

        int script_count = 0; 
        try {
            var dir = Dir.open (stasks_dir, 0);
            string? filename = null;
            while ((filename = dir.read_name ()) != null) {
                if (filename.has_suffix (".sh")) {
                    add_task_row (filename);
                    script_count++; 
                }
            }
        } catch (Error e) { printerr ("Error: %s\n", e.message); }

        scroll.visible = (script_count > 0);
        empty_state.visible = (script_count == 0);
    }

    private void add_task_row (string filename) {
        var row = new Adw.ActionRow ();
        row.title = filename.replace (".sh", ""); 
        
        var btn_edit = new Gtk.Button.from_icon_name ("document-edit-symbolic");
        btn_edit.valign = Gtk.Align.CENTER;
        btn_edit.add_css_class ("flat");
        btn_edit.tooltip_text = "Edit script";
        btn_edit.clicked.connect (() => {
            var dialog = new TaskDialog (this, filename);
            dialog.present ();
        });

        var btn_delete = new Gtk.Button.from_icon_name ("user-trash-symbolic");
        btn_delete.valign = Gtk.Align.CENTER;
        btn_delete.add_css_class ("flat");
        btn_delete.tooltip_text = _("Delete script");
        btn_delete.clicked.connect (() => { confirm_delete (filename); });

        var spinner = new Gtk.Spinner ();
        spinner.valign = Gtk.Align.CENTER;
        spinner.visible = false; 

        var btn_run = new Gtk.Button.from_icon_name ("media-playback-start-symbolic");
        btn_run.valign = Gtk.Align.CENTER;
        btn_run.add_css_class ("suggested-action");
        btn_run.tooltip_text = _("Run now");
        btn_run.clicked.connect (() => { execute_script (filename, btn_run, spinner); }); 
        
        row.add_suffix (btn_edit);
        row.add_suffix (btn_delete); 
        row.add_suffix (spinner);
        row.add_suffix (btn_run);
        list_box.append (row);
    }

    private void confirm_delete (string filename) {
        string display_name = filename.replace (".sh", "");
        var dialog = new Adw.MessageDialog (this, _("Delete Task?"), _("Are you sure you want to delete '%s'?\nThis action cannot be undone.").printf(display_name));
        
        dialog.add_response ("cancel", "Cancel");
        dialog.add_response ("delete", "Delete");
        dialog.set_response_appearance ("delete", Adw.ResponseAppearance.DESTRUCTIVE); 
        
        dialog.response.connect ((response) => {
            if (response == "delete") {
                string path = Path.build_filename (Environment.get_user_config_dir (), "sTasks", filename);
                if (FileUtils.remove (path) == 0) {
                    toast_overlay.add_toast (new Adw.Toast (_("Task '%s' deleted.").printf(display_name)));
                    load_tasks (); 
                }
            }
        });
        dialog.present ();
    }

    private void extract_default_scripts (string target_dir) {
        try {
            string res_path = "/com/ixsvf/stasks/scripts";
            string[] children = resources_enumerate_children (res_path, ResourceLookupFlags.NONE);
            foreach (string child in children) {
                string full_res_path = res_path + "/" + child;
                string dest_file = Path.build_filename (target_dir, child);
                var bytes = resources_lookup_data (full_res_path, ResourceLookupFlags.NONE);
                FileUtils.set_contents (dest_file, (string) bytes.get_data ());
                FileUtils.chmod (dest_file, 0755); 
            }
        } catch (Error e) { printerr (_("Warning: Could not extract defaults: %s\n"), e.message); }
    }

    private void execute_script (string script_name, Gtk.Button btn_run, Gtk.Spinner spinner) {
        string script_path = Path.build_filename (Environment.get_user_config_dir (), "sTasks", script_name);
        btn_run.visible = false;
        spinner.visible = true;
        spinner.start ();
        log_expander.expanded = true; 
        append_log ("\n--- Running: " + script_name + " ---\n");

        try {
            var subprocess = new Subprocess (SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_PIPE, "/bin/bash", script_path);
            var stdout_stream = new DataInputStream (subprocess.get_stdout_pipe ());
            var stderr_stream = new DataInputStream (subprocess.get_stderr_pipe ());
            read_stream (stdout_stream);
            read_stream (stderr_stream);

            subprocess.wait_check_async.begin (null, (obj, res) => {
                spinner.stop (); spinner.visible = false; btn_run.visible = true;
                try {
                    subprocess.wait_check_async.end (res);
                    append_log ("--- Task completed successfully! ---\n");
                    toast_overlay.add_toast (new Adw.Toast (_("'%s' executed!").printf (script_name)));
                } catch (Error e) { append_log ("--- Error: Script failed ---\n"); }
            });
        } catch (Error e) { 
            spinner.stop (); spinner.visible = false; btn_run.visible = true;
            append_log ("Start failed: " + e.message + "\n"); 
        }
    }

    private void read_stream (DataInputStream stream) {
        stream.read_line_async.begin (Priority.DEFAULT, null, (obj, res) => {
            try {
                size_t length;
                string line = stream.read_line_async.end (res, out length);
                if (line != null) {
                    append_log (line + "\n");
                    read_stream (stream); 
                }
            } catch (Error e) {}
        });
    }

    private void append_log (string text) {
        var buffer = log_view.buffer;
        Gtk.TextIter iter;
        buffer.get_end_iter (out iter);
        buffer.insert (ref iter, text, -1);
        var mark = buffer.create_mark (null, iter, false);
        log_view.scroll_to_mark (mark, 0.0, true, 0.0, 1.0);
    }
}

public class TaskDialog : Adw.Window {
    private STasksWindow parent_window;
    private Gtk.Entry name_entry;
    private Gtk.TextView script_view;

    public TaskDialog (STasksWindow parent, string? filename = null) {
        Object (transient_for: parent, modal: true);
        this.parent_window = parent;
        this.set_default_size (500, 400);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        var header = new Adw.HeaderBar ();
        box.append (header);

        var btn_save = new Gtk.Button.with_label ("Save");
        btn_save.add_css_class ("suggested-action");
        header.pack_end (btn_save);

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        content_box.margin_top = 12; content_box.margin_bottom = 12;
        content_box.margin_start = 12; content_box.margin_end = 12;

        name_entry = new Gtk.Entry ();
        name_entry.placeholder_text = _("Script Name");
        content_box.append (name_entry);

        script_view = new Gtk.TextView ();
        script_view.monospace = true;
        var scroll = new Gtk.ScrolledWindow ();
        scroll.vexpand = true;
        scroll.set_child (script_view);
        scroll.add_css_class ("view");
        content_box.append (scroll);

        box.append (content_box);
        this.content = box;

        if (filename != null) {
            this.title = _("Edit: ") + filename;
            name_entry.text = filename.replace (".sh", "");
            name_entry.sensitive = false; 
            string path = Path.build_filename (Environment.get_user_config_dir (), "sTasks", filename);
            try {
                string content_out; FileUtils.get_contents (path, out content_out);
                script_view.buffer.text = content_out;
            } catch (Error e) { script_view.buffer.text = "# Error loading file"; }
        } else {
            this.title = _("New Task");
            script_view.buffer.text = "#!/bin/bash\n\n";
        }
        btn_save.clicked.connect (save_script);
    }

    private void save_script () {
        string name = name_entry.text.strip ();
        if (name == "") return;
        if (!name.has_suffix (".sh")) name += ".sh";
        Gtk.TextIter start, end;
        script_view.buffer.get_bounds (out start, out end);
        string content = script_view.buffer.get_text (start, end, false);
        string path = Path.build_filename (Environment.get_user_config_dir (), "sTasks", name);
        try {
            FileUtils.set_contents (path, content);
            FileUtils.chmod (path, 0755); 
            parent_window.load_tasks ();
            this.destroy ();
        } catch (Error e) { printerr ("Error: %s\n", e.message); }
    }
}