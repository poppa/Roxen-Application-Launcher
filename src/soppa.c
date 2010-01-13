#include "soppa.h"

gboolean save_soup_data(SoupMessageBody *data, const char *file)
{
	FILE *fh;

	if ((fh = fopen(file, "w")) == NULL) {
		fprintf(stderr, "Unable to open file \"%s\" for writing!\n", file);
		return FALSE;
	}

	fwrite(data->data, 1, data->length, fh);
	fclose(fh);
	return TRUE;
}

