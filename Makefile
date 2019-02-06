.PHONY: build
build: compile

.PHONY: compile
compile:
	npx truffle compile --all

.PHONY: clean
clean:
	$(RM) -rf coverage*
	$(RM) -rf build

.PHONY: migrate
migrate: 
	npx truffle migrate --reset

.PHONY: test
test: compile migrate
	npx truffle test

.PHONY: coverage
coverage: 
	npx solidity-coverage

.PHONY: poa-migrate
poa-migrate:
	npx truffle migrate --reset --network poa

.PHONY: poa-test
poa-test: compile poa-migrate
	npx truffle test --network poa

.PHONY: rinkeby-migrate
rinkeby-migrate:
	npx truffle migrate --network rinkeby
