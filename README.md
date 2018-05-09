# Sylius Docker Environment

> inspired by https://github.com/sylius/docker but with some enhancements

This project is intended as boilerplate and for bootstrapping your 100% dockerized Sylius development environment. It can 
also be used as blueprint to use in an automated deployment pipeline achieving Dev/Prod-Parity.

The development environment consists of 5 services,

  * nginx 
  * php-fpm (7.2)
  * Percona 5.7 as database
  * [MailHog](https://github.com/mailhog/MailHog) for testing outgoing email
  * nodejs

You can control, customize and extend the behaviour of this environment with bash script `console.sh`.

# Development

## Requirements

Because ``docker-compose.yml`` uses Compose file format 2.1 at least **Docker version 1.12** is required for this environment.

## Quickstart

```bash
git clone https://github.com/zemd/sylius-bootstrap-docker myshinyapp
cd myshinyapp
./console.sh create-project [options]
./console.sh npm install
./console.sh gulp
./console.sh console sylius:install
./console.sh up -d
./console.sh down
```

You may use `docker` or `docker-compose` utilities instead of `console.sh`. This script is only small wrapper around these commands.

## Running Symfony Console

You can always execute Symfony Console either by getting an interactive shell in the application container using ``./console.sh console``.

When using the wrapper target you can pass arguments to ``console``:

```bash
./console.sh console sylius:install
./console.sh console sylius:user:promote awesome@sylius.org
./console.sh console sylius:theme:assets:install web --symlink --relative
```

## Available commands

```bash
./console.sh console [options]
./console.sh create-project [options]
./console.sh composer [options]
./console.sh test
./console.sh npm [options]
./console.sh yarn [options]
./console.sh gulp [options]
```

## License

sylius-bootstrap-docker is released under the MIT license.

## Donate

[![](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://www.patreon.com/red_rabbit)
[![](https://img.shields.io/badge/flattr-donate-yellow.svg)](https://flattr.com/profile/red_rabbit)

