// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./RLPDecoder.sol";

contract Helper {

    function decode(bytes calldata input) public pure returns (bytes[] memory) {
        return RLPDecoder.decode(input);
    }
}
