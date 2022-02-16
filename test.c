#include <malloc.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void signalHandler(int signo, siginfo_t* info, void* context)
{
  fprintf(stderr, "\nSegmentation fault at address: %p\n", info->si_addr);
  abort();
}

int main()
{
  struct sigaction action = {0};
  action.sa_flags = SA_SIGINFO;
  action.sa_sigaction = signalHandler;
  if (sigaction(SIGSEGV, &action, NULL) == -1)
  {
    perror("sigaction");
    exit(EXIT_FAILURE);
  }

  fprintf(stderr, "sbrk: %p\n", sbrk(0));

  const int kTotalBytes = 1024 * 1024 * 64;      // 64 MiB
  const int kInitialAllocationBytes = 1024 * 16; // 16 KiB
  const int kPerAllocationBytes = 1024 * 200;    // 200 KiB

  for (int i = 0; i < kTotalBytes; i += kPerAllocationBytes)
  {
    void* p = malloc(i == 0 ? kInitialAllocationBytes : kPerAllocationBytes);
    fprintf(stderr, "%p ", p);
  }
  fprintf(stderr, "\n");

  malloc_stats();
}
