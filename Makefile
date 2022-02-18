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

.PHONY: slither
slither:
	slither .

.PHONY: smartcheck
smartcheck:
	npx smartcheck -p contracts

.PHONY: poa-migrate
poa-migrate:
	npx truffle migrate --reset --network poa

.PHONY: poa-test
poa-test: compile poa-migrate
	npx truffle test --network poa

.PHONY: rinkeby-migrate
rinkeby-migrate:
	npx truffle migrate --network rinkeby

.PHONY: goerli-migrate
goerli-migrate:
	npx truffle migrate --network goerli

.PHONY: polygon-pos-mumbai-migrate
polygon-pos-mumbai-migrate:
	npx truffle migrate --network polygon_pos_mumbai

.PHONY: polygon-pos-mainnet-migrate
polygon-pos-mainnet-migrate:
	npx truffle migrate --network polygon_pos_mainnet
