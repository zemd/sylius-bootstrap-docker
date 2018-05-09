#!/usr/bin/env bash

# This is console utility to help developers to work with sylius and docker containers

CWD=$(pwd -P)

# Set environment variables
export RUN_AS_UID=${RUN_AS_UID:-33}
export COMPOSE_ENTRY_FILE=${COMPOSE_ENTRY_FILE:-"docker-compose.yml"}

## Sylius variables
export SYLIUS_VERSION=${SYLIUS_VERSION:-1.1.1}
export SYLIUS_NAME=${SYLIUS_NAME:-"sylius-standard"}
export SYLIUS_SOURCE_DIRNAME=${SYLIUS_SOURCE_DIRNAME:-sylius}
export SYLIUS_SOURCE_DIR=${SYLIUS_SOURCE_DIR:-"$CWD/$SYLIUS_SOURCE_DIRNAME"} # on host machine
export SYLIUS_WORKING_DIR=${SYLIUS_WORKING_DIR:-"/var/www/html"} # on guest machine

## Ports
export SYLIUS_PORT=${SYLIUS_PORT:-8000}
export DB_PORT=${DB_PORT:-3306}
export MAILHOG_PORT=${MAILHOG_PORT:-8025}

## Services' names
export SYLIUS_SERVICE_NAME=${SYLIUS_SERVICE_NAME:-phpfpm}
export NODEJS_SERVICE_NAME=${NODEJS_SERVICE_NAME:-nodejs}

## Database
export DB_NAME=${DB_NAME:-sylius_dev}
export DB_USER=${DB_USER:-sylius}
export DB_PASS=${DB_PASS:-sylius}
export DB_ROOT_PASS=${DB_ROOT_PASS:-sylius}

# Disable pseudo-TTY allocation for CI
TTY=""

if [ -z "BUILD_NUMBER" ]; then
	# Disable pseudo-tty allocation
	TTY="-T"
fi

COMPOSE="docker-compose"

if [ $# -gt 0 ]; then
	if [ "$1" == "console" ]; then
		shift 1
		$COMPOSE run --rm \
			-w $SYLIUS_WORKING_DIR \
			${SYLIUS_SERVICE_NAME} \
			bin/console "$@"

	elif [ "$1" == "create-project" ]; then
		# if "create-project" is used create new project in current directory with composer
		shift 1
		mkdir $SYLIUS_SOURCE_DIR
		$COMPOSE run --rm $TTY \
			-w $SYLIUS_WORKING_DIR \
			$SYLIUS_SERVICE_NAME \
			composer create-project sylius/sylius-standard . $SYLIUS_VERSION "$@"
		cd $SYLIUS_SOURCE_DIR
		chmod +x bin/console
		# Patch Sylius Standard from master (required for version < 1.1)
		rm -f app/config/parameters.yml
		curl -o app/config/parameters.yml.dist https://raw.githubusercontent.com/Sylius/Sylius-Standard/master/app/config/parameters.yml.dist
		$COMPOSE run --rm $TTY \
			-w $SYLIUS_WORKING_DIR \
			$SYLIUS_SERVICE_NAME \
			composer run-script post-install-cmd

	elif [ "$1" == "composer" ]; then
		# If "composer" is used pass-thru to "composer" inside a new container
		shift 1
		$COMPOSE run --rm $TTY \
			-w $SYLIUS_WORKING_DIR \
			${SYLIUS_SERVICE_NAME} \
			composer "$@"

	elif [ "$1" == "test" ]; then
		# If "test" is used run unit tests inside a new container
		shift 1
		$COMPOSE run --rm $TTY \
			${SYLIUS_SERVICE_NAME} \
			./vendor/bin/phpunit "$@"

	elif [ "$1" == "t" ]; then
		# Run phpunit within existed container
		shift 1
		$COMPOSE exec \
			-w $SYLIUS_WORKING_DIR \
			${SYLIUS_SERVICE_NAME} \
			sh -c "cd $SYLIUS_WORKING_DIR && ./vendor/bin/phpunit $@"

	elif [ "$1" == "npm" ]; then
		# If "npm" is used run npm inside a new container
		shift 1
		cd $SYLIUS_SOURCE_DIR
		$COMPOSE run --rm $TTY \
			-w $SYLIUS_WORKING_DIR \
			${NODEJS_SERVICE_NAME} \
			npm "$@"

	elif [ "$1"  == "yarn" ]; then
		# If "yarn" is used run yarn inside a new container
		shift 1
		$COMPOSE run --rm $TTY \
			-w $SYLIUS_WORKING_DIR \
			${NODEJS_SERVICE_NAME} \
			yarn $@

	elif [ "$1" == "gulp" ]; then
		# If "gulp" is used run gulp inside a new container.
		# gulp must be installed first with npm install/yarn install
		shift 1
		cd $SYLIUS_SOURCE_DIR
		$COMPOSE run --rm $TTY \
			-w $SYLIUS_WORKING_DIR \
			${NODEJS_SERVICE_NAME} \
			./node_modules/.bin/gulp "$@"

	else
		docker-compose "$@"
	fi
else
	# If no arguments passed run by default "docker-compose ps"
	docker-compose ps
fi
