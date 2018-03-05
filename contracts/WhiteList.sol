pragma solidity ^0.4.18;


import "./Withdrawable.sol";
import "./WhiteListInterface.sol";


contract WhiteList is WhiteListInterface, Withdrawable {

    uint public weiPerSgd; // amount of weis in 1 singapore dollar
    mapping (address=>uint) public userCategory; // each user has a category defining cap on trade. 0 for standard.
    mapping (uint=>uint)    public categoryCap;  // will define cap on trade amount per category in singapore Dollar.

    /// @notice WhiteList constructor
    /// @param _admin Admin can execute `withdrawToken` and `withdrawEther` on `Withdrawwable.sol`.
    function WhiteList(address _admin) public {
        require(_admin != address(0));
        admin = _admin;
    }

    /// @notice Checks in which category a user is registered and returns the cap for that category according to the `weiPerSgd` rate.
    /// @param user Address to be queried.
    /// @returns userCapWei Cap for `user` based on the category and current `weiPerSgd` rate.
    function getUserCapInWei(address user) external view returns (uint userCapWei) {
        uint category = userCategory[user];
        return (categoryCap[category] * weiPerSgd);
    }

    event UserCategorySet(address user, uint category);

    /// @notice Assigns a user to category.
    /// @param user Address to be assigned.
    /// @param category Category of investment that the user will be assigned to.
    function setUserCategory(address user, uint category) public onlyOperator {
        userCategory[user] = category;
        UserCategorySet(user, category);
    }

    event CategoryCapSet (uint category, uint sgdCap);

    /// @notice Assigns a cap to category.
    /// @param category Category ID.
    /// @param sgdCap Cap in SGD to assign to category.
    function setCategoryCap(uint category, uint sgdCap) public onlyOperator {
        categoryCap[category] = sgdCap;
        CategoryCapSet(category, sgdCap);
    }

    event SgdToWeiRateSet (uint rate);

    /// @notice Setter for weiPerSgd
    /// @dev WARN: 0 is a valid input.
    /// @param _sgdToWeiRate The new rate.
    function setSgdToEthRate(uint _sgdToWeiRate) public onlyOperator {
        weiPerSgd = _sgdToWeiRate;
        SgdToWeiRateSet(_sgdToWeiRate);
    }
}
