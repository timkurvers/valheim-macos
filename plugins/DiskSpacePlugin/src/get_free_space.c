#include <stdint.h>
#include <sys/statvfs.h>

int64_t get_free_space(char* path) {
  struct statvfs buf;

  if (statvfs(path, &buf) != 0) {
    return -1;
  }

  return buf.f_bfree * buf.f_frsize;
}
