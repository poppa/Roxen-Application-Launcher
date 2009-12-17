/* application-form.c generated by valac, the Vala compiler
 * generated from application-form.vala, do not modify */

/* -*- Mode: Vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * application-form.vala
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
#include <config.h>
#include <glib/gi18n-lib.h>


#define ROXENLAUNCHER_TYPE_APPLICATION_FORM (roxenlauncher_application_form_get_type ())
#define ROXENLAUNCHER_APPLICATION_FORM(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), ROXENLAUNCHER_TYPE_APPLICATION_FORM, RoxenlauncherApplicationForm))
#define ROXENLAUNCHER_APPLICATION_FORM_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), ROXENLAUNCHER_TYPE_APPLICATION_FORM, RoxenlauncherApplicationFormClass))
#define ROXENLAUNCHER_IS_APPLICATION_FORM(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), ROXENLAUNCHER_TYPE_APPLICATION_FORM))
#define ROXENLAUNCHER_IS_APPLICATION_FORM_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), ROXENLAUNCHER_TYPE_APPLICATION_FORM))
#define ROXENLAUNCHER_APPLICATION_FORM_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), ROXENLAUNCHER_TYPE_APPLICATION_FORM, RoxenlauncherApplicationFormClass))

typedef struct _RoxenlauncherApplicationForm RoxenlauncherApplicationForm;
typedef struct _RoxenlauncherApplicationFormClass RoxenlauncherApplicationFormClass;
typedef struct _RoxenlauncherApplicationFormPrivate RoxenlauncherApplicationFormPrivate;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))

#define ROXENLAUNCHER_TYPE_FILE_DIALOG (roxenlauncher_file_dialog_get_type ())
#define ROXENLAUNCHER_FILE_DIALOG(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), ROXENLAUNCHER_TYPE_FILE_DIALOG, RoxenlauncherFileDialog))
#define ROXENLAUNCHER_FILE_DIALOG_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), ROXENLAUNCHER_TYPE_FILE_DIALOG, RoxenlauncherFileDialogClass))
#define ROXENLAUNCHER_IS_FILE_DIALOG(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), ROXENLAUNCHER_TYPE_FILE_DIALOG))
#define ROXENLAUNCHER_IS_FILE_DIALOG_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), ROXENLAUNCHER_TYPE_FILE_DIALOG))
#define ROXENLAUNCHER_FILE_DIALOG_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), ROXENLAUNCHER_TYPE_FILE_DIALOG, RoxenlauncherFileDialogClass))

typedef struct _RoxenlauncherFileDialog RoxenlauncherFileDialog;
typedef struct _RoxenlauncherFileDialogClass RoxenlauncherFileDialogClass;
typedef struct _RoxenlauncherFileDialogPrivate RoxenlauncherFileDialogPrivate;

struct _RoxenlauncherApplicationForm {
	GObject parent_instance;
	RoxenlauncherApplicationFormPrivate * priv;
};

struct _RoxenlauncherApplicationFormClass {
	GObjectClass parent_class;
};

struct _RoxenlauncherApplicationFormPrivate {
	GtkBuilder* builder;
	GtkDialog* dialog;
	GtkEntry* tf_content_type;
	GtkEntry* tf_editor_name;
	GtkEntry* tf_editor_cmd;
	GtkEntry* tf_editor_args;
	GtkButton* btn_ok;
	GtkButton* btn_cancel;
	GtkButton* btn_browse;
	gboolean _response;
	char* ct;
	char* name;
	char* cmd;
	char* args;
};

struct _RoxenlauncherFileDialog {
	GtkFileChooserDialog parent_instance;
	RoxenlauncherFileDialogPrivate * priv;
};

struct _RoxenlauncherFileDialogClass {
	GtkFileChooserDialogClass parent_class;
};


static gpointer roxenlauncher_application_form_parent_class = NULL;
static gpointer roxenlauncher_file_dialog_parent_class = NULL;

GType roxenlauncher_application_form_get_type (void);
#define ROXENLAUNCHER_APPLICATION_FORM_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), ROXENLAUNCHER_TYPE_APPLICATION_FORM, RoxenlauncherApplicationFormPrivate))
enum  {
	ROXENLAUNCHER_APPLICATION_FORM_DUMMY_PROPERTY,
	ROXENLAUNCHER_APPLICATION_FORM_RESPONSE,
	ROXENLAUNCHER_APPLICATION_FORM_CONTENT_TYPE,
	ROXENLAUNCHER_APPLICATION_FORM_EDITOR_NAME,
	ROXENLAUNCHER_APPLICATION_FORM_EDITOR_COMMAND,
	ROXENLAUNCHER_APPLICATION_FORM_EDITOR_ARGUMENTS
};
char* roxenlauncher_get_ui_path (const char* local_path);
#define ROXENLAUNCHER_APP_EDITOR_UI_FILENAME "application-form.ui"
static void roxenlauncher_application_form_on_tf_changed (RoxenlauncherApplicationForm* self, GtkEditable* src);
static void _roxenlauncher_application_form_on_tf_changed_gtk_editable_changed (GtkEditable* _sender, gpointer self);
static void roxenlauncher_application_form_on_btn_cancel_clicked (RoxenlauncherApplicationForm* self, GtkButton* src);
static void _roxenlauncher_application_form_on_btn_cancel_clicked_gtk_button_clicked (GtkButton* _sender, gpointer self);
static void roxenlauncher_application_form_on_btn_ok_clicked (RoxenlauncherApplicationForm* self, GtkButton* src);
static void _roxenlauncher_application_form_on_btn_ok_clicked_gtk_button_clicked (GtkButton* _sender, gpointer self);
static void roxenlauncher_application_form_on_quit (RoxenlauncherApplicationForm* self);
static void _roxenlauncher_application_form_on_quit_gtk_object_destroy (GtkObject* _sender, gpointer self);
RoxenlauncherFileDialog* roxenlauncher_file_dialog_new (void);
RoxenlauncherFileDialog* roxenlauncher_file_dialog_construct (GType object_type);
GType roxenlauncher_file_dialog_get_type (void);
static void _lambda7_ (RoxenlauncherApplicationForm* self);
static void __lambda7__gtk_button_clicked (GtkButton* _sender, gpointer self);
void roxenlauncher_application_form_run (RoxenlauncherApplicationForm* self);
static void roxenlauncher_application_form_set_response (RoxenlauncherApplicationForm* self, gboolean value);
RoxenlauncherApplicationForm* roxenlauncher_application_form_new (void);
RoxenlauncherApplicationForm* roxenlauncher_application_form_construct (GType object_type);
gboolean roxenlauncher_application_form_get_response (RoxenlauncherApplicationForm* self);
const char* roxenlauncher_application_form_get_content_type (RoxenlauncherApplicationForm* self);
void roxenlauncher_application_form_set_content_type (RoxenlauncherApplicationForm* self, const char* value);
const char* roxenlauncher_application_form_get_editor_name (RoxenlauncherApplicationForm* self);
void roxenlauncher_application_form_set_editor_name (RoxenlauncherApplicationForm* self, const char* value);
const char* roxenlauncher_application_form_get_editor_command (RoxenlauncherApplicationForm* self);
void roxenlauncher_application_form_set_editor_command (RoxenlauncherApplicationForm* self, const char* value);
const char* roxenlauncher_application_form_get_editor_arguments (RoxenlauncherApplicationForm* self);
void roxenlauncher_application_form_set_editor_arguments (RoxenlauncherApplicationForm* self, const char* value);
static void roxenlauncher_application_form_finalize (GObject* obj);
static void roxenlauncher_application_form_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void roxenlauncher_application_form_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);
enum  {
	ROXENLAUNCHER_FILE_DIALOG_DUMMY_PROPERTY
};
char* roxenlauncher_get_last_folder (void);
static void _lambda8_ (RoxenlauncherFileDialog* self);
static void __lambda8__gtk_object_destroy (GtkObject* _sender, gpointer self);
void roxenlauncher_set_last_folder (const char* path);
static void roxenlauncher_file_dialog_real_response (GtkDialog* base, gint type);
static void _vala_array_destroy (gpointer array, gint array_length, GDestroyNotify destroy_func);
static void _vala_array_free (gpointer array, gint array_length, GDestroyNotify destroy_func);
static gint _vala_array_length (gpointer array);
static int _vala_strcmp0 (const char * str1, const char * str2);



static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static void _roxenlauncher_application_form_on_tf_changed_gtk_editable_changed (GtkEditable* _sender, gpointer self) {
	roxenlauncher_application_form_on_tf_changed (self, _sender);
}


static void _roxenlauncher_application_form_on_btn_cancel_clicked_gtk_button_clicked (GtkButton* _sender, gpointer self) {
	roxenlauncher_application_form_on_btn_cancel_clicked (self, _sender);
}


static void _roxenlauncher_application_form_on_btn_ok_clicked_gtk_button_clicked (GtkButton* _sender, gpointer self) {
	roxenlauncher_application_form_on_btn_ok_clicked (self, _sender);
}


static void _roxenlauncher_application_form_on_quit_gtk_object_destroy (GtkObject* _sender, gpointer self) {
	roxenlauncher_application_form_on_quit (self);
}


static void _lambda7_ (RoxenlauncherApplicationForm* self) {
	RoxenlauncherFileDialog* fd;
	gint res;
	fd = g_object_ref_sink (roxenlauncher_file_dialog_new ());
	res = gtk_dialog_run ((GtkDialog*) fd);
	if (res == GTK_RESPONSE_ACCEPT) {
		char* _tmp0_;
		gtk_entry_set_text (self->priv->tf_editor_cmd, _tmp0_ = gtk_file_chooser_get_filename ((GtkFileChooser*) fd));
		_g_free0 (_tmp0_);
		if (_vala_strcmp0 (gtk_entry_get_text (self->priv->tf_editor_name), "") == 0) {
			char** _tmp2_;
			gint s_size;
			gint s_length1;
			char** _tmp1_;
			char** s;
			char* n;
			s = (_tmp2_ = _tmp1_ = g_strsplit (gtk_entry_get_text (self->priv->tf_editor_cmd), "/", 0), s_length1 = _vala_array_length (_tmp1_), s_size = s_length1, _tmp2_);
			n = g_strdup (s[s_length1 - 1]);
			gtk_entry_set_text (self->priv->tf_editor_name, n);
			s = (_vala_array_free (s, s_length1, (GDestroyNotify) g_free), NULL);
			_g_free0 (n);
		}
	}
	gtk_object_destroy ((GtkObject*) fd);
	_g_object_unref0 (fd);
}


static void __lambda7__gtk_button_clicked (GtkButton* _sender, gpointer self) {
	_lambda7_ (self);
}


void roxenlauncher_application_form_run (RoxenlauncherApplicationForm* self) {
	GError * _inner_error_;
	GtkBuilder* _tmp0_;
	char* filename;
	GtkDialog* _tmp1_;
	GtkEntry* _tmp2_;
	GtkEntry* _tmp3_;
	GtkEntry* _tmp4_;
	GtkEntry* _tmp5_;
	GtkButton* _tmp6_;
	GtkButton* _tmp7_;
	GtkButton* _tmp8_;
	g_return_if_fail (self != NULL);
	_inner_error_ = NULL;
	self->priv->builder = (_tmp0_ = gtk_builder_new (), _g_object_unref0 (self->priv->builder), _tmp0_);
	filename = roxenlauncher_get_ui_path (ROXENLAUNCHER_APP_EDITOR_UI_FILENAME);
	if (filename == NULL) {
		g_warning ("application-form.vala:75: Unable to load GUI for main window");
		_g_free0 (filename);
		return;
	}
	{
		gtk_builder_set_translation_domain (self->priv->builder, GETTEXT_PACKAGE);
		gtk_builder_add_from_file (self->priv->builder, filename, &_inner_error_);
		if (_inner_error_ != NULL) {
			goto __catch29_g_error;
			goto __finally29;
		}
	}
	goto __finally29;
	__catch29_g_error:
	{
		GError * e;
		e = _inner_error_;
		_inner_error_ = NULL;
		{
			g_warning ("application-form.vala:84: GUI load error: %s", e->message);
			_g_error_free0 (e);
			_g_free0 (filename);
			return;
		}
	}
	__finally29:
	if (_inner_error_ != NULL) {
		_g_free0 (filename);
		g_critical ("file %s: line %d: uncaught error: %s", __FILE__, __LINE__, _inner_error_->message);
		g_clear_error (&_inner_error_);
		return;
	}
	self->priv->dialog = (_tmp1_ = _g_object_ref0 (GTK_DIALOG (gtk_builder_get_object (self->priv->builder, "editor"))), _g_object_unref0 (self->priv->dialog), _tmp1_);
	self->priv->tf_content_type = (_tmp2_ = _g_object_ref0 (GTK_ENTRY (gtk_builder_get_object (self->priv->builder, "tf_content_type"))), _g_object_unref0 (self->priv->tf_content_type), _tmp2_);
	self->priv->tf_editor_name = (_tmp3_ = _g_object_ref0 (GTK_ENTRY (gtk_builder_get_object (self->priv->builder, "tf_editor_name"))), _g_object_unref0 (self->priv->tf_editor_name), _tmp3_);
	self->priv->tf_editor_cmd = (_tmp4_ = _g_object_ref0 (GTK_ENTRY (gtk_builder_get_object (self->priv->builder, "tf_editor_cmd"))), _g_object_unref0 (self->priv->tf_editor_cmd), _tmp4_);
	self->priv->tf_editor_args = (_tmp5_ = _g_object_ref0 (GTK_ENTRY (gtk_builder_get_object (self->priv->builder, "tf_editor_args"))), _g_object_unref0 (self->priv->tf_editor_args), _tmp5_);
	gtk_entry_set_text (self->priv->tf_content_type, self->priv->ct);
	gtk_entry_set_text (self->priv->tf_editor_name, self->priv->name);
	gtk_entry_set_text (self->priv->tf_editor_cmd, self->priv->cmd);
	gtk_entry_set_text (self->priv->tf_editor_args, self->priv->args);
	g_signal_connect_object ((GtkEditable*) self->priv->tf_content_type, "changed", (GCallback) _roxenlauncher_application_form_on_tf_changed_gtk_editable_changed, self, 0);
	g_signal_connect_object ((GtkEditable*) self->priv->tf_editor_name, "changed", (GCallback) _roxenlauncher_application_form_on_tf_changed_gtk_editable_changed, self, 0);
	g_signal_connect_object ((GtkEditable*) self->priv->tf_editor_cmd, "changed", (GCallback) _roxenlauncher_application_form_on_tf_changed_gtk_editable_changed, self, 0);
	g_signal_connect_object ((GtkEditable*) self->priv->tf_editor_args, "changed", (GCallback) _roxenlauncher_application_form_on_tf_changed_gtk_editable_changed, self, 0);
	self->priv->btn_ok = (_tmp6_ = _g_object_ref0 (GTK_BUTTON (gtk_builder_get_object (self->priv->builder, "btn_ok"))), _g_object_unref0 (self->priv->btn_ok), _tmp6_);
	self->priv->btn_cancel = (_tmp7_ = _g_object_ref0 (GTK_BUTTON (gtk_builder_get_object (self->priv->builder, "btn_cancel"))), _g_object_unref0 (self->priv->btn_cancel), _tmp7_);
	self->priv->btn_browse = (_tmp8_ = _g_object_ref0 (GTK_BUTTON (gtk_builder_get_object (self->priv->builder, "btn_browse"))), _g_object_unref0 (self->priv->btn_browse), _tmp8_);
	gtk_widget_set_sensitive ((GtkWidget*) self->priv->btn_ok, FALSE);
	g_signal_connect_object (self->priv->btn_cancel, "clicked", (GCallback) _roxenlauncher_application_form_on_btn_cancel_clicked_gtk_button_clicked, self, 0);
	g_signal_connect_object (self->priv->btn_ok, "clicked", (GCallback) _roxenlauncher_application_form_on_btn_ok_clicked_gtk_button_clicked, self, 0);
	g_signal_connect_object ((GtkObject*) self->priv->dialog, "destroy", (GCallback) _roxenlauncher_application_form_on_quit_gtk_object_destroy, self, 0);
	g_signal_connect_object (self->priv->btn_browse, "clicked", (GCallback) __lambda7__gtk_button_clicked, self, 0);
	gtk_dialog_run (self->priv->dialog);
	gtk_object_destroy ((GtkObject*) self->priv->dialog);
	_g_free0 (filename);
}


static gboolean string_contains (const char* self, const char* needle) {
	gboolean result;
	g_return_val_if_fail (self != NULL, FALSE);
	g_return_val_if_fail (needle != NULL, FALSE);
	result = strstr (self, needle) != NULL;
	return result;
}


static glong string_get_length (const char* self) {
	glong result;
	g_return_val_if_fail (self != NULL, 0L);
	result = g_utf8_strlen (self, -1);
	return result;
}


static void roxenlauncher_application_form_on_tf_changed (RoxenlauncherApplicationForm* self, GtkEditable* src) {
	gint ok;
	g_return_if_fail (self != NULL);
	g_return_if_fail (src != NULL);
	ok = 0;
	if (string_contains (gtk_entry_get_text (self->priv->tf_content_type), "/")) {
		ok++;
	}
	if (string_get_length (gtk_entry_get_text (self->priv->tf_editor_name)) > 0) {
		ok++;
	}
	if (string_get_length (gtk_entry_get_text (self->priv->tf_editor_cmd)) > 0) {
		ok++;
	}
	gtk_widget_set_sensitive ((GtkWidget*) self->priv->btn_ok, ok > 2);
}


static void roxenlauncher_application_form_on_btn_cancel_clicked (RoxenlauncherApplicationForm* self, GtkButton* src) {
	g_return_if_fail (self != NULL);
	g_return_if_fail (src != NULL);
	roxenlauncher_application_form_set_response (self, FALSE);
}


static void roxenlauncher_application_form_on_btn_ok_clicked (RoxenlauncherApplicationForm* self, GtkButton* src) {
	char* _tmp0_;
	char* _tmp1_;
	char* _tmp2_;
	char* _tmp3_;
	g_return_if_fail (self != NULL);
	g_return_if_fail (src != NULL);
	roxenlauncher_application_form_set_response (self, TRUE);
	self->priv->ct = (_tmp0_ = g_strdup (gtk_entry_get_text (self->priv->tf_content_type)), _g_free0 (self->priv->ct), _tmp0_);
	self->priv->name = (_tmp1_ = g_strdup (gtk_entry_get_text (self->priv->tf_editor_name)), _g_free0 (self->priv->name), _tmp1_);
	self->priv->cmd = (_tmp2_ = g_strdup (gtk_entry_get_text (self->priv->tf_editor_cmd)), _g_free0 (self->priv->cmd), _tmp2_);
	self->priv->args = (_tmp3_ = g_strdup (gtk_entry_get_text (self->priv->tf_editor_args)), _g_free0 (self->priv->args), _tmp3_);
}


static void roxenlauncher_application_form_on_quit (RoxenlauncherApplicationForm* self) {
	g_return_if_fail (self != NULL);
	g_message ("application-form.vala:166: Destroy dialog");
}


RoxenlauncherApplicationForm* roxenlauncher_application_form_construct (GType object_type) {
	RoxenlauncherApplicationForm * self;
	self = (RoxenlauncherApplicationForm*) g_object_new (object_type, NULL);
	return self;
}


RoxenlauncherApplicationForm* roxenlauncher_application_form_new (void) {
	return roxenlauncher_application_form_construct (ROXENLAUNCHER_TYPE_APPLICATION_FORM);
}


gboolean roxenlauncher_application_form_get_response (RoxenlauncherApplicationForm* self) {
	gboolean result;
	g_return_val_if_fail (self != NULL, FALSE);
	result = self->priv->_response;
	return result;
}


static void roxenlauncher_application_form_set_response (RoxenlauncherApplicationForm* self, gboolean value) {
	g_return_if_fail (self != NULL);
	self->priv->_response = value;
	g_object_notify ((GObject *) self, "response");
}


const char* roxenlauncher_application_form_get_content_type (RoxenlauncherApplicationForm* self) {
	const char* result;
	g_return_val_if_fail (self != NULL, NULL);
	result = self->priv->ct;
	return result;
}


void roxenlauncher_application_form_set_content_type (RoxenlauncherApplicationForm* self, const char* value) {
	char* _tmp0_;
	g_return_if_fail (self != NULL);
	self->priv->ct = (_tmp0_ = g_strdup (value), _g_free0 (self->priv->ct), _tmp0_);
	g_object_notify ((GObject *) self, "content-type");
}


const char* roxenlauncher_application_form_get_editor_name (RoxenlauncherApplicationForm* self) {
	const char* result;
	g_return_val_if_fail (self != NULL, NULL);
	result = self->priv->name;
	return result;
}


void roxenlauncher_application_form_set_editor_name (RoxenlauncherApplicationForm* self, const char* value) {
	char* _tmp0_;
	g_return_if_fail (self != NULL);
	self->priv->name = (_tmp0_ = g_strdup (value), _g_free0 (self->priv->name), _tmp0_);
	g_object_notify ((GObject *) self, "editor-name");
}


const char* roxenlauncher_application_form_get_editor_command (RoxenlauncherApplicationForm* self) {
	const char* result;
	g_return_val_if_fail (self != NULL, NULL);
	result = self->priv->cmd;
	return result;
}


void roxenlauncher_application_form_set_editor_command (RoxenlauncherApplicationForm* self, const char* value) {
	char* _tmp0_;
	g_return_if_fail (self != NULL);
	self->priv->cmd = (_tmp0_ = g_strdup (value), _g_free0 (self->priv->cmd), _tmp0_);
	g_object_notify ((GObject *) self, "editor-command");
}


const char* roxenlauncher_application_form_get_editor_arguments (RoxenlauncherApplicationForm* self) {
	const char* result;
	g_return_val_if_fail (self != NULL, NULL);
	result = self->priv->args;
	return result;
}


void roxenlauncher_application_form_set_editor_arguments (RoxenlauncherApplicationForm* self, const char* value) {
	char* _tmp0_;
	g_return_if_fail (self != NULL);
	self->priv->args = (_tmp0_ = g_strdup (value), _g_free0 (self->priv->args), _tmp0_);
	g_object_notify ((GObject *) self, "editor-arguments");
}


static void roxenlauncher_application_form_class_init (RoxenlauncherApplicationFormClass * klass) {
	roxenlauncher_application_form_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (RoxenlauncherApplicationFormPrivate));
	G_OBJECT_CLASS (klass)->get_property = roxenlauncher_application_form_get_property;
	G_OBJECT_CLASS (klass)->set_property = roxenlauncher_application_form_set_property;
	G_OBJECT_CLASS (klass)->finalize = roxenlauncher_application_form_finalize;
	g_object_class_install_property (G_OBJECT_CLASS (klass), ROXENLAUNCHER_APPLICATION_FORM_RESPONSE, g_param_spec_boolean ("response", "response", "response", FALSE, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE));
	g_object_class_install_property (G_OBJECT_CLASS (klass), ROXENLAUNCHER_APPLICATION_FORM_CONTENT_TYPE, g_param_spec_string ("content-type", "content-type", "content-type", NULL, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE | G_PARAM_WRITABLE));
	g_object_class_install_property (G_OBJECT_CLASS (klass), ROXENLAUNCHER_APPLICATION_FORM_EDITOR_NAME, g_param_spec_string ("editor-name", "editor-name", "editor-name", NULL, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE | G_PARAM_WRITABLE));
	g_object_class_install_property (G_OBJECT_CLASS (klass), ROXENLAUNCHER_APPLICATION_FORM_EDITOR_COMMAND, g_param_spec_string ("editor-command", "editor-command", "editor-command", NULL, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE | G_PARAM_WRITABLE));
	g_object_class_install_property (G_OBJECT_CLASS (klass), ROXENLAUNCHER_APPLICATION_FORM_EDITOR_ARGUMENTS, g_param_spec_string ("editor-arguments", "editor-arguments", "editor-arguments", NULL, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE | G_PARAM_WRITABLE));
}


static void roxenlauncher_application_form_instance_init (RoxenlauncherApplicationForm * self) {
	self->priv = ROXENLAUNCHER_APPLICATION_FORM_GET_PRIVATE (self);
	self->priv->_response = FALSE;
	self->priv->ct = g_strdup ("");
	self->priv->name = g_strdup ("");
	self->priv->cmd = g_strdup ("");
	self->priv->args = g_strdup ("");
}


static void roxenlauncher_application_form_finalize (GObject* obj) {
	RoxenlauncherApplicationForm * self;
	self = ROXENLAUNCHER_APPLICATION_FORM (obj);
	_g_object_unref0 (self->priv->builder);
	_g_object_unref0 (self->priv->dialog);
	_g_object_unref0 (self->priv->tf_content_type);
	_g_object_unref0 (self->priv->tf_editor_name);
	_g_object_unref0 (self->priv->tf_editor_cmd);
	_g_object_unref0 (self->priv->tf_editor_args);
	_g_object_unref0 (self->priv->btn_ok);
	_g_object_unref0 (self->priv->btn_cancel);
	_g_object_unref0 (self->priv->btn_browse);
	_g_free0 (self->priv->ct);
	_g_free0 (self->priv->name);
	_g_free0 (self->priv->cmd);
	_g_free0 (self->priv->args);
	G_OBJECT_CLASS (roxenlauncher_application_form_parent_class)->finalize (obj);
}


GType roxenlauncher_application_form_get_type (void) {
	static GType roxenlauncher_application_form_type_id = 0;
	if (roxenlauncher_application_form_type_id == 0) {
		static const GTypeInfo g_define_type_info = { sizeof (RoxenlauncherApplicationFormClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) roxenlauncher_application_form_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (RoxenlauncherApplicationForm), 0, (GInstanceInitFunc) roxenlauncher_application_form_instance_init, NULL };
		roxenlauncher_application_form_type_id = g_type_register_static (G_TYPE_OBJECT, "RoxenlauncherApplicationForm", &g_define_type_info, 0);
	}
	return roxenlauncher_application_form_type_id;
}


static void roxenlauncher_application_form_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	RoxenlauncherApplicationForm * self;
	self = ROXENLAUNCHER_APPLICATION_FORM (object);
	switch (property_id) {
		case ROXENLAUNCHER_APPLICATION_FORM_RESPONSE:
		g_value_set_boolean (value, roxenlauncher_application_form_get_response (self));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_CONTENT_TYPE:
		g_value_set_string (value, roxenlauncher_application_form_get_content_type (self));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_EDITOR_NAME:
		g_value_set_string (value, roxenlauncher_application_form_get_editor_name (self));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_EDITOR_COMMAND:
		g_value_set_string (value, roxenlauncher_application_form_get_editor_command (self));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_EDITOR_ARGUMENTS:
		g_value_set_string (value, roxenlauncher_application_form_get_editor_arguments (self));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void roxenlauncher_application_form_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	RoxenlauncherApplicationForm * self;
	self = ROXENLAUNCHER_APPLICATION_FORM (object);
	switch (property_id) {
		case ROXENLAUNCHER_APPLICATION_FORM_RESPONSE:
		roxenlauncher_application_form_set_response (self, g_value_get_boolean (value));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_CONTENT_TYPE:
		roxenlauncher_application_form_set_content_type (self, g_value_get_string (value));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_EDITOR_NAME:
		roxenlauncher_application_form_set_editor_name (self, g_value_get_string (value));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_EDITOR_COMMAND:
		roxenlauncher_application_form_set_editor_command (self, g_value_get_string (value));
		break;
		case ROXENLAUNCHER_APPLICATION_FORM_EDITOR_ARGUMENTS:
		roxenlauncher_application_form_set_editor_arguments (self, g_value_get_string (value));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void _lambda8_ (RoxenlauncherFileDialog* self) {
	gtk_object_destroy ((GtkObject*) self);
}


static void __lambda8__gtk_object_destroy (GtkObject* _sender, gpointer self) {
	_lambda8_ (self);
}


RoxenlauncherFileDialog* roxenlauncher_file_dialog_construct (GType object_type) {
	RoxenlauncherFileDialog * self;
	char* _tmp0_;
	self = g_object_newv (object_type, 0, NULL);
	gtk_window_set_title ((GtkWindow*) self, _ ("Select application..."));
	gtk_file_chooser_set_action ((GtkFileChooser*) self, GTK_FILE_CHOOSER_ACTION_OPEN);
	gtk_dialog_add_button ((GtkDialog*) self, GTK_STOCK_CANCEL, (gint) GTK_RESPONSE_CANCEL);
	gtk_dialog_add_button ((GtkDialog*) self, GTK_STOCK_OPEN, (gint) GTK_RESPONSE_ACCEPT);
	gtk_dialog_set_default_response ((GtkDialog*) self, (gint) GTK_RESPONSE_ACCEPT);
	gtk_file_chooser_set_current_folder ((GtkFileChooser*) self, _tmp0_ = roxenlauncher_get_last_folder ());
	_g_free0 (_tmp0_);
	g_signal_connect_object ((GtkObject*) self, "destroy", (GCallback) __lambda8__gtk_object_destroy, self, 0);
	return self;
}


RoxenlauncherFileDialog* roxenlauncher_file_dialog_new (void) {
	return roxenlauncher_file_dialog_construct (ROXENLAUNCHER_TYPE_FILE_DIALOG);
}


static void roxenlauncher_file_dialog_real_response (GtkDialog* base, gint type) {
	RoxenlauncherFileDialog * self;
	self = (RoxenlauncherFileDialog*) base;
	if (type == GTK_RESPONSE_ACCEPT) {
		char* _tmp0_;
		roxenlauncher_set_last_folder (_tmp0_ = gtk_file_chooser_get_current_folder ((GtkFileChooser*) self));
		_g_free0 (_tmp0_);
	}
}


static void roxenlauncher_file_dialog_class_init (RoxenlauncherFileDialogClass * klass) {
	roxenlauncher_file_dialog_parent_class = g_type_class_peek_parent (klass);
	GTK_DIALOG_CLASS (klass)->response = roxenlauncher_file_dialog_real_response;
}


static void roxenlauncher_file_dialog_instance_init (RoxenlauncherFileDialog * self) {
}


GType roxenlauncher_file_dialog_get_type (void) {
	static GType roxenlauncher_file_dialog_type_id = 0;
	if (roxenlauncher_file_dialog_type_id == 0) {
		static const GTypeInfo g_define_type_info = { sizeof (RoxenlauncherFileDialogClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) roxenlauncher_file_dialog_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (RoxenlauncherFileDialog), 0, (GInstanceInitFunc) roxenlauncher_file_dialog_instance_init, NULL };
		roxenlauncher_file_dialog_type_id = g_type_register_static (GTK_TYPE_FILE_CHOOSER_DIALOG, "RoxenlauncherFileDialog", &g_define_type_info, 0);
	}
	return roxenlauncher_file_dialog_type_id;
}


static void _vala_array_destroy (gpointer array, gint array_length, GDestroyNotify destroy_func) {
	if ((array != NULL) && (destroy_func != NULL)) {
		int i;
		for (i = 0; i < array_length; i = i + 1) {
			if (((gpointer*) array)[i] != NULL) {
				destroy_func (((gpointer*) array)[i]);
			}
		}
	}
}


static void _vala_array_free (gpointer array, gint array_length, GDestroyNotify destroy_func) {
	_vala_array_destroy (array, array_length, destroy_func);
	g_free (array);
}


static gint _vala_array_length (gpointer array) {
	int length;
	length = 0;
	if (array) {
		while (((gpointer*) array)[length]) {
			length++;
		}
	}
	return length;
}


static int _vala_strcmp0 (const char * str1, const char * str2) {
	if (str1 == NULL) {
		return -(str1 != str2);
	}
	if (str2 == NULL) {
		return str1 != str2;
	}
	return strcmp (str1, str2);
}




