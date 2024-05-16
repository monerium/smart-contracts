// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./IValidator.sol";

/**
 * @title BlacklistValidator
 * @dev Rejects transfers from blacklisted addresses.
 */
contract BlacklistValidatorUpgradeable is
    Initializable,
    Ownable2StepUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IValidator
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    // keccak256("monerium.validator")
    bytes32 private constant ID = 0x5341d189213c4172d0c7256f80bc5f8e6350af3aaff7a029625d8dd94f0f82a5;

    struct BlacklistValidatorStorage {
        mapping(address => bool) blacklist;
    }

    // keccak256("Monerium.BlacklistValidatorStorage")
    bytes32 private constant BlacklistValidatorStorageLocation =
        0x187fd434edb52abef1e387c6baed33eabbe6de77c176d95834d5ab434a07fc18;

    function _getBlacklistValidatorStorage()
        private
        pure
        returns (BlacklistValidatorStorage storage $)
    {
        assembly {
            $.slot := BlacklistValidatorStorageLocation

        }
    }

    error Unauthorized();

    /**
     * @dev Emitted when an address is added to the blacklist.
     * @param adversary Address added.
     */
    event Ban(address indexed adversary);

    /**
     * @dev Emitted when an address is removed from the blacklist.
     * @param friend Address removed.
     */
    event Unban(address indexed friend);

    /**
     * @dev Emitted when admin account is added.
     * @param account The address of the account.
     */
    event AdminAccountAdded(address indexed account);

    /**
     * @dev Emitted when admin account is removed.
     * @param account The address of the account.
     */
    event AdminAccountRemoved(address indexed account);

    /**
     * @dev Initializes the contract.
     */
    function initialize() public initializer {
        __Ownable2Step_init();
        __Ownable_init(_msgSender());
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // _authorizeUpgrade is a crucial part of the UUPS upgrade pattern in OpenZeppelin.
    // By defining this function, we can control the upgrade process and prevent unauthorized changes.
    // This function can be customized to include additional checks or logic, such as a timelock or a multisig requirement.
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // CONTRACT_ID returns the contract identifier.
    function CONTRACT_ID() public pure returns (bytes32) {
        return ID;
    }

    /**
     * @dev Adds an address to the blacklist.
     * @param adversary Address to add.
     */
    function ban(address adversary) external onlyAdminAccounts {
        BlacklistValidatorStorage storage $ = _getBlacklistValidatorStorage();
        
        $.blacklist[adversary] = true;
        emit Ban(adversary);
    }

    /**
     * @dev Removes an address from the blacklist.
     * @param friend Address to remove.
     */
    function unban(address friend) external onlyAdminAccounts {
        BlacklistValidatorStorage storage $ = _getBlacklistValidatorStorage();
        $.blacklist[friend] = false;
        emit Unban(friend);
    }

    /**
     * @dev Checks if an address is in the blacklist.
     * @param account Address to check.
     * @return true if the address is in the blacklist.
     */
    function isBan(address account) external view returns (bool) {
        BlacklistValidatorStorage storage $ = _getBlacklistValidatorStorage();
        return $.blacklist[account];
    }

    /**
     * @dev Validates token transfer.
     * Implements IValidator interface.
     */
    function validate(
        address from,
        address to,
        uint256 amount
    ) external returns (bool valid) {
        BlacklistValidatorStorage storage $ = _getBlacklistValidatorStorage();
        valid = !($.blacklist[from]);
        emit Decision(from, to, amount, valid);
    }

    /**
     * @dev modifier to restrict access to admin accounts.
     */
    modifier onlyAdminAccounts() {
        if (!isAdminAccount(_msgSender())) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @dev Checks wether an address is a admin account.
     * @param account The address of the account.
     * @return true if admin account.
     */
    function isAdminAccount(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    /**
     * @dev add admin account.
     * @param account The address of the account.
     */
    function addAdminAccount(address account) public virtual  {
        grantRole(ADMIN_ROLE, account);
        emit AdminAccountAdded(account);
    }

    /**
     * @dev remove admin account.
     * @param account The address of the account.
     */
    function removeAdminAccount(address account) public virtual onlyOwner {
        revokeRole(ADMIN_ROLE, account);
        emit AdminAccountRemoved(account);
    }

}

