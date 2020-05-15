#ifndef LOG_H
#define LOG_H

#ifdef LOG_1
#define IF_LOG if(1)
#define LOG(s) printf("%s\n", s)
#endif

#ifdef LOG_0
#define IF_LOG if(0)
#define LOG(s) 
#endif


#endif