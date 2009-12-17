/* tray.c generated by valac, the Vala compiler
 * generated from tray.vala, do not modify */

/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * tray.vala
 * Copyright (C) Pontus Östlund 2009 <pontus@poppa.se>
 *
 * This file is part of Roxen Application Launcher (RAL)
 * 
 * RAL is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * RAL is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with RAL.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <stdlib.h>
#include <string.h>
#include <glib/gi18n-lib.h>
#include <gee.h>
#include <gdk-pixbuf/gdk-pixdata.h>


#define ROXENLAUNCHER_TYPE_TRAY (roxenlauncher_tray_get_type ())
#define ROXENLAUNCHER_TRAY(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), ROXENLAUNCHER_TYPE_TRAY, RoxenlauncherTray))
#define ROXENLAUNCHER_TRAY_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), ROXENLAUNCHER_TYPE_TRAY, RoxenlauncherTrayClass))
#define ROXENLAUNCHER_IS_TRAY(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), ROXENLAUNCHER_TYPE_TRAY))
#define ROXENLAUNCHER_IS_TRAY_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), ROXENLAUNCHER_TYPE_TRAY))
#define ROXENLAUNCHER_TRAY_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), ROXENLAUNCHER_TYPE_TRAY, RoxenlauncherTrayClass))

typedef struct _RoxenlauncherTray RoxenlauncherTray;
typedef struct _RoxenlauncherTrayClass RoxenlauncherTrayClass;
typedef struct _RoxenlauncherTrayPrivate RoxenlauncherTrayPrivate;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))

#define ROXENLAUNCHER_TYPE_MAIN_WINDOW (roxenlauncher_main_window_get_type ())
#define ROXENLAUNCHER_MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), ROXENLAUNCHER_TYPE_MAIN_WINDOW, RoxenlauncherMainWindow))
#define ROXENLAUNCHER_MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), ROXENLAUNCHER_TYPE_MAIN_WINDOW, RoxenlauncherMainWindowClass))
#define ROXENLAUNCHER_IS_MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), ROXENLAUNCHER_TYPE_MAIN_WINDOW))
#define ROXENLAUNCHER_IS_MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), ROXENLAUNCHER_TYPE_MAIN_WINDOW))
#define ROXENLAUNCHER_MAIN_WINDOW_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), ROXENLAUNCHER_TYPE_MAIN_WINDOW, RoxenlauncherMainWindowClass))

typedef struct _RoxenlauncherMainWindow RoxenlauncherMainWindow;
typedef struct _RoxenlauncherMainWindowClass RoxenlauncherMainWindowClass;

#define TYPE_LAUNCHER_FILE (launcher_file_get_type ())
#define LAUNCHER_FILE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_LAUNCHER_FILE, LauncherFile))
#define LAUNCHER_FILE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_LAUNCHER_FILE, LauncherFileClass))
#define IS_LAUNCHER_FILE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_LAUNCHER_FILE))
#define IS_LAUNCHER_FILE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_LAUNCHER_FILE))
#define LAUNCHER_FILE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_LAUNCHER_FILE, LauncherFileClass))

typedef struct _LauncherFile LauncherFile;
typedef struct _LauncherFileClass LauncherFileClass;

#define LAUNCHER_FILE_TYPE_STATUSES (launcher_file_statuses_get_type ())
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))

struct _RoxenlauncherTray {
	GObject parent_instance;
	RoxenlauncherTrayPrivate * priv;
};

struct _RoxenlauncherTrayClass {
	GObjectClass parent_class;
};

struct _RoxenlauncherTrayPrivate {
	GtkStatusIcon* icon;
	GtkMenu* popmenu;
	char* m_show;
	char* m_hide;
	char* t_show;
	char* t_hide;
};

