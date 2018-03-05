pragma solidity ^0.4.18;


contract WhiteListInterface {
    /// @notice Checks in which category a user is registered and returns the cap for that user.
    /// @dev Implemented in `WhiteList.sol`.
    /// @param user Address to be queried.
    /// @returns userCapWei Cap for `user`.
    function getUserCapInWei(address user) external view returns (uint userCapWei);
}
