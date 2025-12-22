## Scope
We have a problem with aggregators like CoW swap being unable to connect the V1 and V2 liquidity together.

## Solution

The `SwapV1V2` contract that enables 1:1 token swapping between V1 and V2 tokens that share the same balance storage. The contract supports five swap methods:

  - `swapExactIn`: Basic 1:1 swap with slippage protection
  - `swapWithPermitStrict`: Swap with ERC-2612 permit for gasless approvals (strict mode - fails if permit fails)
  - `swapWithPermitBestEffort`: Swap with optional permit that continues even if permit fails
  - `sellGem`: LitePSM-compatible function to sell V1 for V2 
  - `buyGem`: LitePSM-compatible function to buy V1 with V2

### Key features:
  - **OpenZeppelin Upgradeable Pattern**: Uses UUPS (Universal Upgradeable Proxy Standard) for future contract upgrades
  - 1:1 exchange rate (no reserves needed)
  - Reentrancy protection via `ReentrancyGuardUpgradeable`
  - Support for ERC-2612 permits
  - Slippage protection via minOut parameter
  - Owner-controlled upgrades via `OwnableUpgradeable`
  - **LitePSM Compatibility**: Provides `sellGem` and `buyGem` functions for aggregator integration
  - **Shared State Optimization**: Skips transfers when sender equals recipient (V1/V2 share same storage)

### Contract Implementation

  - `SwapV1V2.sol`: Main swap contract that facilitates 1:1 swaps between two tokens
  - **Upgradeable Architecture**: Inherits from `Initializable`, `OwnableUpgradeable`, `UUPSUpgradeable`, and `ReentrancyGuardUpgradeable`
  - **Proxy Pattern**: Deployed using ERC1967Proxy with proper initialization instead of constructor
  - **Storage Compatibility**: Maintains storage layout compatibility with V1/V2 shared storage principle
  - **LitePSM Integration**: Added `sellGem` and `buyGem` functions with same 1:1 swap logic
  - **Shared State Optimization**: All functions skip transfers when `msg.sender == recipient` since V1/V2 share storage
  - Implemented permit functionality with proper calldata decoding (97 bytes packed format)
  - Added comprehensive error handling (BadPair, ZeroAmount, slippage)

### Upgradeable Pattern Implementation

The contract follows OpenZeppelin's recommended upgradeable pattern:

```solidity
contract SwapV1V2 is Initializable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address v1, address v2, address initialOwner) public initializer {
        V1 = v1;
        V2 = v2;
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
```

**Key Benefits:**
- **Future-proof**: Contract can be upgraded to add new features or fix issues
- **Owner-controlled**: Only the contract owner can authorize upgrades
- **State preservation**: All contract state (V1, V2 addresses, ownership) is preserved across upgrades
- **Storage safety**: Uses OpenZeppelin's proven upgradeable patterns to avoid storage collisions

### Key Technical Details

  - Uses abi.encodePacked for 97-byte permit calldata format: deadline(32) + v(1) + r(32) + s(32)
  - Manual decoding of packed permit data in swapWithPermitBestEffort
  - Best-effort permit calls use low-level calls to avoid reverting the entire transaction
  - Proper event emissions for all swap operations
  - **Proxy deployment**: Uses ERC1967Proxy for transparent upgrades

### 1:1 Price Guarantee

The contract ensures a guaranteed 1:1 exchange rate through:
  - Deterministic Quote Function: quote(tokenIn, tokenOut, amountIn) returns amountIn for valid pairs, 0 for invalid pairs
  - No Price Discovery: Unlike AMMs, there are no reserves or price calculations - always amountOut = amountIn
  - Pair Validation: Only allows swaps between the configured V1 and V2 token addresses
  - Direct Transfer Logic: Contract receives amountIn of tokenIn and sends exactly amountIn of tokenOut

```solidity
function quote(address tokenIn, address tokenOut, uint256 amountIn)
    external view returns (uint256) {
    return _isPair(tokenIn, tokenOut) ? amountIn : 0;  // Always 1:1 or 0
}
```
 
