#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mex.h"
#include "utils.h"

#define MAX_CHUNK_SIZE 1024


/****************
 * Sample buffer
 */

struct chunk_t
{
  int size;
  double data[MAX_CHUNK_SIZE][5];
  struct chunk_t *next;
};


struct chunk_t *create_chunk()
{
  struct chunk_t *chunk = (struct chunk_t *) malloc(sizeof(struct chunk_t));
  chunk->size = 0;
  chunk->next = NULL;
  return chunk;
}


struct message_t
{
  double time;
  mxArray *message;
  struct message_t *next;
};


struct message_t *create_message(int time, char *msg)
{
  struct message_t *message = (struct message_t *) malloc(sizeof(struct message_t));
  message->time = time;
  message->message = mxCreateString(msg);
  message->next = NULL;
  return message;
}


struct buffer_t
{
  int nsamples;
  int nmessages;

  struct chunk_t *first;
  struct chunk_t *last;
  
  struct message_t *first_msg;
  struct message_t *last_msg;
};


void add_sample(struct buffer_t *buffer, int time, double data[])
{
  int i = 0;

  buffer->nsamples++;

  if(buffer->first == NULL) {
    buffer->first = create_chunk();
    buffer->last = buffer->first;
  }

  if(buffer->last->size == MAX_CHUNK_SIZE) {
    buffer->last->next = create_chunk();
    buffer->last = buffer->last->next;
  }

  buffer->last->data[buffer->last->size][0] = (double) time / 1000.0;
  for(i = 0; i < 4; i++)
    buffer->last->data[buffer->last->size][1 + i] = data[i];
  buffer->last->size++;
}


void add_message(struct buffer_t *buffer, int time, char *message)
{
  buffer->nmessages++;
  
  if(buffer->first_msg == NULL) {
    buffer->first_msg = create_message(time, message);
    buffer->last_msg = buffer->first_msg;
  } else {
    buffer->last_msg->next = create_message(time, message);
    buffer->last_msg = buffer->last_msg->next;
  }
}


struct buffer_t *create_buffer()
{
  struct buffer_t *buffer = (struct buffer_t *) malloc(sizeof(struct buffer_t));
  buffer->nsamples = 0;
  buffer->first = NULL;
  buffer->last = NULL;

  buffer->nmessages = 0;
  buffer->first_msg = NULL;
  buffer->last_msg = NULL;
  
  return buffer;
}


void destroy_buffer(struct buffer_t **buffer)
{
  struct chunk_t *chunk = (*buffer)->first;

  while(chunk) {
    (*buffer)->first = chunk->next;
    free(chunk);
    chunk = (*buffer)->first;
  }

  struct message_t *message = (*buffer)->first_msg;

  while(message) {
    (*buffer)->first_msg = message->next;
    free(message);
    message = (*buffer)->first_msg;
  }
  
  free(*buffer);
}


/******************************
 * Reading of data into buffer
 */


void read_sample_into_buffer(struct buffer_t *buffer, struct file_t *file)
{
  int time;
  double data[4];

	time = read_signed_integer(file); 
  
  if(peek_char(file) == '\n')
    return;
  
  read_whitespace(file);
	data[0] = read_double(file); read_whitespace(file);
	data[1] = read_double(file); read_whitespace(file);
	read_double(file); read_whitespace(file);
	data[2] = read_double(file); read_whitespace(file);
	data[3] = read_double(file); read_whitespace(file);
	read_double(file); read_whitespace(file);

  add_sample(buffer, time, data);
}


void parse_file(struct buffer_t *buffer, struct file_t *file)
{
  char string[100];
  int time = 0;

  /* Skip comments */
	while(peek_char(file) == '\n' || peek_char(file) == '*') {
		while(get_char(file) != '\n') {}
	}

	int ch = 0;
	while(has_more(file)) {
		ch = peek_char(file);

    if(ch == -1) break;

		if(ch >= '0' && ch <= '9') {
			read_sample_into_buffer(buffer, file);
		} else {
			read_string(file, string, 100);
			read_whitespace(file);
			
			if(strcmp(string, "MSG") == 0) {
				time = read_signed_integer(file);
				read_whitespace(file);
        char line[1024];
        read_line(file, line, 1024);
        add_message(buffer, time, line);

        /*while(has_more(file) && (ch = peek_char(file)) != '\n') { get_char(file); }*/
			} else if(strcmp(string, "START") == 0) {
				time = read_signed_integer(file);
        add_message(buffer, time, "START");        
			} else if(strcmp(string, "END") == 0) {
				time = read_signed_integer(file);
        add_message(buffer, time, "STOP");
			} else {
        char line[1024];
        read_line(file, line, 1024);
        
        char tmp[1024];        
        strcpy(tmp, string);
        strcat(tmp, " ");
        strcat(tmp, line);
        
        add_message(buffer, time, tmp);        
      }
		}	    
 
		/* Skip to end of line */
		while(has_more(file) && (ch = get_char(file)) != '\n') {
    }
	}
}


/****************
 * Main function
 */


mxArray *buffer_to_array(struct buffer_t *buffer)
{
  mwSize dims[2];
  dims[0] = 5;
  dims[1] = buffer->nsamples;
  
  mxArray *array = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
  double *data = mxGetData(array);
 
  struct chunk_t *chunk = buffer->first;
  
  while(chunk != NULL) {    
    memcpy(data, chunk->data, sizeof(double) * 5 * chunk->size);
    data += (5 * chunk->size);
    chunk = chunk->next;
  }
  
  return array;
}


mxArray *buffer_to_cell(struct buffer_t *buffer)
{
  mxArray *cell = mxCreateCellMatrix(buffer->nmessages, 2);
  
  struct message_t *message = buffer->first_msg;
  int i = 0;
  
  while(message) {
    mxArray *array = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    double *data = mxGetData(array);
    *data = message->time / 1000.0;
    
    mxSetCell(cell, i, array);
    mxSetCell(cell, i + buffer->nmessages, message->message);
    message = message->next;
    
    i++;
  }
  
  return cell;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if(nrhs != 1 || nlhs != 2)
    return;  
	
  /* Open file */
  char *filename = mxArrayToString(prhs[0]);
	struct file_t *file = open_file(filename);
  mxFree(filename);      

  if(!file) {
    fprintf(stderr, "Could not open file.\n");
    return;
  }

  /* Create buffer and parse file */
  struct buffer_t *buffer = create_buffer();
  parse_file(buffer, file);

  /* Copy samples into matlab structure! */
  plhs[0] = buffer_to_array(buffer);
  plhs[1] = buffer_to_cell(buffer);
  
  /* printf("Samples: %d\n", buffer->nsamples); */
  destroy_buffer(&buffer);
  
	close_file(&file);
}

