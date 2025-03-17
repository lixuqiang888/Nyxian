# IO Module
## Description
Module to interact with the file system and the console.
## Macros
### Open Macros
<table border="1" cellpadding="8" cellspacing="0">
  <thead>
    <tr>
      <th>Macro</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>O_RDONLY</code></td>
      <td>Open for <strong>read-only</strong> access.</td>
    </tr>
    <tr>
      <td><code>O_WRONLY</code></td>
      <td>Open for <strong>write-only</strong> access.</td>
    </tr>
    <tr>
      <td><code>O_RDWR</code></td>
      <td>Open for <strong>read-write</strong> access.</td>
    </tr>
    <tr>
      <td><code>O_APPEND</code></td>
      <td>Writes will always <strong>append</strong> to the end of the file.</td>
    </tr>
    <tr>
      <td><code>O_CREAT</code></td>
      <td><strong>Create</strong> the file if it does not exist.</td>
    </tr>
    <tr>
      <td><code>O_EXCL</code></td>
      <td>Used with <code>O_CREAT</code>; fails if file exists. Ensures <strong>exclusive creation</strong>.</td>
    </tr>
    <tr>
      <td><code>O_TRUNC</code></td>
      <td>If file exists, <strong>truncate</strong> it to zero length.</td>
    </tr>
    <tr>
      <td><code>O_NOCTTY</code></td>
      <td>If file is a terminal, do <strong>not assign</strong> it as controlling terminal.</td>
    </tr>
    <tr>
      <td><code>O_SYNC</code></td>
      <td>Open for synchronous I/O; <strong>writes are flushed to disk immediately</strong>.</td>
    </tr>
    <tr>
      <td><code>O_DSYNC</code></td>
      <td>Similar to <code>O_SYNC</code>, but only <strong>data is synchronized</strong>, not metadata.</td>
    </tr>
    <tr>
      <td><code>O_NONBLOCK</code></td>
      <td>Open in <strong>non-blocking mode</strong>; I/O returns immediately.</td>
    </tr>
    <tr>
      <td><code>O_CLOEXEC</code></td>
      <td>Set <strong>close-on-exec</strong> flag; descriptor closed on <code>exec()</code>.</td>
    </tr>
    <tr>
      <td><code>O_ACCMODE</code></td>
      <td>Mask to extract access mode (<code>O_RDONLY</code>, <code>O_WRONLY</code>, <code>O_RDWR</code>).</td>
    </tr>
  </tbody>
</table>

### File Macros

<table border="1" cellpadding="8" cellspacing="0">
  <thead>
    <tr>
      <th>Macro</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>F_OK</code></td>
      <td>Check if a file exists (used with <code>access()</code> function).</td>
    </tr>
    <tr>
      <td><code>F_DUPFD</code></td>
      <td>Duplicate a file descriptor (used with <code>fcntl()</code>).</td>
    </tr>
    <tr>
      <td><code>F_GETFD</code></td>
      <td>Get file descriptor flags (like <code>FD_CLOEXEC</code>).</td>
    </tr>
    <tr>
      <td><code>F_SETFD</code></td>
      <td>Set file descriptor flags.</td>
    </tr>
    <tr>
      <td><code>F_GETFL</code></td>
      <td>Get file status flags (e.g., <code>O_NONBLOCK</code>, <code>O_APPEND</code>).</td>
    </tr>
    <tr>
      <td><code>F_SETFL</code></td>
      <td>Set file status flags.</td>
    </tr>
    <tr>
      <td><code>F_GETLK</code></td>
      <td>Check if a file lock is held (used with <code>fcntl()</code> and <code>struct flock</code>).</td>
    </tr>
    <tr>
      <td><code>F_SETLK</code></td>
      <td>Set (non-blocking) file lock.</td>
    </tr>
    <tr>
      <td><code>F_SETLKW</code></td>
      <td>Set file lock and wait (blocking) if lock is not immediately available.</td>
    </tr>
    <tr>
      <td><code>F_GETOWN</code></td>
      <td>Get PID or process group ID that receives <code>SIGIO</code>/<code>SIGURG</code> signals for asynchronous I/O.</td>
    </tr>
    <tr>
      <td><code>F_SETOWN</code></td>
      <td>Set PID or process group to receive <code>SIGIO</code>/<code>SIGURG</code> signals.</td>
    </tr>
    <tr>
      <td><code>F_RDLCK</code></td>
      <td>Set a <strong>read (shared) lock</strong> on file (used in <code>struct flock</code>).</td>
    </tr>
    <tr>
      <td><code>F_WRLCK</code></td>
      <td>Set a <strong>write (exclusive) lock</strong> on file.</td>
    </tr>
    <tr>
      <td><code>F_UNLCK</code></td>
      <td>Remove/unlock a previously set lock.</td>
    </tr>
  </tbody>
