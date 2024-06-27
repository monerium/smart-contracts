pragma solidity ^0.8.20;

contract RateLimitsUpgradeable {
    /**
     * @notice Contains the rate limits parameters to mint or burn
     *
     * @param timestamp The timestamp of the last mint/burn
     * @param ratePerSecond The rate per second one can mint/burn
     * @param dailyLimit The max limit per day
     * @param currentLimit The current limit
     * @param maxLimit the maximum someone can set the currentLimit to;
     */
    struct RateLimitParameters {
        uint256 timestamp;
        uint256 ratePerSecond;
        uint256 dailyLimit;
        uint256 currentLimit;
        uint256 maxLimit; // Should we cap this ? it is so that an admin can set a current higher than the daily but only up to a certain amount.
    }

    /**
     * @notice Contains the full minting and burning data for a particular minter/burner
     *
     * @param minterParams The minting parameters
     * @param burnerParams The burning parameters
     */
    struct Limits {
        RateLimitParameters mint;
        RateLimitParameters burn;
    }

    struct RateLimitsStorage {
        mapping(address => Limits) _limits;
    }

    /**
     * @notice The duration it takes for the limits to fully replenish
     */
    uint256 private constant _DURATION = 1 days;

    //keccak256("Monerium.AllowanceStorage")
    bytes32 private constant RateLimitsStorageLocation =
        0xb337526095403ef89c7becef1792605e55dadf16cfa1d0df874fad9581a6937d;

    function _getRateLimitsStorage()
        private
        pure
        returns (RateLimitsStorage storage $)
    {
        assembly {
            $.slot := RateLimitsStorageLocation
        }
    }

    /**
     * @notice set the maxlimit of a minter
     * @param account The address of the minter who is being changed
     * @param newMax The new maxLimit
     */
    function _setMinterMaxLimit(address account, uint256 newMax) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        m.maxLimit = newMax;
    }

    /**
     * @notice set the maxlimit of a burner
     * @param account The address of the burner who is being changed
     * @param newMax The new maxLimit
     */
    function _setBurnerMaxLimit(address account, uint256 newMax) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        b.maxLimit = newMax;
    }

    /**
     * @notice Uses the limit of a minter
     * @param account The address of the minter who is being changed
     * @param change The change in the limit
     */
    function _useMinterLimits(address account, uint256 change) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        uint256 currentLimit = mintingCurrentLimitOf(account);
        m.timestamp = block.timestamp;
        m.currentLimit = currentLimit - change;
    }

    /**
     * @notice Uses the limit of a burner
     * @param account The address of the burner who is being changed
     * @param change The change in the limit
     */
    function _useBurnerLimits(address account, uint256 change) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        uint256 currentLimit = burningCurrentLimitOf(account);
        b.timestamp = block.timestamp;
        b.currentLimit = currentLimit - change;
    }

    /**
     * @notice Resets the minting limit for a given account to a specified value
     * @param account The address of the minter whose limit is to be reset
     * @param limit The new current limit to be set for minting
     */
    function _resetMinterCurrentLimit(
        address account,
        uint256 limit
    ) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        require(limit <= m.maxLimit, "too high");

        m.currentLimit = limit;
        m.timestamp = block.timestamp;
    }

    /**
     * @notice Resets the burning limit for a given account to a specified value
     * @param account The address of the burner whose limit is to be reset
     * @param limit The new current limit to be set for burning
     */
    function _resetBurnerCurrentLimit(
        address account,
        uint256 limit
    ) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        require(limit <= b.maxLimit, "too high");

        b.currentLimit = limit;
        b.timestamp = block.timestamp;
    }

    /**
     * @notice Updates the limit of a minter
     * @param account The address of the minter we are setting the limit too
     * @param limit The updated limit we are setting to the minter
     */
    function _changeMinterLimit(address account, uint256 limit) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        require(limit <= m.maxLimit, "too high");

        uint256 oldLimit = m.dailyLimit;
        uint256 currentLimit = mintingCurrentLimitOf(account);
        m.dailyLimit = limit;

        m.currentLimit = _calculateNewCurrentLimit(
            limit,
            oldLimit,
            currentLimit
        );

        m.ratePerSecond = limit / _DURATION;
        m.timestamp = block.timestamp;
    }

    /**
     * @notice Updates the limit of a burner
     * @param account The address of the minter we are setting the limit too
     * @param limit The updated limit we are setting to the minter
     */
    function _changeBurnerLimit(address account, uint256 limit) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        require(limit <= b.maxLimit, "too high");

        uint256 oldLimit = b.dailyLimit;
        uint256 currentLimit = burningCurrentLimitOf(account);
        b.dailyLimit = limit;

        b.currentLimit = _calculateNewCurrentLimit(
            limit,
            oldLimit,
            currentLimit
        );

        b.ratePerSecond = limit / _DURATION;
        b.timestamp = block.timestamp;
    }

    /**
     * @notice Returns the max limit of a account
     *
     * @param account the account we are viewing the limits of
     * @return limit The limit the account has
     */
    function mintingMaxLimitOf(
        address account
    ) public view returns (uint256 limit) {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;
        limit = m.dailyLimit;
    }

    /**
     * @notice Returns the max limit of a account
     *
     * @param account the account we are viewing the limits of
     * @return limit The limit the account has
     */
    function burningMaxLimitOf(
        address account
    ) public view returns (uint256 limit) {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;
        limit = b.dailyLimit;
    }

    /**
     * @notice Returns the current limit of a account
     *
     * @param account the account we are viewing the limits of
     * @return limit The limit the account has
     */
    function mintingCurrentLimitOf(
        address account
    ) public view returns (uint256 limit) {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;
        limit = _getCurrentLimit(
            m.currentLimit,
            m.dailyLimit,
            m.timestamp,
            m.ratePerSecond
        );
    }

    /**
     * @notice Returns the current limit of a account
     *
     * @param account the account we are viewing the limits of
     * @return limit The limit the account has
     */
    function burningCurrentLimitOf(
        address account
    ) public view returns (uint256 limit) {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;
        limit = _getCurrentLimit(
            b.currentLimit,
            b.dailyLimit,
            b.timestamp,
            b.ratePerSecond
        );
    }

    /**
     * @notice Updates the current limit
     *
     * @param _limit The new limit
     * @param _oldLimit The old limit
     * @param _currentLimit The current limit
     * @return _newCurrentLimit The new current limit
     */
    function _calculateNewCurrentLimit(
        uint256 _limit,
        uint256 _oldLimit,
        uint256 _currentLimit
    ) internal pure returns (uint256 _newCurrentLimit) {
        uint256 _difference;

        if (_oldLimit > _limit) {
            _difference = _oldLimit - _limit;
            _newCurrentLimit = _currentLimit > _difference
                ? _currentLimit - _difference
                : 0;
        } else {
            _difference = _limit - _oldLimit;
            _newCurrentLimit = _currentLimit + _difference;
        }
    }

    /**
     * @notice Gets the current limit
     *
     * @param _currentLimit The current limit
     * @param _dailyLimit The max limit
     * @param _timestamp The timestamp of the last update
     * @param _ratePerSecond The rate per second
     * @return _limit The current limit
     */
    function _getCurrentLimit(
        uint256 _currentLimit,
        uint256 _dailyLimit,
        uint256 _timestamp,
        uint256 _ratePerSecond
    ) internal view returns (uint256 _limit) {
        _limit = _currentLimit;
        if (_limit >= _dailyLimit) {
            return _limit;
        } else if (_timestamp + _DURATION <= block.timestamp) {
            _limit = _dailyLimit;
        } else if (_timestamp + _DURATION > block.timestamp) {
            uint256 _timePassed = block.timestamp - _timestamp;
            uint256 _calculatedLimit = _limit + (_timePassed * _ratePerSecond);
            _limit = _calculatedLimit > _dailyLimit
                ? _dailyLimit
                : _calculatedLimit;
        }
    }

}
