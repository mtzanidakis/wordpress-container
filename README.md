# Containerized WordPress with NGINX Unit

Run a containerized [WordPress](https://wordpress.org/) with [NGINX Unit](https://unit.nginx.org/).

The container image is based on [Alpine Linux](https://www.alpinelinux.org/) and [PHP](https://www.php.net/) 8.3.

## Configuration

The following configuration options are available, passed as environment variables:

- `EMAIL_FROM`: The email address to use for sending emails; defaults to `wordpress@example.com`.
- `MAXUPLOAD`: The maximum upload size in bytes; defaults to `32M`.
- `PHPEXECTIME`: The maximum execution time for PHP scripts; defaults to `60`.
- `PHPMAX`: The maximum number of PHP processes; defaults to `20`.
- `PHPMEMORY`: The maximum memory per PHP process; defaults to `256M`.
- `PHPSPARE`: The number of spare PHP processes; defaults to `5`.
- `PGID`: The group ID to use for the PHP process.
- `PUID`: The user ID to use for the PHP process.