typedef enum  {
	LAUNCHER_FILE_STATUSES_DUMMY_STATUS,
	LAUNCHER_FILE_STATUSES_NOT_DOWNLOADED,
	LAUNCHER_FILE_STATUSES_DOWNLOADED,
	LAUNCHER_FILE_STATUSES_UPLOADED,
	LAUNCHER_FILE_STATUSES_NOT_UPLOADED,
	LAUNCHER_FILE_STATUSES_DOWNLOADING,
	LAUNCHER_FILE_STATUSES_UPLOADING,
	LAUNCHER_FILE_STATUSES_NOT_CHANGED
} LauncherFileStatuses;


extern RoxenlauncherMainWindow* win;
static gpointer roxenlauncher_tray_parent_class = NULL;

GType roxenlauncher_tray_get_type (void);
#define ROXENLAUNCHER_TRAY_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), ROXENLAUNCHER_TYPE_TRAY, RoxenlauncherTrayPrivate))
enum  {
	ROXENLAUNCHER_TRAY_DUMMY_PROPERTY
};
static void roxenlauncher_tray_on_trayicon_popup (RoxenlauncherTray* self, guint btn, guint time);
static void _roxenlauncher_tray_on_trayicon_popup_gtk_status_icon_popup_menu (GtkStatusIcon* _sender, guint button, guint activate_time, gpointer self);
static void roxenlauncher_tray_set_window_visibility (RoxenlauncherTray* self);
static void _roxenlauncher_tray_set_window_visibility_gtk_status_icon_activate (GtkStatusIcon* _sender, gpointer self);
void roxenlauncher_tray_hookup (RoxenlauncherTray* self);
void roxenlauncher_tray_set_blinking (RoxenlauncherTray* self, gboolean val);
GType roxenlauncher_main_window_get_type (void);
GtkWindow* roxenlauncher_main_window_get_window (RoxenlauncherMainWindow* self);
GType launcher_file_get_type (void);
GeeArrayList* launcher_file_get_reversed_files (void);
gint launcher_file_get_status (LauncherFile* self);
static GType launcher_file_statuses_get_type (void);
char* launcher_file_get_uri (LauncherFile* self);
LauncherFile* launcher_file_find_by_uri (const char* uri);
void launcher_file_download (LauncherFile* self, gboolean do_launch_editor);
static void _lambda11_ (GtkMenuItem* widget, RoxenlauncherTray* self);
static void __lambda11__gtk_menu_item_activate (GtkMenuItem* _sender, gpointer self);
void roxenlauncher_main_window_finish_all_files (RoxenlauncherMainWindow* self);
static gboolean _lambda13_ (RoxenlauncherTray* self);
static gboolean __lambda13__gsource_func (gpointer self);
static void _lambda12_ (RoxenlauncherTray* self);
static void __lambda12__gtk_menu_item_activate (GtkImageMenuItem* _sender, gpointer self);
void roxenlauncher_main_window_on_window_destroy (RoxenlauncherMainWindow* self);
static void _roxenlauncher_main_window_on_window_destroy_gtk_menu_item_activate (GtkImageMenuItem* _sender, gpointer self);
static void _roxenlauncher_tray_set_window_visibility_gtk_menu_item_activate (GtkImageMenuItem* _sender, gpointer self);
RoxenlauncherTray* roxenlauncher_tray_new (void);
RoxenlauncherTray* roxenlauncher_tray_construct (GType object_type);
char* roxenlauncher_get_ui_path (const char* local_path);
static GObject * roxenlauncher_tray_constructor (GType type, guint n_construct_properties, GObjectConstructParam * construct_properties);
static void roxenlauncher_tray_finalize (GObject* obj);



static void _roxenlauncher_tray_on_trayicon_popup_gtk_status_icon_popup_menu (GtkStatusIcon* _sender, guint button, guint activate_time, gpointer self) {
	roxenlauncher_tray_on_trayicon_popup (self, button, activate_time);
}


static void _roxenlauncher_tray_set_window_visibility_gtk_status_icon_activate (GtkStatusIcon* _sender, gpointer self) {
	roxenlauncher_tray_set_window_visibility (self);
}


