-include .env

.PHONY: all test deploy

build:; forge build # run 'make build' to build

install:
	forge install cyfrin/foundry-devops@0.2.2 --no-commit && \
	forge install smartcontractkit/chainlink-brownie-contracts@1.6.1 --no-commit && \
	forge install foundry-rs/forge-std@v1.8.2 --no-commit && \
	forge install transmissions11/solmate@v6 --no-commit

# Update Dependencies
update:; forge update

test:; forge test

snapshot:; forge snapshot

format:; forge fmt
coverage:; forge coverage

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	forge script script/DeployRaffle.s.sol:DeployRaffle $(NETWORK_ARGS)

createSubscription:
	forge script script/Interactions.s.sol:CreateSubscription $(NETWORK_ARGS)

addConsumer:
	forge script script/Interactions.s.sol:AddConsumer $(NETWORK_ARGS)

fundSubscription:
	forge script script/Interactions.s.sol:FundSubscription $(NETWORK_ARGS)