#ifndef SOPPA_H
#define SOPPA_H

#include <stdio.h>
#include <string.h>
#include <libsoup/soup.h>

gboolean save_soup_data(SoupMessageBody *data, const char *file);

#endif

