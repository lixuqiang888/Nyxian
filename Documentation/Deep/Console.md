## Implementing a ASCII capable Console in your Coding app

To implement a Console into your app you can use a popular framework called [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm)

It offers full ASCII support and is relatively easy to implement.

###### Implementation



## Stdandard Filedescriptors

This is a more advanced topic. It's not easy to implement support to listen to standard file descriptors. Tho I have ironed out approaches to get data from them correctly and sending it. As we usually use a logpipe we will use a logpipe in this case and set the write end to the logpipes write end.

- ###### Stdout & Stderr

  ```c
  int stdout_plus_err;
  
  void set_std_fd(int fd)
  {
    stdout_plus_err = fd;
  }
  
  int get_std_fd(void)
  {
    return stdout_plus_err;
  }
  ```

- ###### Stdin

  The stdin file descriptor is a bit harder to solve. In the case of stdin we hook stdin to first have a real sender and for the terminal emulator to be able to send data to stdin it self. We basically call `void pipe(int fd[2])` to first create out pipe and after we created the pipe we call `void dup2(int, int)` to hook out pipe reading end to the real "STDIN_FILENO" that has no receiver usually on iOS. then the terminal emulator can call `void sendchar(const uint8_t *ro_buffer, size_t len)` to send buffered data to the writing end of our stdin hook.

  ```c
  #include <stdio.h>
  #include <stdint.h>
  #include <unistd.h>
  #include <fcntl.h>
  
  int stdinfd[2];
  
  void stdin_init(void)
  {
      if (pipe(stdinfd) == -1)
          return;
      
      dup2(stdinfd[0], STDIN_FILENO);
  }
  
  void stdin_write(const uint8_t *ro_buffer, size_t len)
  {
      write(stdinfd[1], ro_buffer, len);
  }
  ```

  