</table>

### Seek Macros

<table border="1" cellpadding="8" cellspacing="0">
  <thead>
    <tr>
      <th>Macro</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>SEEK_SET</code></td>
      <td>Set file offset to a specific position relative to the <strong>beginning of the file</strong>.</td>
    </tr>
    <tr>
      <td><code>SEEK_CUR</code></td>
      <td>Set file offset <strong>relative to the current file position</strong>.</td>
    </tr>
    <tr>
      <td><code>SEEK_END</code></td>
      <td>Set file offset relative to the <strong>end of the file</strong>.</td>
    </tr>
  </tbody>
</table>

### File Permission Bit Macros

<table border="1" cellpadding="8" cellspacing="0">
  <thead>
    <tr>
      <th>Macro</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>S_IFMT</code></td>
      <td>Bitmask for the file type bit fields (used to extract file type from <code>st_mode</code>).</td>
    </tr>
    <tr>
      <td><code>S_IFSOCK</code></td>
      <td>File type: <strong>socket</strong>.</td>
    </tr>
    <tr>
      <td><code>S_IFLNK</code></td>
      <td>File type: <strong>symbolic link</strong>.</td>
    </tr>
    <tr>
      <td><code>S_IFREG</code></td>
      <td>File type: <strong>regular file</strong>.</td>
    </tr>
    <tr>
      <td><code>S_IFBLK</code></td>
      <td>File type: <strong>block device</strong>.</td>
    </tr>
    <tr>
      <td><code>S_IFDIR</code></td>
      <td>File type: <strong>directory</strong>.</td>
    </tr>
    <tr>
      <td><code>S_IFCHR</code></td>
      <td>File type: <strong>character device</strong>.</td>
    </tr>
    <tr>
      <td><code>S_IFIFO</code></td>
      <td>File type: <strong>FIFO (named pipe)</strong>.</td>
    </tr>
    <tr>
      <td><code>S_IRWXU</code></td>
      <td>Owner permissions: <strong>read, write, execute</strong> (rwx).</td>
    </tr>
    <tr>
      <td><code>S_IRUSR</code></td>
      <td>Owner permission: <strong>read</strong> (r).</td>
    </tr>
    <tr>
      <td><code>S_IWUSR</code></td>
      <td>Owner permission: <strong>write</strong> (w).</td>
    </tr>
    <tr>
      <td><code>S_IXUSR</code></td>
      <td>Owner permission: <strong>execute/search</strong> (x).</td>
    </tr>
    <tr>
      <td><code>S_IRWXG</code></td>
      <td>Group permissions: <strong>read, write, execute</strong> (rwx).</td>
    </tr>
    <tr>
      <td><code>S_IRGRP</code></td>
      <td>Group permission: <strong>read</strong> (r).</td>
    </tr>
    <tr>
      <td><code>S_IWGRP</code></td>
      <td>Group permission: <strong>write</strong> (w).</td>
    </tr>
    <tr>
      <td><code>S_IXGRP</code></td>
      <td>Group permission: <strong>execute/search</strong> (x).</td>
    </tr>
    <tr>
      <td><code>S_IRWXO</code></td>
      <td>Others permissions: <strong>read, write, execute</strong> (rwx).</td>
    </tr>
    <tr>
      <td><code>S_IROTH</code></td>
      <td>Others permission: <strong>read</strong> (r).</td>
    </tr>
    <tr>
      <td><code>S_IWOTH</code></td>
      <td>Others permission: <strong>write</strong> (w).</td>
    </tr>
    <tr>
      <td><code>S_IXOTH</code></td>
      <td>Others permission: <strong>execute/search</strong> (x).</td>
    </tr>
    <tr>
      <td><code>S_ISUID</code></td>
      <td>Set-user-ID on execution.</td>
    </tr>
    <tr>
      <td><code>S_ISGID</code></td>
      <td>Set-group-ID on execution.</td>
    </tr>
    <tr>
      <td><code>S_ISVTX</code></td>
      <td>Sticky bit (restricts file deletion; used on directories like <code>/tmp</code>).</td>
    </tr>
  </tbody>
</table>

### Directory Macros

<table border="1" cellpadding="8" cellspacing="0">
  <thead>
    <tr>
      <th>Macro</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>DT_BLK</code></td>
      <td>Block device file.</td>
    </tr>
    <tr>
      <td><code>DT_CHR</code></td>
      <td>Character device file.</td>
    </tr>
    <tr>
      <td><code>DT_DIR</code></td>
      <td>Directory.</td>
    </tr>
    <tr>
      <td><code>DT_LNK</code></td>
      <td>Symbolic link.</td>
    </tr>
    <tr>
      <td><code>DT_REG</code></td>
      <td>Regular file.</td>
    </tr>
    <tr>
      <td><code>DT_WHT</code></td>
      <td>Whiteout (used on some filesystems like unionfs, rarely used in general).</td>
    </tr>
    <tr>
      <td><code>DT_FIFO</code></td>
      <td>FIFO (named pipe).</td>
    </tr>
    <tr>
      <td><code>DT_SOCK</code></td>
      <td>Socket.</td>
    </tr>
    <tr>
      <td><code>DT_UNKNOWN</code></td>
      <td>Unknown file type.</td>
    </tr>
  </tbody>
