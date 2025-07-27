// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * @title KNToken Contract
 * @author Luke
 * @notice A custom ERC20 token with transfer restrictions, minting, and burning capabilities.
 * @dev By default, token transfers are disabled except between whitelisted addresses.
 *      The owner can enable global transfers or manage the whitelist.
 */

contract KNSToken {
    /// @notice Mapping of addresses allowed to send/receive when transfers are globally disabled
    mapping(address => bool) public transferWhitelist;

    /// @notice Global transfer toggle. When false, only whitelist-to-whitelist or whitelist-to-any transfers are allowed.
    bool public isTransferUnrestricted = false;

    /// @notice Once set to true, minting is permanently disabled
    bool public mintEnabled = true;

    /// @notice Emitted when the global transfer setting is changed
    event TransferUnrestrictedUpdated(bool enabled);

    /// @notice Emitted when an address is added to or removed from the whitelist
    event TransferWhitelistUpdated(address indexed user, bool isWhitelisted);

    /// @notice Emitted when deadMint is enabled
    event DisabledMint();

    error MintAlreadyDisabled();

    /**
     * @notice Contract constructor that sets the token name, symbol, and initial owner
     * @param initialOwner The address that will be granted ownership of the token contract
     */
    constructor(address initialOwner, string memory _name, string memory _symbol) {}

    /**
     * @notice Modifier that restricts transfers when `isTransferUnrestricted` is false
     * @dev Allows transfers if either `from` or `to` is whitelisted.
     *      Blocks transfers between two non-whitelisted addresses when transfers are disabled.
     * @param from Sender address
     * @param to Receiver address
     */
    modifier canTransfer(address from, address to) {
        if (!isTransferUnrestricted) {
            bool fromWhitelisted = transferWhitelist[from];
            bool toWhitelisted = transferWhitelist[to];
            require(
                fromWhitelisted || toWhitelisted, "Transfers disabled: non-whitelisted can only send to whitelisted"
            );
        }
        _;
    }
}
