pragma solidity ^0.4.18;


/**
 * @title PermissionGroups
 * @dev WARN all the logic is loaded in contracts even when they only use a portion of the code.
 * @dev SUGGESTION have the logic split into diferent files under one folder and only request what is needed.
 */
contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) internal operators;
    mapping(address=>bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint constant internal MAX_GROUP_SIZE = 50;

    function PermissionGroups() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {
        require(alerters[msg.sender]);
        _;
    }

    /**
     * @notice Getter for operators.
     * @returns `operatorsGroup` array.
     */
    function getOperators () external view returns(address[]) {
        return operatorsGroup;
    }

    /**
     * @notice Getter for alerters.
     * @returns `alertersGroup` array.
     */
    function getAlerters () external view returns(address[]) {
        return alertersGroup;
    }

    event TransferAdminPending(address pendingAdmin);

    /**
     * @notice Allows the current admin to set the pendingAdmin address.
     * @dev this is part of a two step process and `pendingAdmin` must claim ownership, is more secure but costs more gas.
     * @dev Can only be executed by `admin`.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(pendingAdmin);
        pendingAdmin = newAdmin;
    }

    /**
     * @notice Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @dev This is a faster, cheaper, and less secure version of `transferAdmin` that doesn't require claiming.
     * @dev Can only be executed by `admin`.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(newAdmin);
        AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

    /**
     * @notice Allows the pendingAdmin address to finalize the change admin process.
     * @dev This is the last part of a two step process after `transferAdmin`.
     * @dev Can only be executed by `pendingAdmin`.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender);
        AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event AlerterAdded (address newAlerter, bool isAdd);

    /**
     * @notice Adds an address to the alertersGroup.
     * @dev Can only be executed by `admin`.
     * @param newAlerter Address to be added.
     */
    function addAlerter(address newAlerter) public onlyAdmin {
        require(!alerters[newAlerter]); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE);

        AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    /**
     * @notice Removes an address from the alertersGroup.
     * @dev Can only be executed by `admin`.
     * @param alerter Address to be removed.
     */
    function removeAlerter (address alerter) public onlyAdmin {
        require(alerters[alerter]);
        alerters[alerter] = false;

        for (uint i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.length--;
                AlerterAdded(alerter, false);
                break;
            }
        }
    }

    event OperatorAdded(address newOperator, bool isAdd);

    /**
     * @notice Adds an address to the operatorsGroup.
     * @dev Can only be executed by `admin`.
     * @param newOperator Address to be added.
     */
    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator]); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE);

        OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    /**
     * @notice Removes an address from the operatorsGroup.
     * @dev Can only be executed by `admin`.
     * @param operator Address to be removed.
     */
    function removeOperator (address operator) public onlyAdmin {
        require(operators[operator]);
        operators[operator] = false;

        for (uint i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.length -= 1;
                OperatorAdded(operator, false);
                break;
            }
        }
    }
}
