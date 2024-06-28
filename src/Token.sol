// SPDX-License-Identifier: APACHE-2.0
pragma solidity ^0.8.20;

// We are utilizing the 'openzeppelin/contracts-upgradeable' library instead of 'openzeppelin/contracts'.
// The reason for this is that the Upgradeable contracts use an 'initialize' function as a substitute for the constructor.
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./MintAllowanceUpgradeable.sol";
import "./RateLimitsUpgradeable.sol";
import "./SystemRoleUpgradeable.sol";
import "./IValidator.sol";
import "./interfaces/IXERC20.sol";

/**
 * @dev Token contract with upgradeable patterns, mint allowance, and system roles.
 */
contract Token is
    Initializable,
    ERC20PermitUpgradeable,
    UUPSUpgradeable,
    MintAllowanceUpgradeable,
    RateLimitsUpgradeable,
    SystemRoleUpgradeable,
    IXERC20
{
    // Subsequent contract versions must retain this variable to avoid storage conflicts with the proxy.
    IValidator public validator;
    using SignatureChecker for address;

    /**
     * @dev Emitted when the contract owner recovers tokens.
     * @param from Sender address.
     * @param to Recipient address.
     * @param amount Number of tokens.
     */
    event Recovered(address indexed from, address indexed to, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
        // This line is necessary for the upgradable pattern. It disables the initializers of the parent contracts to prevent them from being called twice.
    }

    function initialize(
        string memory name,
        string memory symbol,
        address _validator
    ) public virtual initializer { // Those line replaces the inheritance call in the constructor, as we are using the upgradeable pattern.
        // In the upgradeable pattern, the 'initialize' function replaces the constructor. It's not called automatically.
        // The proxy contract calls this function using delegatecall.
        // This results in storing all new variables from ERC20, Ownable, etc., in the proxy's storage.
        __ERC20_init(name, symbol);
        __ERC20Permit_init(name);
        __UUPSUpgradeable_init();
        __SystemRole_init();
        validator = IValidator(_validator);
        require(
            validator.CONTRACT_ID() == keccak256("monerium.validator"),
            "Not Monerium Validator Contract"
        );
    }

    // _authorizeUpgrade is a crucial part of the UUPS upgrade pattern in OpenZeppelin.
    // By defining this function, we can control the upgrade process and prevent unauthorized changes.
    // This function can be customized to include additional checks or logic, such as a timelock or a multisig requirement.
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function mint(address to, uint256 amount) public onlySystemAccounts {
        _useMintAllowance(_msgSender(), amount);
        _useMinterLimits(_msgSender(), amount);
        _mint(to, amount);
    }

    function burn(
        address from,
        uint256 amount,
        bytes32,
        bytes memory signature
    ) public onlySystemAccounts {
        require(
            from.isValidSignatureNow(
                0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f,
                signature
            ),
            "signature/hash does not match"
        );
        _burn(from, amount);
    }

    function recover(
        address from,
        address to,
        bytes32,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external onlySystemAccounts returns (uint256) {
        bytes memory signature;
        if (r != bytes32(0) || s != bytes32(0)) {
            signature = abi.encodePacked(r, s, v);
        }
        require(
            from.isValidSignatureNow(
                0xb77c35c892a1b24b10a2ce49b424e578472333ee8d2456234fff90626332c50f,
                signature
            ),
            "signature/hash does not match"
        );
        uint256 amount = balanceOf(from);
        _burn(from, amount);
        _mint(to, amount);
        emit Recovered(from, to, amount);
        return amount;
    }

    // Function to set the validator, restricted to owner
    function setValidator(address _validator) public onlyOwner {
        validator = IValidator(_validator);
        require(
            validator.CONTRACT_ID() == keccak256("monerium.validator"),
            "Not Monerium Validator Contract"
        );
    }

    // Override transfer function to invoke validator
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(
            validator.validate(_msgSender(), to, amount),
            "Transfer not validated"
        );
        return super.transfer(to, amount);
    }

    // Override transferFrom function to invoke validator
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(validator.validate(from, to, amount), "Transfer not validated");
        return super.transferFrom(from, to, amount);
    }

    // setMaxMintAllowance is only callable by the owner
    function setMaxMintAllowance(uint256 amount) public onlyOwner {
        _setMaxMintAllowance(amount);
    }

    // setMintAllowance is only callable by the admins
    function setMintAllowance(
        address account,
        uint256 amount
    ) public onlyAdminAccounts {
        _setMintAllowance(account, amount);
    }

    /**
     * @notice Returns the max limit of a minter
     *
     * @param minter The minter we are viewing the limits of
     *  @return limit The limit the minter has daily
     */
    function mintingMaxLimitOf(
        address minter
    )
        public
        view
        override(IXERC20, RateLimitsUpgradeable)
        returns (uint256 limit)
    {
        limit = super.mintingMaxLimitOf(minter);
    }

    /**
     * @notice Returns the daily limit of a burner
     *
     * @param burner the bridge we are viewing the limits of
     * @return limit The limit the burner has daily
     */
    function burningMaxLimitOf(
        address burner
    )
        public
        view
        override(IXERC20, RateLimitsUpgradeable)
        returns (uint256 limit)
    {
        limit = super.burningMaxLimitOf(burner);
    }

    /**
     * @notice Returns the current limit of a minter
     *
     * @param minter The minter we are viewing the limits of
     * @return limit The limit the minter has
     */
    function mintingCurrentLimitOf(
        address minter
    )
        public
        view
        override(IXERC20, RateLimitsUpgradeable)
        returns (uint256 limit)
    {
        limit = super.mintingCurrentLimitOf(minter);
    }

    /**
     * @notice Returns the current limit of a burner
     *
     * @param burner the burner we are viewing the limits of
     * @return limit The limit the bridge has
     */
    function burningCurrentLimitOf(
        address burner
    )
        public
        view
        override(IXERC20, RateLimitsUpgradeable)
        returns (uint256 limit)
    {
        limit = super.burningCurrentLimitOf(burner);
    }

    // EIP-2612 helper
    function getPermitDigest(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    _domainSeparatorV4(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            nonce,
                            deadline
                        )
                    )
                )
            );
    }


    function addMinterAndBurner(address account, uint256 limitCap) external onlyOwner {
      addSystemAccount(account);
      _setMinterMaxLimit(account, limitCap);
      _setBurnerMaxLimit(account, limitCap);
    }

    // IXERC20
    function setLockbox(address) external pure {
        revert("Not Implemented");
    }

    /**
     * @notice Updates the limits of any bridge
     * @dev Can only be called by the owner
     * @param mintingLimit The updated minting limit we are setting to the bridge
     * @param burningLimit The updated burning limit we are setting to the bridge
     * @param bridge The address of the bridge we are setting the limits too
     */
    function setLimits(
        address bridge,
        uint256 mintingLimit,
        uint256 burningLimit
    ) external onlyAdminAccounts {
        _changeMinterLimit(bridge, mintingLimit);
        _changeBurnerLimit(bridge, burningLimit);
    }

    /**
     * @notice Burns tokens for a user
     * @dev Can only be called by a minter
     * @param user The address of the user who needs tokens burned
     * @param amount The amount of tokens being burned
     */
    function burn(address user, uint256 amount) external onlySystemAccounts {
      if (_msgSender() !=  user){
        _spendAllowance(user, _msgSender(), amount);
      }

      _useBurnerLimits(_msgSender(), amount);
      _burn(user, amount);
    }

}

