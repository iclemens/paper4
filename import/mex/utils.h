#ifndef __UTILS_H__
#define __UTILS_H__

struct file_t;

struct file_t *open_file(const char *filename);
void close_file(struct file_t **file);

int peek_char(struct file_t *file);
int get_char(struct file_t *file);

int has_more(struct file_t *file);


int read_unsigned_integer(struct file_t *file);
int read_signed_integer(struct file_t *file);
double read_double(struct file_t *file);
void read_string(struct file_t *file, char *buffer, int length);
void read_line(struct file_t *file, char *buffer, int length);
int read_whitespace(struct file_t *file);

#endif

