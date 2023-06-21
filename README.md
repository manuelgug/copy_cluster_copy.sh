                                           ______             _____                                                   ______  
    _________________________  __    _________  /___  __________  /_____________ _________________________  __ __________  /_ 
    _  ___/  __ \__  __ \_  / / /    _  ___/_  /_  / / /_  ___/  __/  _ \_  ___/ _  ___/  __ \__  __ \_  / / / __  ___/_  __ \
    / /__ / /_/ /_  /_/ /  /_/ /     / /__ _  / / /_/ /_(__  )/ /_ /  __/  /     / /__ / /_/ /_  /_/ /  /_/ /___(__  )_  / / /
    \___/ \____/_  .___/_\__, /______\___/ /_/  \__,_/ /____/ \__/ \___//_/______\___/ \____/_  .___/_\__, /_(_)____/ /_/ /_/ 
                /_/     /____/_/_____/                                    _/_____/           /_/     /____/                   

The `copy_cluster_copy.sh` script allows you to copy files or directories locally or between a local machine and a remote cluster using the Secure Copy Protocol (SCP). It also performs an integrity check using MD5 checksums to ensure the successful transfer of data.

### Usage

```bash
$ ./copy_cluster_copy.sh [SOURCE] [DESTINATION]
```

### Arguments

- `SOURCE`: The path to the source file or directory. It can be a local path or a remote path in the format `user@server:/path/to/source`.
- `DESTINATION`: The path to the destination directory. It can be a local path or a remote path in the format `user@server:/path/to/destination`.

### Functionality

The script performs the following actions based on the provided arguments:

1. Extracts the server and source paths.
2. Transfers the source directory using SCP.
3. Calculates the MD5 checksum of server and local directories.
4. Compares the server and local MD5 checksums and displays the results.

### Example

#### Local to Cluster Transfer

```bash
$ ./copy_cluster_copy.sh dir username@server:/path/to/remote/.
```

#### Cluster to Local Transfer

```bash
$ ./copy_cluster_copy.sh username@server:/path/to/remote/dir . 
```

Please note that the script requires SSH and SCP to be properly configured for the remote server to enable successful transfers.
