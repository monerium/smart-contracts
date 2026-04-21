# V1Block Fix — Upgrade Playbook

## Background

On Ethereum, Gnosis, and Polygon, each token currency (EUR, USD, GBP, ISK) has two live interfaces sharing the same on-chain state:

- **V1 (TokenFrontend)** — immutable, legacy address. Delegates all calls to the V2 proxy via `_withCaller` functions.
- **V2 (ERC1967Proxy)** — the canonical token. Stores all balances. Implements `EthereumControllerToken` / `GnosisControllerToken` / `PolygonControllerToken`.

`V1_BLOCKED_ROLE` was introduced to block specific counterparties (e.g. Balancer V3 Vault) from the V1 frontend only, while still permitting V2 direct transfers. This prevents a double-entrypoint exploit where both EURE_V1 and EURE_V2 share state and could be used to drain a Balancer pool.

### The Bug

The original implementation checked `V1_BLOCKED_ROLE` inside `Validator.validate()`. Because the ControllerToken runs via `delegatecall` inside the V2 proxy, `msg.sender` in `validate()` is always the V2 proxy — regardless of whether the transfer originated from V1 or V2. As a result, the V1 block check fired for all transfers, including legitimate V2 direct transfers to blocked addresses.

### The Fix

V1 block enforcement moved to `ControllerToken._withCaller` functions (`transfer_withCaller`, `transferFrom_withCaller`, `transferAndCall_withCaller`). These are the exclusive V1 entrypoints, already gated by `onlyFrontend`. `Validator.validate()` is now chain-agnostic and checks the blacklist only. Block-list data management (`V1_BLOCKED_ROLE`, `setV1Blocked`, `revokeV1Blocked`) stays in `Validator` for centralised admin control.

**After this upgrade:**
- V1 transfer to a V1-blocked address → reverts with `V1Blocked(address)`
- V2 direct transfer to a V1-blocked address → succeeds
- Blacklisted addresses are blocked on both V1 and V2 paths (unchanged)

---

## Proxy Addresses

These are the V2 proxy addresses (upgrade targets) verified on-chain. Note that for Ethereum, the public token list for GBPe/USDe/ISKe shows the immutable V1 frontend addresses — the actual upgradeable proxies are the controller addresses behind them.

### Ethereum (chainId 1)

| Token | V2 Proxy |
|-------|----------|
| EURe | `0x39b8B6385416f4cA36a20319F70D28621895279D` |
| GBPe | `0x78a20B7AF85156B4389a349Aa4c96efC2E509768` |
| USDe | `0x05968f40939fdc016AD58F82Cd08dA884825aD55` |
| ISKe | `0x38D22BD604c4549e2cC15e94B8e22E6FE4aE82B4` |

### Gnosis (chainId 100)

| Token | V2 Proxy |
|-------|----------|
| EURe | `0x420CA0f9B9b604cE0fd9C18EF134C705e5Fa3430` |
| GBPe | `0x8E34bfEC4f6Eb781f9743D9b4af99CD23F9b7053` |
| USDe | `0x50D1A74F4b6dcaCddD97fd442C0e22a4c97F2b7f` |
| ISKe | `0x614Bd419D3735C9eb51542C06e5Acc09a9953f61` |

### Polygon (chainId 137)

| Token | V2 Proxy |
|-------|----------|
| EURe | `0xE0aEa583266584DafBB3f9C3211d5588c73fEa8d` |
| GBPe | `0x646BEea7a02FdAdA34c8e118949fE32350aB2206` |
| USDe | `0x91e2B584908C2807EFc9F846E0C2A1fe875C5141` |
| ISKe | `0xd053fc09e8F05A43Da4ECC40a750559C938C8131` |

### Sepolia (chainId 11155111) — testnet