</table>

## Functions
### print
```
io.print(<string:content>);
```
Prints the specified string to the console.

### readline
```
let ret = io.readline(<string:prompt>);
```
Displays a prompt message and waits for the user to input a line. Returns the inputted string when the user presses Enter.

### getchar
```
let ret = io.getchar();
```
Waits for the user to input a single character and returns it once typed.

### open
```
try {
    let fd = io.open(<string:path>, <integer:flags>, <integer:mode>);
} catch (error) {
    io.print(error);
}
```
Opens a file for reading, writing, or appending using the specified flags. Optionally, a mode can be set if the file needs to be created. Returns the file descriptor.

### close

```
try {
    io.close(<integer:fd>);
} catch (error) {
    io.print(error);
}
```
Closes the file descriptor passed as an argument.

### write

```
try {
    io.write(<integer:fd>, <string:content>, <integer:size>);
} catch (error) {
    io.print(error);
}
```
Writes the specified content to the file descriptor, limited by the specified size. Returns the number of bytes written.

### read

```
try {
    let ret = io.read(<integer:fd>, <integer:size>);
} catch (error) {
    io.print(error);
}
```
Reads data from the specified file descriptor. Returns an object containing the `size` of the buffer and the `buffer` itself, representing the data read.

### stat

```
try {
    let stat = io.stat(<integer:fd>);
} catch (error) {
    io.print(error);
}
```
Returns a `stat` object containing detailed information about the file descriptor.

### seek

```
try {
    io.seek(<integer:fd>, <integer:position>, <integer:flags>);
} catch (error) {
    io.print(error);
}
```
Moves the file pointer to the specified position, using the given flags (e.g., `SEEK_SET`).

### access

```
try {
    io.access(<string:path>, <integer:flags>);
} catch (error) {
    io.print(error);
}
```
Checks the specified file path for access rights based on the flags (e.g., `F_OK`). Returns an integer value indicating success or failure.

### remove

```
try {
    io.remove(<string:path>);
} catch (error) {
    io.print(error);
}
```
Removes the file or directory at the given path.

### mkdir

```
try {
    io.mkdir(<string:path>, <integer:mode>);
} catch (error) {
    io.print(error);
}
```
Creates a new directory at the specified path with the given mode.

### rmdir

```
try {
    io.rmdir(<string:path>);
} catch (error) {
    io.print(error);
}
```
Removes the directory at the specified path.

### chown

```
try {
    io.chown(<string:path>, <integer:uid>, <integer:gid>);
} catch (error) {
    io.print(error);
}
```
Changes the ownership of the file or directory at the specified path.

### chmod

```
try {
    io.chmod(<string:path>, <integer:flags>);
} catch (error) {
    io.print(error);
}
```
Changes the permissions of the file or directory at the specified path using the given flags.

### fopen

```
try {
    let file = io.fopen(<string:path>, <string:mode>);
} catch (error) {
    io.print(error);
}
```

### fclose

```
try {
    io.fclose(<FILE:file object>);
} catch (error) {
    io.print(error);
}
```
Opens a file with the specified path and mode. Similar to open but takes a mode string (e.g., "r", "w").

### freopen

```
try {
    let file = io.freopen(<string:path>, <string:mode>, <FILE:file object>);
} catch (error) {
    io.print(error);
}
```
This function reopens a file with a different mode. It is useful when you want to change the file mode of an already opened file without closing it and reopening it. The function returns the file object after reopening the file.

### opendir

```
try {
    let dir = io.opendir(<string:path>);
} catch (error) {
    io.print(error);
}
```
This function opens a directory stream, which can be used to read the contents of a directory.

### closedir

```
try {
    io.closedir(<DIR:directory object>);
} catch (error) {
    io.print(error);
}
```
This function closes a previously opened directory stream. It's important to call this when you're done reading the directory contents to release resources.

### readdir

```
try {
    let dirent = io.readdir(<DIR:directory object>);
} catch (error) {
    io.print(error);
}
```
This function reads the next directory entry from the opened directory stream. It returns an object containing the file/directory name.

### rewinddir

```
try {
    let dir = io.rewinddir(<DIR:directory object>);
} catch (error) {
    io.print(error);
}
```
This function resets the position of the directory stream, allowing you to start reading the directory from the beginning again.
