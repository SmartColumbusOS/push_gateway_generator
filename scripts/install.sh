#!/bin/bash

mix local.rebar --force
mix local.hex --force
mix deps.get
mix format --check-formatted
mix credo
