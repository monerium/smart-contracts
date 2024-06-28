pragma solidity ^0.8.20;

contract RateLimitsUpgradeable {
    /**
     * @notice Contains the rate limits parameters to mint or burn
     *
     * @param timestamp The timestamp of the last mint/burn
     * @param ratePerSecond The rate per second one can mint/burn
     * @param maxLimit The max limit per day
     * @param currentLimit The current limit
     * @param limitCap the maximum someone can set the currentLimit to;
     */
    struct RateLimitParameters {
        uint256 timestamp;
        uint256 ratePerSecond;
        uint256 maxLimit;
        uint256 currentLimit;
        uint256 limitCap; // Should we cap this ? it is so that an admin can set a current higher than the daily but only up to a certain amount.
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
     * @notice Reverts when a user with too low of a limit tries to call mint/burn
     */
    error RateLimit_NotHighEnoughLimits();

    /**
     * @notice Reverts when limits are too high
     */
    error RateLimit_LimitsTooHigh();

    /**
     * @notice The duration it takes for the limits to fully replenish
     */
    uint256 private constant _DURATION = 1 days;

    //keccak256("Monerium.RateLimitsStorage")
    bytes32 private constant RateLimitsStorageLocation =
        0xf5c2d6c10bf6af1d4a746f3bd839f32e5b4f31378a525476ce58cee3c1c1f7a7;

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
     * @param newMax The new limitCap
     */
    function _setMinterMaxLimit(address account, uint256 newMax) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        m.limitCap = newMax;
    }

    /**
     * @notice set the maxlimit of a burner
     * @param account The address of the burner who is being changed
     * @param newMax The new limitCap
     */
    function _setBurnerMaxLimit(address account, uint256 newMax) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        b.limitCap = newMax;
    }

    /**
     * @notice Uses the limit of a minter
     * @param account The address of the minter who is being changed
     * @param amount The amount of the limit to be used
     */
    function _useMinterLimits(address account, uint256 amount) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        uint256 currentLimit = mintingCurrentLimitOf(account);
        if (currentLimit < amount) revert RateLimit_NotHighEnoughLimits();
        m.timestamp = block.timestamp;
        m.currentLimit = currentLimit - amount;
    }

    /**
     * @notice Uses the limit of a burner
     * @param account The address of the burner who is being changed
     * @param amount The amount of the limit to be used
     */
    function _useBurnerLimits(address account, uint256 amount) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        uint256 currentLimit = burningCurrentLimitOf(account);
        if (currentLimit < amount) revert RateLimit_NotHighEnoughLimits();
        b.timestamp = block.timestamp;
        b.currentLimit = currentLimit - amount;
    }

    /**
     * @notice Resets the minting limit for a given account to a specified value
     * @param account The address of the minter whose limit is to be reset
     * @param limit The new current limit to be set for minting
     */
    function _resetMinterCurrentLimit(address account, uint256 limit) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        if (limit > m.limitCap) revert RateLimit_LimitsTooHigh();

        m.currentLimit = limit;
        m.timestamp = block.timestamp;
    }

    /**
     * @notice Resets the burning limit for a given account to a specified value
     * @param account The address of the burner whose limit is to be reset
     * @param limit The new current limit to be set for burning
     */
    function _resetBurnerCurrentLimit(address account, uint256 limit) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        if (limit > b.limitCap) revert RateLimit_LimitsTooHigh();

        b.currentLimit = limit;
        b.timestamp = block.timestamp;
    }

    /**
     * @notice Updates the daily limit of a minter
     * @param account The address of the minter we are setting the limit too
     * @param newDailyLimit The updated limit we are setting to the minter
     */
    function _changeMinterLimit(address account, uint256 newDailyLimit) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        if (newDailyLimit > m.limitCap) revert RateLimit_LimitsTooHigh();

        uint256 oldLimit = m.maxLimit;
        uint256 currentLimit = mintingCurrentLimitOf(account);
        m.maxLimit = newDailyLimit;

        m.currentLimit = _calculateNewCurrentLimit(
            newDailyLimit,
            oldLimit,
            currentLimit
        );

        m.ratePerSecond = newDailyLimit / _DURATION;
        m.timestamp = block.timestamp;
    }

    /**
     * @notice Updates the limit of a burner
     * @param account The address of the minter we are setting the limit too
     * @param newDailyLimit The updated daily limit we are setting to the minter
     */
    function _changeBurnerLimit(
        address account,
        uint256 newDailyLimit
    ) internal {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;

        if (newDailyLimit > b.limitCap) revert RateLimit_LimitsTooHigh();

        uint256 oldLimit = b.maxLimit;
        uint256 currentLimit = burningCurrentLimitOf(account);
        b.maxLimit = newDailyLimit;

        b.currentLimit = _calculateNewCurrentLimit(
            newDailyLimit,
            oldLimit,
            currentLimit
        );

        b.ratePerSecond = newDailyLimit / _DURATION;
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
    ) public view virtual returns (uint256 limit) {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;
        limit = m.maxLimit;
    }

    /**
     * @notice Returns the max limit of a account
     *
     * @param account the account we are viewing the limits of
     * @return limit The limit the account has
     */
    function burningMaxLimitOf(
        address account
    ) public view virtual returns (uint256 limit) {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;
        limit = b.maxLimit;
    }

    /**
     * @notice Returns the current limit of a account
     *
     * @param account the account we are viewing the limits of
     * @return limit The limit the account has
     */
    function mintingCurrentLimitOf(
        address account
    ) public view virtual returns (uint256 limit) {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;
        limit = _getCurrentLimit(
            m.currentLimit,
            m.maxLimit,
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
    ) public view virtual returns (uint256 limit) {
        RateLimitParameters storage b = _getRateLimitsStorage()
            ._limits[account]
            .burn;
        limit = _getCurrentLimit(
            b.currentLimit,
            b.maxLimit,
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
     * @param _maxLimit The max limit per day
     * @param _timestamp The timestamp of the last update
     * @param _ratePerSecond The rate per second
     * @return _limit The current limit
     */
    function _getCurrentLimit(
        uint256 _currentLimit,
        uint256 _maxLimit,
        uint256 _timestamp,
        uint256 _ratePerSecond
    ) internal view returns (uint256 _limit) {
        _limit = _currentLimit;
        if (_limit >= _maxLimit) {
            return _limit;
        } else if (_timestamp + _DURATION <= block.timestamp) {
            _limit = _maxLimit;
        } else if (_timestamp + _DURATION > block.timestamp) {
            uint256 _timePassed = block.timestamp - _timestamp;
            uint256 _calculatedLimit = _limit + (_timePassed * _ratePerSecond);
            _limit = _calculatedLimit > _maxLimit
                ? _maxLimit
                : _calculatedLimit;
        }
    }

}