void roxenlauncher_tray_hookup (RoxenlauncherTray* self) {
	g_return_if_fail (self != NULL);
	g_signal_connect_object (self->priv->icon, "popup-menu", (GCallback) _roxenlauncher_tray_on_trayicon_popup_gtk_status_icon_popup_menu, self, 0);
	g_signal_connect_object (self->priv->icon, "activate", (GCallback) _roxenlauncher_tray_set_window_visibility_gtk_status_icon_activate, self, 0);
	gtk_status_icon_set_visible (self->priv->icon, TRUE);
}


void roxenlauncher_tray_set_blinking (RoxenlauncherTray* self, gboolean val) {
	g_return_if_fail (self != NULL);
	gtk_status_icon_set_blinking (self->priv->icon, val);
}


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static void _lambda11_ (GtkMenuItem* widget, RoxenlauncherTray* self) {
	GError * _inner_error_;
	g_return_if_fail (widget != NULL);
	_inner_error_ = NULL;
	{
		LauncherFile* f;
		f = launcher_file_find_by_uri (gtk_menu_item_get_label (GTK_MENU_ITEM (widget)));
		if (f != NULL) {
			launcher_file_download (f, TRUE);
		}
		_g_object_unref0 (f);
	}
	goto __finally23;
	__catch23_g_error:
	{
		GError * e;
		e = _inner_error_;
		_inner_error_ = NULL;
		{
			g_warning ("tray.vala:103: Error calling download: %s", e->message);
			_g_error_free0 (e);
		}
	}
	__finally23:
	if (_inner_error_ != NULL) {
		g_critical ("file %s: line %d: uncaught error: %s", __FILE__, __LINE__, _inner_error_->message);
		g_clear_error (&_inner_error_);
		return;
	}
}


static void __lambda11__gtk_menu_item_activate (GtkMenuItem* _sender, gpointer self) {
	_lambda11_ (_sender, self);
}


static gboolean _lambda13_ (RoxenlauncherTray* self) {
	gboolean result;
	roxenlauncher_main_window_finish_all_files (win);
	result = FALSE;
	return result;
}


static gboolean __lambda13__gsource_func (gpointer self) {
	return _lambda13_ (self);
}


static void _lambda12_ (RoxenlauncherTray* self) {
	g_idle_add_full (G_PRIORITY_DEFAULT_IDLE, __lambda13__gsource_func, g_object_ref (self), g_object_unref);
	gtk_menu_popdown (self->priv->popmenu);
}


static void __lambda12__gtk_menu_item_activate (GtkImageMenuItem* _sender, gpointer self) {
	_lambda12_ (self);
}


static void _roxenlauncher_main_window_on_window_destroy_gtk_menu_item_activate (GtkImageMenuItem* _sender, gpointer self) {
	roxenlauncher_main_window_on_window_destroy (self);
}


static void _roxenlauncher_tray_set_window_visibility_gtk_menu_item_activate (GtkImageMenuItem* _sender, gpointer self) {
	roxenlauncher_tray_set_window_visibility (self);
}


