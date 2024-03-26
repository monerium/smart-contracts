pragma solidity ^0.8.20;

contract MintAllowanceUpgradeable {
    struct MintAllowanceStorage {
        mapping(address => uint256) _mintAllowance;
        uint256 _maxMintAllowance;
    }

    //keccak256("Monerium.MintAllowanceStorage")
    bytes32 private constant MintAllowanceStorageLocation =
        0xb337526095403ef89c7becef1792605e55dadf16cfa1d0df874fad9581a6937d;

    function _getMintAllowanceStorage()
        private
        pure
        returns (MintAllowanceStorage storage $)
    {
        assembly {
            $.slot := MintAllowanceStorageLocation
        }
    }

    /**
     * @dev Emitted when allowance is set.
     * @param account The address of the account.
     * @param amount The amount of allowance.
     */
    event MintAllowance(address indexed account, uint256 amount);

    /**
     * @dev Emitted when max allowance is set.
     * @param amount The amount of allowance.
     */
    event MaxMintAllowance(uint256 amount);

    modifier onlyAllowedMinter(address account, uint256 amount) {
        MintAllowanceStorage storage s = _getMintAllowanceStorage();
        require(
            s._mintAllowance[account] >= amount,
            "MintAllowance: not allowed to mint more than allowed"
        );
        _;
    }

    function getMintAllowance(address account) public view returns (uint256) {
        MintAllowanceStorage storage s = _getMintAllowanceStorage();
        return s._mintAllowance[account];
    }

    function _setMintAllowance(address account, uint256 amount) internal {
        MintAllowanceStorage storage s = _getMintAllowanceStorage();

        require(
            amount <= s._maxMintAllowance,
            "MintAllowance: cannot set allowance higher than max"
        );

        s._mintAllowance[account] = amount;

        emit MintAllowance(account, amount);
    }

    function _useMintAllowance(address account, uint256 amount) internal {
        MintAllowanceStorage storage s = _getMintAllowanceStorage();

        require(
            s._mintAllowance[account] >= amount,
            "MintAllowance: not allowed to mint more than allowed"
        );

        s._mintAllowance[account] -= amount;

        emit MintAllowance(account, s._mintAllowance[account]);
    }

    function getMaxMintAllowance() public view returns (uint256) {
        MintAllowanceStorage storage s = _getMintAllowanceStorage();
        return s._maxMintAllowance;
    }

    function _setMaxMintAllowance(uint256 amount) internal {
        MintAllowanceStorage storage s = _getMintAllowanceStorage();

        s._maxMintAllowance = amount;

        emit MaxMintAllowance(amount);
    }
}
