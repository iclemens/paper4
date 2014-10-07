#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#include "utils.h"

/********************************************
 * File input with one-character read-ahead.
 */

struct file_t
{
	FILE *file;
	int more;
	int ch;
};


/**
 * Open file for reading.
 */
struct file_t *open_file(const char *filename)
{
  struct file_t *file = (struct file_t *) malloc(sizeof(struct file_t));

	file->file = fopen(filename, "r");

	if(!file->file) {
		file->more = 0;
		return NULL;
	}
	
	file->more = !feof(file->file);
	
	if(file->more)
		file->ch = fgetc(file->file);	
	
	return file;
}


/**
 * Close file.
 */
void close_file(struct file_t **file)
{
	if((*file)->file)
		fclose((*file)->file);
	(*file)->file = NULL;

  free(*file);
  *file = NULL;
}


/**
 * Return next character without removing it from the buffer.
 */
int peek_char(struct file_t *file)
{
	return file->ch;
}


/**
 * Returns whether there are more characters to be read.
 */
int has_more(struct file_t *file)
{
	return file->more;
}


/**
 * Return next character and remove it from buffer.
 */
int get_char(struct file_t *file)
{
	int ch = file->ch;
	
	file->more = !feof(file->file);
	
	if(has_more(file))
		file->ch = fgetc(file->file);	
	
	return ch;
}


/******************
 * Character types
 */

/***************************************************************
 * Reading common sequences from file (e.g. int, float, string)
 */


/**
 * Reads an unsigned integer from a file.
 */
int read_unsigned_integer(struct file_t *file)
{
	int ch = peek_char(file);
	int value = 0;

	while (ch >= '0' && ch <= '9') {
		get_char(file);
		value = (value * 10) +  (ch - '0');
		ch = peek_char(file);
	}
	
	return value;
}


/**
 * Reads an integer from a file
 */
int read_signed_integer(struct file_t *file)
{
	int ch = peek_char(file);

  if(ch == '-') {
    get_char(file);
    return -read_unsigned_integer(file);
  }

  if(ch == '+')
    get_char(file);
	
	return read_unsigned_integer(file);
}


/**
 * Read double (float) from file.
 */
double read_double(struct file_t *file)
{
	double value = read_signed_integer(file);
	
	if(peek_char(file) == '.') {
		get_char(file);
		
		int ch = peek_char(file);
		double divider = 10;
		while(ch >= '0' && ch <= '9') {
			value = value + (double)(ch-'0') / divider;
			divider *= 10;
			ch = get_char(file);
		}		
	}
	
	return value;
}


/**
 * Read string from file.
 */
void read_string(struct file_t *file, char *buffer, int length)
{
	int ch = peek_char(file);
	int i = 0;
	
	while(!isspace(ch)) {
		get_char(file);
		if(i < length - 1) {
			buffer[i] = ch;
			i++;
		}
		ch = peek_char(file);
	}
	buffer[i] = '\0';
}


/**
 * Read until newline.
 */
void read_line(struct file_t *file, char *buffer, int length)
{
  int ch;
  int i = 0;

  while(has_more(file) && (ch = peek_char(file)) != '\n') {
    ch = get_char(file);

    if(i < length - 1) {
      buffer[i] = ch;
      i++;
    }
  }
  buffer[i] = '\0';   
}


/**
 * Reads whitespace
 */
int read_whitespace(struct file_t *file)
{
  int count = 0;

	while(has_more(file) && isspace(peek_char(file))) {
		get_char(file);
    count++;
  }

  return count;
}
