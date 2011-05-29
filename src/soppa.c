#include "soppa.h"

gboolean save_soup_data(SoupMessageBody *data, const char *file)
{
	FILE *fh;

	if ((fh = fopen(file, "w")) == NULL) {
		fprintf(stderr, "Unable to open file \"%s\" for writing!\n", file);
		return FALSE;
	}

	int wrote = fwrite(data->data, 1, data->length, fh);
	
	if (wrote != (int)data->length) {
	  fprintf(stderr, "wrote (%d) != data->length (%d). Data may have been "
	                  "truncated", wrote, (int)data->length);
	}

	fclose(fh);
	return TRUE;
}