static void roxenlauncher_tray_on_trayicon_popup (RoxenlauncherTray* self, guint btn, guint time) {
	GtkWindow* _tmp0_;
	gboolean _tmp1_;
	gboolean visible;
	GtkMenu* _tmp2_;
	GtkImageMenuItem* item_quit;
	GtkImage* img_hide;
	GtkImage* img_show;
	const char* _tmp3_;
	GtkImageMenuItem* item_toggle;
	GtkImage* _tmp4_;
	GeeArrayList* lfs;
	GtkImageMenuItem* finish_all;
	GtkSeparatorMenuItem* _tmp11_;
	g_return_if_fail (self != NULL);
	visible = (_tmp1_ = gtk_widget_get_visible ((GtkWidget*) (_tmp0_ = roxenlauncher_main_window_get_window (win))), _g_object_unref0 (_tmp0_), _tmp1_);
	self->priv->popmenu = (_tmp2_ = g_object_ref_sink ((GtkMenu*) gtk_menu_new ()), _g_object_unref0 (self->priv->popmenu), _tmp2_);
	item_quit = g_object_ref_sink ((GtkImageMenuItem*) gtk_image_menu_item_new_from_stock (GTK_STOCK_QUIT, NULL));
	img_hide = g_object_ref_sink ((GtkImage*) gtk_image_new_from_stock (GTK_STOCK_CLOSE, GTK_ICON_SIZE_MENU));
	img_show = g_object_ref_sink ((GtkImage*) gtk_image_new_from_stock (GTK_STOCK_OPEN, GTK_ICON_SIZE_MENU));
	_tmp3_ = NULL;
	if (visible) {
		_tmp3_ = self->priv->t_hide;
	} else {
		_tmp3_ = self->priv->t_show;
	}
	item_toggle = g_object_ref_sink ((GtkImageMenuItem*) gtk_image_menu_item_new_with_label (_tmp3_));
	_tmp4_ = NULL;
	if (visible) {
		_tmp4_ = img_hide;
	} else {
		_tmp4_ = img_show;
	}
	gtk_image_menu_item_set_image (item_toggle, (GtkWidget*) _tmp4_);
	lfs = launcher_file_get_reversed_files ();
	if (gee_collection_get_size ((GeeCollection*) lfs) == 0) {
		GtkMenuItem* mi;
		mi = g_object_ref_sink ((GtkMenuItem*) gtk_menu_item_new_with_label (_ ("No active files")));
		gtk_widget_set_sensitive ((GtkWidget*) mi, FALSE);
		gtk_container_add ((GtkContainer*) self->priv->popmenu, (GtkWidget*) mi);
		_g_object_unref0 (mi);
	} else {
		{
			GeeIterator* _lf_it;
			_lf_it = gee_abstract_collection_iterator ((GeeAbstractCollection*) lfs);
			while (TRUE) {
				LauncherFile* lf;
				GtkMenuItem* mi;
				gboolean _tmp5_ = FALSE;
				if (!gee_iterator_next (_lf_it)) {
					break;
				}
				lf = (LauncherFile*) gee_iterator_get (_lf_it);
				mi = NULL;
				if (launcher_file_get_status (lf) == LAUNCHER_FILE_STATUSES_DOWNLOADED) {
					_tmp5_ = TRUE;
				} else {
					_tmp5_ = launcher_file_get_status (lf) == LAUNCHER_FILE_STATUSES_UPLOADED;
				}
				if (_tmp5_) {
					const char* _tmp6_;
					char* img;
					GtkImageMenuItem* imi;
					char* _tmp7_;
					GtkMenuItem* _tmp8_;
					_tmp6_ = NULL;
					if (launcher_file_get_status (lf) == LAUNCHER_FILE_STATUSES_DOWNLOADED) {
						_tmp6_ = GTK_STOCK_GO_DOWN;
					} else {
						_tmp6_ = GTK_STOCK_GO_UP;
					}
					img = g_strdup (_tmp6_);
					imi = g_object_ref_sink ((GtkImageMenuItem*) gtk_image_menu_item_new_from_stock (img, NULL));
					gtk_menu_item_set_label ((GtkMenuItem*) imi, _tmp7_ = launcher_file_get_uri (lf));
					_g_free0 (_tmp7_);
					mi = (_tmp8_ = _g_object_ref0 (GTK_MENU_ITEM (imi)), _g_object_unref0 (mi), _tmp8_);
					_g_free0 (img);
					_g_object_unref0 (imi);
				} else {
					GtkMenuItem* _tmp10_;
					char* _tmp9_;
					mi = (_tmp10_ = g_object_ref_sink ((GtkMenuItem*) gtk_menu_item_new_with_label (_tmp9_ = launcher_file_get_uri (lf))), _g_object_unref0 (mi), _tmp10_);
					_g_free0 (_tmp9_);
				}
				g_signal_connect_object (mi, "activate", (GCallback) __lambda11__gtk_menu_item_activate, self, 0);
				gtk_container_add ((GtkContainer*) self->priv->popmenu, (GtkWidget*) mi);
				_g_object_unref0 (lf);
				_g_object_unref0 (mi);
			}
			_g_object_unref0 (_lf_it);
		}
	}
	finish_all = g_object_ref_sink ((GtkImageMenuItem*) gtk_image_menu_item_new_from_stock (GTK_STOCK_CLEAR, NULL));
	g_signal_connect_object ((GtkMenuItem*) finish_all, "activate", (GCallback) __lambda12__gtk_menu_item_activate, self, 0);
	if (gee_collection_get_size ((GeeCollection*) lfs) == 0) {
		gtk_widget_set_sensitive ((GtkWidget*) finish_all, FALSE);
	}
	g_signal_connect_object ((GtkMenuItem*) item_quit, "activate", (GCallback) _roxenlauncher_main_window_on_window_destroy_gtk_menu_item_activate, win, 0);
	g_signal_connect_object ((GtkMenuItem*) item_toggle, "activate", (GCallback) _roxenlauncher_tray_set_window_visibility_gtk_menu_item_activate, self, 0);
	gtk_container_add ((GtkContainer*) self->priv->popmenu, (GtkWidget*) (_tmp11_ = g_object_ref_sink ((GtkSeparatorMenuItem*) gtk_separator_menu_item_new ())));
	_g_object_unref0 (_tmp11_);
	gtk_container_add ((GtkContainer*) self->priv->popmenu, (GtkWidget*) finish_all);
	gtk_container_add ((GtkContainer*) self->priv->popmenu, (GtkWidget*) item_toggle);
	gtk_container_add ((GtkContainer*) self->priv->popmenu, (GtkWidget*) item_quit);
	gtk_widget_show_all ((GtkWidget*) self->priv->popmenu);
	gtk_menu_popup (self->priv->popmenu, NULL, NULL, NULL, NULL, btn, (guint32) time);
	_g_object_unref0 (item_quit);
	_g_object_unref0 (img_hide);
	_g_object_unref0 (img_show);
	_g_object_unref0 (item_toggle);
	_g_object_unref0 (lfs);
	_g_object_unref0 (finish_all);
}


