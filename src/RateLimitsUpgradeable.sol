pragma solidity ^0.8.20;

contract RateLimitsUpgradeable {
    /**
     * @notice Contains the rate limits parameters to mint or burn
     *
     * @param timestamp The timestamp of the last mint/burn
     * @param ratePerSecond The rate per second one can mint/burn
     * @param maxLimit The max limit
     * @param currentLimit The current limit
     */
    struct RateLimitParameters {
        uint256 timestamp;
        uint256 ratePerSecond;
        uint256 maxLimit;
        uint256 currentLimit;
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
     * @notice Updates the limit of a minter
     * @param account The address of the minter we are setting the limit too
     * @param limit The updated limit we are setting to the minter
     */
    function _changeMinterLimit(address account, uint256 limit) internal {
        RateLimitParameters storage m = _getRateLimitsStorage()
            ._limits[account]
            .mint;

        uint256 oldLimit = m.maxLimit;
        uint256 currentLimit = mintingCurrentLimitOf(account);
        m.maxLimit = limit;

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

        uint256 oldLimit = b.maxLimit;
        uint256 currentLimit = burningCurrentLimitOf(account);
        b.maxLimit = limit;

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
    ) public view returns (uint256 limit) {
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
    ) public view returns (uint256 limit) {
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
    ) public view returns (uint256 limit) {
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
     * @param _maxLimit The max limit
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
        if (_limit == _maxLimit) {
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
