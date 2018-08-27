compile:
	npx truffle compile --all

migrate: 
	npx truffle migrate --reset

test: compile migrate
	npx truffle test
