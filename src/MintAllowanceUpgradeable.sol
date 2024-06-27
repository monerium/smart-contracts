pragma solidity ^0.8.20;

contract MintAllowanceUpgradeable {
    struct Allowance {
        uint256 max;
        mapping(address => uint256) allowances;
    }

    struct AllowanceStorage {
        Allowance _mint;
        Allowance _burn;
    }

    //keccak256("Monerium.MintAllowanceStorage")
    bytes32 private constant AllowanceStorageLocation =
        0x7dfa07e9bc075623c605ec9614e9976bbce827d371ce2ecdb28aa7ae3f76de54;

    function _getAllowanceStorage()
        private
        pure
        returns (AllowanceStorage storage $)
    {
        assembly {
            $.slot := AllowanceStorageLocation
        }
    }

    /**
     * @dev Emitted when allowance is set.
     * @param account The address of the account.
     * @param amount The amount of allowance.
     */
    event BurnAllowance(address indexed account, uint256 amount);

    /**
     * @dev Emitted when max allowance is set.
     * @param amount The amount of allowance.
     */
    event MaxBurnAllowance(uint256 amount);

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

    ///////////// Burn
    function getBurnAllowance(address account) public view returns (uint256) {
        Allowance storage b = _getAllowanceStorage()._burn;
        return b.allowances[account];
    }

    function _setBurnAllowance(address account, uint256 amount) internal {
        Allowance storage b = _getAllowanceStorage()._burn;

        require(
            amount <= b.max,
            "BurnAllowance: cannot set allowance higher than max"
        );

        b.allowances[account] = amount;

        emit BurnAllowance(account, amount);
    }

    function _setBurnAllowance(address account, uint256 amount) internal {
        Allowance storage b = _getAllowanceStorage()._burn;

        require(
            amount <= b.max,
            "BurnAllowance: cannot set allowance higher than max"
        );

        b.allowances[account] = amount;

        emit BurnAllowance(account, amount);
    }

    function getMaxBurnAllowance() public view returns (uint256) {
        Allowance storage b = _getAllowanceStorage()._burn;
        return b.max;
    }

    function _setMaxBurnAllowance(uint256 amount) internal {
        Allowance storage b = _getAllowanceStorage()._burn;

        b.max = amount;

        emit MaxBurnAllowance(amount);
    }

    function _useBurnAllowance(address account, uint256 amount) internal {
        Allowance storage b = _getAllowanceStorage()._burn;

        require(
            b.allowances[account] >= amount,
            "BurnAllowance: not allowed to burn more than allowed"
        );

        b.allowances[account] -= amount;

        emit BurnAllowance(account, b.allowances[account]);
    }
    
    ///////////// Mint
    function getMintAllowance(address account) public view returns (uint256) {
        Allowance storage m = _getAllowanceStorage()._mint;
        return m.allowances[account];
    }

    function _setMintAllowance(address account, uint256 amount) internal {
        Allowance storage m = _getAllowanceStorage()._mint;

        require(
            amount <= m.max,
            "MintAllowance: cannot set allowance higher than max"
        );

        m.allowances[account] = amount;

        emit MintAllowance(account, amount);
    }

    function _useMintAllowance(address account, uint256 amount) internal {
        Allowance storage m = _getAllowanceStorage()._mint;

        require(
            m.allowances[account] >= amount,
            "MintAllowance: not allowed to mint more than allowed"
        );

        m.allowances[account] -= amount;

        emit MintAllowance(account, m.allowances[account]);
    }

    function getMaxMintAllowance() public view returns (uint256) {
        Allowance storage m = _getAllowanceStorage()._mint;
        return m.max;
    }

    function _setMaxMintAllowance(uint256 amount) internal {
        Allowance storage m = _getAllowanceStorage()._mint;

        m.max = amount;

        emit MaxMintAllowance(amount);
    }
}