static void roxenlauncher_tray_set_window_visibility (RoxenlauncherTray* self) {
	GtkWindow* _tmp0_;
	gboolean _tmp1_;
	gboolean v;
	GtkWindow* _tmp2_;
	const char* _tmp3_;
	g_return_if_fail (self != NULL);
	v = (_tmp1_ = gtk_widget_get_visible ((GtkWidget*) (_tmp0_ = roxenlauncher_main_window_get_window (win))), _g_object_unref0 (_tmp0_), _tmp1_);
	gtk_widget_set_visible ((GtkWidget*) (_tmp2_ = roxenlauncher_main_window_get_window (win)), !v);
	_g_object_unref0 (_tmp2_);
	_tmp3_ = NULL;
	if (v) {
		_tmp3_ = self->priv->m_show;
	} else {
		_tmp3_ = self->priv->m_hide;
	}
	gtk_status_icon_set_tooltip_text (self->priv->icon, _tmp3_);
}


RoxenlauncherTray* roxenlauncher_tray_construct (GType object_type) {
	RoxenlauncherTray * self;
	self = g_object_newv (object_type, 0, NULL);
	return self;
}


RoxenlauncherTray* roxenlauncher_tray_new (void) {
	return roxenlauncher_tray_construct (ROXENLAUNCHER_TYPE_TRAY);
}