| Token | V2 Proxy |
|-------|----------|
| EURe | `0x67b34b93ac295c985e856E5B8A20D83026b580Eb` |
| GBPe | `0x539fA90D0a29eB2a513f6b88fEd30b529dF071ca` |
| USDe | `0xEc262C76Ff70330BBa90e2c477B185d6665c4aA2` |
| ISKe | `0x429D7bAe4436394150fdfBbfB01aBC9270B6F2b8` |

Safe owner (Sepolia): `0x5e0A62e88FA3fbf15c2A14A7CDf3a6d625B1E58f`

---

## What Changes on Chain

For each of the three chains (Ethereum, Gnosis, Polygon):

| Contract | Change |
|----------|--------|
| `Validator` (new deploy) | Removes V1 detection logic from `validate()`; manages `V1_BLOCKED_ROLE` data only |
| `*ControllerToken` (new impl) | Adds V1 block check in `_withCaller` functions; reads `isV1Blocked` / `getV1BlockedCount` from Validator |
| Each token proxy (EUR, USD, GBP, ISK) | Points at new implementation + new Validator via `upgradeToAndCall` + `setValidator` |

One `Validator` is deployed per chain and shared across all four token proxies on that chain.

---

## Ownership Model

The V2 proxies are owned by a **Gnosis Safe** (6 signers) on each chain. No ownership transfer is required. The upgrade is split by permission level:

| Step | Who executes | Why |
|------|-------------|-----|
| Deploy `Validator` | Any funded EOA | Permissionless — no proxy ownership required |
| Deploy new `*ControllerToken` implementation | Any funded EOA | Permissionless — implementations are standalone contracts |
| `proxy.upgradeToAndCall(newImpl, "")` | Safe | `onlyOwner` |
| `proxy.setValidator(newValidator)` | Safe | `onlyOwner` |

The two Safe calls per proxy should be batched into a **single Safe transaction** using the Transaction Builder's MultiSend, so the upgrade is atomic — there is no window where a proxy is running the new implementation but still pointing at the old Validator.

---

## Scripts

### `script/UpgradeV1BlockFix.s.sol`

Contains all Forge script contracts for this upgrade:

| Contract | Purpose |
|----------|---------|
| `DeployValidator` | Deploy new `Validator`, grant `ADMIN_ROLE` to `VALIDATOR_ADMIN` |
| `DeployImplEthereum` | Deploy new `EthereumControllerToken` implementation |
| `DeployImplGnosis` | Deploy new `GnosisControllerToken` implementation |
| `DeployImplPolygon` | Deploy new `PolygonControllerToken` implementation |
| `PrintSafeCalldata` | Print encoded calldata for the two Safe transactions per proxy (no broadcast) |

### `script/upgradeV1BlockFix.sh`

Orchestrates the full upgrade for all four token proxies on a given chain:

1. Deploys the new `Validator` (step 1a)
2. Deploys the new chain-specific implementation (step 1b)
3. Prints the Safe calldata for each proxy (EUR, USD, GBP, ISK)

---

## Environment Variables

Set these in `.env.local` before running any script.

```bash
# Deployer — any funded EOA, does not need to be the proxy owner
PRIVATE_KEY=0x...

# Address that will hold ADMIN_ROLE on the new Validator (typically the ops Safe or an admin EOA)
VALIDATOR_ADMIN=0x...

# V2 proxy addresses for the target chain
PROXY_EUR=0x...
PROXY_USD=0x...
PROXY_GBP=0x...
PROXY_ISK=0x...
```

Chain-specific RPC and verifier vars (already in `.env.local` from previous deployments):

| Chain | Vars needed |
|-------|------------|
| Ethereum mainnet | `ETHEREUM_RPC`, `ETHERSCAN_API_KEY` |
| Sepolia | `SEPOLIA_RPC`, `ETHERSCAN_API_KEY` |
| Gnosis mainnet | `GNOSIS_RPC`, `GNOSISSCAN_API`, `GNOSISSCAN_URL`, `GNOSIS_CHAIN_ID` |
| Gnosis Chiado | `GNOSIS_CHIADO_RPC`, `GNOSIS_CHIADO_BLOCKSCOUT_URL`, `GNOSIS_CHIADO_CHAIN_ID` |
| Polygon mainnet | `POLYGON_RPC`, `POLYGONSCAN_API`, `POLYGONSCAN_URL`, `POLYGON_CHAIN_ID` |
| Polygon Amoy | `POLYGON_AMOY_RPC`, `POLYGONSCAN_API`, `POLYGONSCAN_AMOY_URL`, `POLYGON_AMOY_CHAIN_ID` |

