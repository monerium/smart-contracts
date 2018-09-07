compile:
	npx truffle compile --all

migrate: 
	npx truffle migrate --reset

test: compile migrate
	npx truffle test

poa-migrate:
	npx truffle migrate --reset --network poa

poa-test: compile poa-migrate
	npx truffle test --network poa