static GObject * roxenlauncher_tray_constructor (GType type, guint n_construct_properties, GObjectConstructParam * construct_properties) {
	GObject * obj;
	GObjectClass * parent_class;
	RoxenlauncherTray * self;
	GError * _inner_error_;
	parent_class = G_OBJECT_CLASS (roxenlauncher_tray_parent_class);
	obj = parent_class->constructor (type, n_construct_properties, construct_properties);
	self = ROXENLAUNCHER_TRAY (obj);
	_inner_error_ = NULL;
	{
		{
			GdkPixbuf* logo;
			char* ico;
			GdkPixbuf* _tmp0_;
			GdkPixbuf* _tmp1_;
			GtkStatusIcon* _tmp2_;
			logo = NULL;
			ico = roxenlauncher_get_ui_path ("pixmap/roxen-logo-small.png");
			_tmp0_ = gdk_pixbuf_new_from_file (ico, &_inner_error_);
			if (_inner_error_ != NULL) {
				_g_object_unref0 (logo);
				_g_free0 (ico);
				goto __catch24_g_error;
				goto __finally24;
			}
			logo = (_tmp1_ = _tmp0_, _g_object_unref0 (logo), _tmp1_);
			self->priv->icon = (_tmp2_ = gtk_status_icon_new_from_pixbuf (logo), _g_object_unref0 (self->priv->icon), _tmp2_);
			gtk_status_icon_set_tooltip_text (self->priv->icon, self->priv->m_hide);
			gtk_status_icon_set_visible (self->priv->icon, FALSE);
			_g_object_unref0 (logo);
			_g_free0 (ico);
		}
		goto __finally24;
		__catch24_g_error:
		{
			GError * e;
			e = _inner_error_;
			_inner_error_ = NULL;
			{
				g_warning ("tray.vala:45: Unable to load logo for tray! Cant start panel applet");
				_g_error_free0 (e);
			}
		}
		__finally24:
		if (_inner_error_ != NULL) {
			g_critical ("file %s: line %d: uncaught error: %s", __FILE__, __LINE__, _inner_error_->message);
			g_clear_error (&_inner_error_);
		}
	}
	return obj;
}


static void roxenlauncher_tray_class_init (RoxenlauncherTrayClass * klass) {
	roxenlauncher_tray_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (RoxenlauncherTrayPrivate));
	G_OBJECT_CLASS (klass)->constructor = roxenlauncher_tray_constructor;
	G_OBJECT_CLASS (klass)->finalize = roxenlauncher_tray_finalize;
}


static void roxenlauncher_tray_instance_init (RoxenlauncherTray * self) {
	self->priv = ROXENLAUNCHER_TRAY_GET_PRIVATE (self);
	self->priv->m_show = g_strdup (_ ("Click to show the application launcher"));
	self->priv->m_hide = g_strdup (_ ("Click to hide the application launcher"));
	self->priv->t_show = g_strdup (_ ("Show application launcher"));
	self->priv->t_hide = g_strdup (_ ("Hide application launcher"));
}


static void roxenlauncher_tray_finalize (GObject* obj) {
	RoxenlauncherTray * self;
	self = ROXENLAUNCHER_TRAY (obj);
	_g_object_unref0 (self->priv->icon);
	_g_object_unref0 (self->priv->popmenu);
	_g_free0 (self->priv->m_show);
	_g_free0 (self->priv->m_hide);
	_g_free0 (self->priv->t_show);
	_g_free0 (self->priv->t_hide);
	G_OBJECT_CLASS (roxenlauncher_tray_parent_class)->finalize (obj);
}


GType roxenlauncher_tray_get_type (void) {
	static GType roxenlauncher_tray_type_id = 0;
	if (roxenlauncher_tray_type_id == 0) {
		static const GTypeInfo g_define_type_info = { sizeof (RoxenlauncherTrayClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) roxenlauncher_tray_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (RoxenlauncherTray), 0, (GInstanceInitFunc) roxenlauncher_tray_instance_init, NULL };
		roxenlauncher_tray_type_id = g_type_register_static (G_TYPE_OBJECT, "RoxenlauncherTray", &g_define_type_info, 0);
	}
	return roxenlauncher_tray_type_id;
}



