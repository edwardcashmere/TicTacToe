.DEFAULT_GOAL=help

format: # format all files
	@mix format
test-format: # format and run tests
	@mix format && mix test

debug: # run the server in dev
	@iex -S mix phx.server

compile: # compile  project
	@mix compile 

asdf-setup: # install correct langugage versions from .tool-versions file install dependencies, create database and run migrations
	@asdf install && mix deps.get && mix ecto.create && mix ecto.migrate

setup: # install dependencies create database then run migration
	@mix deps.get && mix ecto.create && mix ecto.migrate

reset: # Reset the database, create a new database and run migrations again
	@mix ecto.drop && mix ecto.create && mix ecto.migrate 

help: # Show this help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