This makes the contract suitable for pathfinders and aggregators that need predictable pricing.

### LitePSM Compatibility Functions

The contract includes two additional functions to provide compatibility with LitePSM-style interfaces expected by some aggregators and solvers:

#### `sellGem(address usr, uint256 gemAmt)`
- **Purpose**: Sell V1 token and receive V2 token (V1 → V2)
- **Parameters**: 
  - `usr`: Address of the V2 token recipient
  - `gemAmt`: Amount of V1 token being sold
- **Returns**: Amount of V2 token received (always equals `gemAmt` since 1:1)
- **Gas Optimization**: Skips transfers when `msg.sender == usr` (shared storage optimization)

#### `buyGem(address usr, uint256 gemAmt)`
- **Purpose**: Buy V1 token with V2 token (V2 → V1)  
- **Parameters**:
  - `usr`: Address of the V1 token recipient
  - `gemAmt`: Amount of V1 token being bought
- **Returns**: Amount of V2 token required (always equals `gemAmt` since 1:1)
- **Gas Optimization**: Skips transfers when `msg.sender == usr` (shared storage optimization)

```solidity
// Example usage
uint256 amountOut = swap.sellGem(recipient, 1e18); // Sell 1 V1 for 1 V2
uint256 amountIn = swap.buyGem(recipient, 1e18);   // Buy 1 V1 with 1 V2
```

**Key Benefits:**
- **Aggregator Integration**: Compatible with solvers expecting LitePSM interface patterns
- **Simplified Implementation**: No decimal conversions needed since V1/V2 share same storage and decimals  
- **Gas Efficient**: Same shared-state optimization as other swap functions
- **Consistent Events**: Emits same `Swapped` events for unified tracking

### Test Coverage

  - 100% test coverage for SwapV1V2 contract
  - Tests for all five swap functions with both V1→V2 and V2→V1 directions:
    - `swapExactIn`, `swapWithPermitStrict`, `swapWithPermitBestEffort`
    - **New**: `sellGem` and `buyGem` LitePSM-compatible functions
  - **Shared State Optimization Tests**: Verifies transfers are skipped when `msg.sender == recipient`
  - **Upgrade functionality tests**: Verifies state preservation and owner-only upgrade authorization
  - Error condition testing (bad pairs, zero amounts, slippage protection)
  - Permit functionality testing (valid signatures, invalid calldata)
  - Initialization validation tests (replaces constructor tests for upgradeable pattern)
  - Event emission verification for all functions
  - Edge cases with different recipient addresses
  - Reentrancy attack protection verification

## How to test

Run the full test suite:

`forge test --match-contract SwapV1V2Test`

Run with coverage:

`forge coverage --match-contract SwapV1V2Test`
 
Key Test Cases:

  - ✅ Basic V1 ↔ V2 swaps in both directions (`swapExactIn`)
  - ✅ Permit-based swaps (strict and best-effort modes)
  - ✅ **LitePSM-compatible functions**: `sellGem` and `buyGem`
  - ✅ **Shared State Optimization**: Same-address transfers skipped for all functions
  - ✅ **Upgrade functionality and owner-only authorization**
  - ✅ **Proxy deployment and initialization**  
  - ✅ Error handling (bad pairs, zero amounts, slippage)
  - ✅ Initialization validation (zero addresses, same addresses)
  - ✅ Event emissions for all swap functions
  - ✅ Different recipient addresses
  - ✅ Permit signature validation and allowance setting
  - ✅ Reentrancy protection

All tests pass (41/41) and achieve 100% line and branch coverage for the SwapV1V2 contract.

### Deployment Instructions

For upgradeable contracts, deployment follows the proxy pattern:

```solidity
// 1. Deploy implementation
SwapV1V2 implementation = new SwapV1V2();

// 2. Deploy proxy with initialization
bytes memory initData = abi.encodeWithSelector(
    SwapV1V2.initialize.selector,
    v1Address,
    v2Address,
    ownerAddress
);
ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);

// 3. Use proxy address for interactions
SwapV1V2 swapContract = SwapV1V2(address(proxy));
```