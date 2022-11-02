pragma solidity ^0.8.0;

interface IPOAP {
    function tokenDetailsOfOwnerByIndex(address winner, uint index)
        external
        view
        returns (uint, uint);

    function balanceOf(address _user) external view returns (uint);
}
