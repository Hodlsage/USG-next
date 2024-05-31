// ----------------------------------------------------------------------------
// --- Name        : USGv1 Depository 
// --- Symbol      : Format - {---}
// --- Total supply: Generated from minter accounts
// --- @Legal      : 
// --- @title for 01101101 01111001 01101101 01100101
// --- BlockHaus.Company - EJS32 - 2018-2023
// --- @dev pragma solidity version:0.8.19+commit.7dd64d404
// --- SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

pragma solidity ^0.8.19;

// ----------------------------------------------------------------------------
// --- Interface IERC20
// ----------------------------------------------------------------------------

interface IERC20 {
  // --- Returns the total supply of tokens
  function totalSupply() external view returns (uint256);

  // --- Returns the number of decimal places the token has
  function decimals() external view returns (uint8);

  // --- Returns the symbol of the token (e.g., CRNT)
  function symbol() external view returns (string memory);

  // --- Returns the name of the token (e.g., Current)
  function name() external view returns (string memory);

  // --- Returns the owner of the contract
  function getOwner() external view returns (address);

  // --- Returns the balance of a specific account
  function balanceOf(address account) external view returns (uint256);

  // --- Transfers tokens from the sender to the recipient
  function transfer(address recipient, uint256 amount) external returns (bool);

  // --- Returns the allowance for a spender on the owner's tokens
  function allowance(address _owner, address spender) external view returns (uint256);

  // --- Approves a spender to spend a specific amount of tokens
  function approve(address spender, uint256 amount) external returns (bool);

  // --- Transfers tokens from a sender to a recipient on behalf of the owner
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  // --- Event emitted when tokens are transferred
  event Transfer(address indexed from, address indexed to, uint256 value);

  // --- Event emitted when approval for spending tokens is granted
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ----------------------------------------------------------------------------
// --- Library Address
// ----------------------------------------------------------------------------

library Address {
   
    error AddressInsufficientBalance(address account);
 
    error AddressEmptyCode(address target);
 
    error FailedInnerCall();

    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    function _revert(bytes memory returndata) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// ----------------------------------------------------------------------------
// --- Interface IERC20Permit
// ----------------------------------------------------------------------------

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// ----------------------------------------------------------------------------
// --- Library SafeERC20
// ----------------------------------------------------------------------------

library SafeERC20 {
    using Address for address;

    error SafeERC20FailedOperation(address token);

    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// ----------------------------------------------------------------------------
// --- Abstract Contract Context 
// ----------------------------------------------------------------------------

abstract contract Context {
  // --- Returns the sender's address, which is the address of the account that initiated the current transaction.
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  // --- Returns the transaction data as a bytes array, which includes the function call data and additional information about the transaction.
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

// ----------------------------------------------------------------------------
// --- Abstract Contract Ownable 
// ----------------------------------------------------------------------------

abstract contract Ownable is Context {
  // --- The address of the current owner of the contract
  address private _owner;

  // --- Custom error for unauthorized account access
  error OwnableUnauthorizedAccount(address account);

  // --- Custom error for an invalid owner address
  error OwnableInvalidOwner(address owner);

  // --- Event emitted when ownership is transferred
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // --- Constructor that sets the initial owner of the contract
  constructor(address initialOwner) {
    // --- Ensure the initial owner address is not 0x0 (invalid)
    if (initialOwner == address(0)) {
      revert OwnableInvalidOwner(address(0));
    }
    // --- Transfer ownership to the initial owner
    _transferOwnership(initialOwner);
  }

  // --- Modifier to restrict access to functions only to the owner
  modifier onlyOwner() {
    _checkOwner();
    _;
  }

  // --- Returns the address of the current owner
  function owner() public view virtual returns (address) {
    return _owner;
  }

  // --- Internal function to check if the sender is the owner
  function _checkOwner() internal view virtual {
    if (owner() != _msgSender()) {
      revert OwnableUnauthorizedAccount(_msgSender());
    }
  }

  // --- Allows the current owner to renounce ownership
  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  // --- Allows the current owner to transfer ownership to a new address
  function transferOwnership(address newOwner) public virtual onlyOwner {
    // --- Ensure the new owner address is not 0x0 (invalid)
    if (newOwner == address(0)) {
      revert OwnableInvalidOwner(address(0));
    }
    // --- Transfer ownership to the new owner
    _transferOwnership(newOwner);
  }

  // --- Internal function to perform the ownership transfer
  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    // --- Emit an event to indicate the ownership transfer
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}


// ----------------------------------------------------------------------------
// --- Contract USGv1Depository
// ----------------------------------------------------------------------------

contract USGv1Depository is Context, Ownable {
    event EtherReleased(uint256 amount);
    event ERC20Released(address indexed token, uint256 amount);

    uint256 private _released;
    mapping(address token => uint256) private _erc20Released;
    uint64 private immutable _start;
    uint64 private immutable _duration;

    constructor(address beneficiary, uint64 startTimestamp, uint64 durationSeconds) payable Ownable(beneficiary) {
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    receive() external payable virtual {}

    function start() public view virtual returns (uint256) {
        return _start;
    }

    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    function end() public view virtual returns (uint256) {
        return start() + duration();
    }

    function released() public view virtual returns (uint256) {
        return _released;
    }

    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }

    function releasable() public view virtual returns (uint256) {
        return depositedAmount(uint64(block.timestamp)) - released();
    }

    function releasable(address token) public view virtual returns (uint256) {
        return depositedAmount(token, uint64(block.timestamp)) - released(token);
    }

    function release() public virtual {
        uint256 amount = releasable();
        _released += amount;
        emit EtherReleased(amount);
        Address.sendValue(payable(owner()), amount);
    }

    function release(address token) public virtual {
        uint256 amount = releasable(token);
        _erc20Released[token] += amount;
        emit ERC20Released(token, amount);
        SafeERC20.safeTransfer(IERC20(token), owner(), amount);
    }

    function depositedAmount(uint64 timestamp) public view virtual returns (uint256) {
        return _releaseSchedule(address(this).balance + released(), timestamp);
    }

    function depositedAmount(address token, uint64 timestamp) public view virtual returns (uint256) {
        return _releaseSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);
    }

    function _releaseSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp >= end()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}