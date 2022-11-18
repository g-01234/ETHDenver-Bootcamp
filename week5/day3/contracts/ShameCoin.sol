import "solmate/src/tokens/ERC20.sol";

/// @title ShameCoin
/// @author carlOS
/// @notice This is a simple weird ERC20 token
/// @dev Don't actually use this

contract ShameCoin is ERC20 {
    /// @notice The administrator
    address public admin;

    /// @notice Constructor that sets decimals to 0 and admin to msg.sender
    constructor() ERC20("ShameCoin", "SHAME", 0) {
        admin = msg.sender;
    }

    /// @notice Allows the admin to transfer one token at a time
    /// @notice If other users attempt to transfer, their balance will just be incremented
    /// @dev breaks totalSupply
    /// @param to The address to transfer to
    /// @param amount The amount to transfer
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        if (msg.sender == admin) {
            require(amount == 1, "One at a time, please");
            balanceOf[to] += 1;
        } else {
            balanceOf[msg.sender] += 1;
        }
        return true;
    }

    /// @notice Allows non-admins to approve the admin to spend ONE token
    /// @notice Attempts to approve other addresses / other amounts will fail
    /// @param spender The address to approve
    /// @param amount The amount to approve
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        require(spender == admin, "Can only approve the admin");
        require(amount == 1, "One at a time, please");
        allowance[msg.sender][spender] = 1;
        emit Approval(msg.sender, spender, 1);
        return true;
    }

    /// @notice Just decrements the caller's balance by one
    /// @dev breaks totalSupply
    /// @param from The address to transfer from
    /// @param to The address to transfer to
    /// @param amount The amount to transfer
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        balanceOf[msg.sender] -= 1;
        return true;
    }
}
