// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library RLPDecoder {

  struct RLPItem {
      bytes data;
      uint length;
  }

  uint constant LIST_LENGTH = 20;

  //Nested Lists are not supported. 
  function decodeList(bytes calldata input) internal pure returns (bytes[] memory) {

    bytes1 firstByte = input[0];
    bytes calldata innerRemainder;
    uint length = 0;
    if (firstByte <= hex"f7") {
      length = uint8(firstByte) - uint8(bytes1(hex"bf"));
      innerRemainder = input[1: length];
    } else {
      // a list  over 55 bytes long
      uint llength = uint8(firstByte) - uint8(bytes1(hex"f6"));
      length = toUintX(input[1:llength], 0);
      uint totalLength = llength + length;
      innerRemainder = input[llength: totalLength];
      require(innerRemainder.length != 0);

    }
    uint listLength = 0;
    bytes[] memory decoded;
    uint index = 0;
    RLPItem memory result;
    while (innerRemainder.length > 0) {
      if(index == decoded.length) {
        bytes[] memory tmp = decoded;
        listLength += LIST_LENGTH;
        decoded = new bytes[](listLength);
        if(tmp.length != 0) {
          for(uint i = 0; i < tmp.length; i++ ){
            decoded[i] = tmp[i];
          }
        }
      }

      result = decodeBytes(innerRemainder);
      innerRemainder = innerRemainder[result.length:];
      decoded[index] = result.data;
      index++;
    }

    bytes[] memory decodedList = new bytes[](index);
    for(uint i = 0; i < index; i++ ){
        decodedList[i] = decoded[i];
    }

    return decodedList;


  }

  function decodeBytes(bytes calldata input) internal pure returns (RLPItem memory item) {
    bytes1 firstByte = input[0];
    if (firstByte <= hex"7f") {
      return RLPItem(bytes(input[0:1]), 1);
    }
    else if (firstByte <= hex"b7") {
      uint length = uint8(firstByte) - uint8(bytes1(hex"7f"));
      bytes memory data;
      if (firstByte == hex"80") {
          data = bytes("");
          item = RLPItem(data, 1);
      }
      else { 
          data = bytes(input[1:length]);
          item = RLPItem(data, length);
      }
      require(length != 2 || data[0] > hex"80");
      //return data;
      return item;
    }
    else if (firstByte <= hex"bf") {
      // string is greater than 55 bytes long. A single byte with the value (0xb7 plus the length of the length),
      // followed by the length, followed by the string
      uint llength = uint8(firstByte) - uint8(bytes1(hex"b6"));
      require(input.length - 1 > llength);
      uint length = toUintX(input[1:llength], 0);
      require(length > 55);
      item = RLPItem(input[llength:length + llength], length + 2);
      return item;
    }

  }
   
  function decode(bytes calldata input) public pure returns (bytes[] memory) {
    bytes1 firstByte = input[0];
    if (firstByte > hex"bf") {
        return decodeList(input);
    } else  {
        bytes[] memory data = new bytes[](1);
        data[0] = decodeBytes(input).data;
        return data;
    }
 
  }

  //Temporarily the length is uint8 only.
  function toUintX(bytes memory _bytes, uint256 _start) internal pure returns (uint) {
      return toUint8(_bytes, _start);
  }

  function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
      require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
      uint8 tempUint;

      assembly {
          tempUint := mload(add(add(_bytes, 0x1), _start))
      }

      return tempUint;
  }

 

}