---

## Upgrade Procedure

### Step 0 — Testnet dry run

Run the full upgrade on testnets first and verify behaviour before touching mainnet.

```bash
source .env.local

# Gnosis Chiado
sh script/upgradeV1BlockFix.sh --gnosis-chiado

# Polygon Amoy
sh script/upgradeV1BlockFix.sh --polygon-amoy

# Sepolia
sh script/upgradeV1BlockFix.sh --sepolia
```

After each testnet run, verify on the block explorer that:
- The new `Validator` contract is deployed and verified
- The proxy's implementation slot points at the new contract
- `proxy.validator()` returns the new Validator address
- A test V2 direct transfer to a previously-blocked address succeeds
- A test V1 transfer to a previously-blocked address reverts

### Step 1 — Deploy contracts (EOA)

```bash
source .env.local

# Gnosis mainnet
sh script/upgradeV1BlockFix.sh --gnosis

# Polygon mainnet
sh script/upgradeV1BlockFix.sh --polygon

# Ethereum mainnet
sh script/upgradeV1BlockFix.sh --ethereum
```

The script outputs something like:

```
New Validator  : 0xAAAA...
New Impl       : 0xBBBB...

=== Step 2: Safe calldata for EUR proxy ===
=== Safe transactions for proxy: 0xCCCC... ===

tx1: upgradeToAndCall
  to  : 0xCCCC...
  data: 0x4f1ef286...

tx2: setValidator
  to  : 0xCCCC...
  data: 0x1256ab96...

=== Step 2: Safe calldata for USD proxy ===
...
```

Note the `Validator` and `Impl` addresses — you will need them for the Safe transactions.

### Step 2 — Execute via Safe

For each chain, submit **four Safe transactions** (one per token proxy), each batching two calls:

1. Open the Safe Transaction Builder for the chain's Safe
2. For each proxy (EUR, USD, GBP, ISK):
   - Add transaction: `to = <proxy>`, `data = <upgradeToAndCall calldata>`
   - Add transaction: `to = <proxy>`, `data = <setValidator calldata>`
   - Batch both into a single Safe transaction and submit for signing
3. Collect 6 signatures and execute

To regenerate the calldata at any time without re-deploying:

```bash
PROXY=0x... IMPL=0x... VALIDATOR=0x... \
  forge script script/UpgradeV1BlockFix.s.sol:PrintSafeCalldata \
  --rpc-url $RPC_URL -vvvv
```

### Step 3 — Post-upgrade verification

For each chain, confirm on-chain:

- [ ] `proxy.validator()` returns the new `Validator` address on all four proxies
- [ ] New `Validator` is verified on the block explorer
- [ ] New implementation is verified on the block explorer
- [ ] `validator.isAdminAccount(<VALIDATOR_ADMIN>)` returns `true`
- [ ] V2 direct transfer to a V1-blocked address succeeds (no regression)
- [ ] V1 transfer to a V1-blocked address reverts with `V1Blocked(address)`
- [ ] Normal V1 and V2 transfers succeed for non-blocked addresses
- [ ] Blacklisted addresses are still blocked on both paths

---

## Rollback

The UUPS proxy stores the implementation address in a standard slot (`EIP-1967`). To roll back, the Safe calls `upgradeToAndCall(previousImpl, "")` and `setValidator(previousValidator)` — the same two-call pattern in reverse. Previous addresses are available in the forge broadcast logs under `broadcast/UpgradeV1BlockFix.s.sol/`.
