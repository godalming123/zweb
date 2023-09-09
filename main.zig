const std = @import("std");
const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("gtk/gtk.h");
    @cInclude("webkit/webkit.h");
});

fn handlePermissionRequest(_: *c.WebKitWebView, _: *c.WebKitPermissionRequest, window: *c.GtkWindow) callconv(.C) void {
    // TODO: consider not using an alert dialog because most wayland compositors handle them awfully
    // TODO: allow allowing permissions
    const dialog = c.gtk_alert_dialog_new("Allow the website you are using permissions");
    var buttons = [3][*c]const u8{
        "Allow",
        "Deny",
        null,
    };
    c.gtk_alert_dialog_set_buttons(dialog, &buttons[0]);
    c.gtk_alert_dialog_show(dialog, window);
}

fn handleKeypress(_: *c.GtkEventController, keyval: u32, _: u32, state: c.GdkModifierType, web_view: *c.WebKitWebView) callconv(.C) bool {
    // TODO: add keybindings for:
    //  - scrolling up/down/left/right
    //  - going to a specefic URL
    //  - LOTS OF WORK - opening a link in the current/a new window
    //  - LOTS OF WORK - selecting and copying text
    if (state == c.GDK_CONTROL_MASK) {
        switch (keyval) {
            c.GDK_KEY_r => c.webkit_web_view_evaluate_javascript(web_view, "location.reload()", 17, null, null, null, null, null),
            c.GDK_KEY_h => c.webkit_web_view_load_uri(web_view, "file:///home/jg/zweb/home-page.html"),
            c.GDK_KEY_Left => c.webkit_web_view_evaluate_javascript(web_view, "history.go(-1)", 14, null, null, null, null, null),
            c.GDK_KEY_Right => c.webkit_web_view_evaluate_javascript(web_view, "history.go(1)", 13, null, null, null, null, null),
            else => return false,
        }
        return true;
    }
    return false;
}

fn handleDownloadRequest(_: *c.WebKitWebView, _: *c.WebKitDownload, _: *void) callconv(.C) void {
    // TODO: handle downloads
    c.g_print("Website download requested");
}

fn handleWebsiteTitleChange(webView: *c.WebKitWebView, _: *void, window: *c.GtkWindow) callconv(.C) void {
    c.gtk_window_set_title(window, "Zweb: ".* ++ c.webkit_web_view_get_title(@ptrCast(webView))[0..100]);
}

fn handleActivate(app: *c.GtkApplication, _: c.gpointer) callconv(.C) void {
    // Create the window
    const window = @as(*c.GtkWindow, @ptrCast(c.gtk_application_window_new(app)));
    c.gtk_window_set_default_size(window, 800, 500);

    // Create the webview
    const web_view = c.webkit_web_view_new();
    const web_view_event_controller = c.gtk_event_controller_key_new();
    c.gtk_widget_add_controller(web_view, web_view_event_controller);
    // c.gtk_overlay_set_child(@ptrCast(overlay), web_view);
    c.gtk_window_set_child(window, web_view);

    // Handle a few events
    _ = c.g_signal_connect_object(web_view, "permission-request", @as(c.GCallback, @ptrCast(&handlePermissionRequest)), window, 0);
    _ = c.g_signal_connect_object(web_view, "download-request", @as(c.GCallback, @ptrCast(&handleDownloadRequest)), window, 0);
    _ = c.g_signal_connect_object(web_view, "notify::title", @as(c.GCallback, @ptrCast(&handleWebsiteTitleChange)), window, 0);
    _ = c.g_signal_connect_object(web_view_event_controller, "key-pressed", @as(c.GCallback, @ptrCast(&handleKeypress)), web_view, 0);

    // TODO: handle permant data storage
    // TODO: when you hover a link show what URL it points to
    // TODO: add an ad/tracker blocker

    // Load the starting page
    c.webkit_web_view_load_uri(@as(*c.WebKitWebView, @ptrCast(web_view)), "file:///home/jg/zweb/home-page.html");

    // Show window
    c.gtk_window_present(window);
}

pub fn main() !void {
    const app = c.gtk_application_new("org.zig.web", c.G_APPLICATION_FLAGS_NONE);
    _ = c.g_signal_connect_data(app, "activate", @as(c.GCallback, @ptrCast(&handleActivate)), null, null, 0);
    _ = c.g_application_run(@as(*c.GApplication, @ptrCast(app)), 0, null);
}
