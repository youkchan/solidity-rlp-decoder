// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "solidity-bytes-utils/contracts/BytesLib.sol";

library RLPDecoder {

  struct RLPItem {
      bytes data;
      uint length;
  }

  uint constant LIST_LENGTH = 20;

  //Nested Lists are not supported. 
  function decodeList(bytes calldata input) internal pure returns (bytes[] memory) {
    bytes1 firstByte = input[0];
    bytes memory innerRemainder;
    uint length = 0;
    if (firstByte <= hex"f7") {
      length = uint8(firstByte) - uint8(bytes1(hex"c0"));
      innerRemainder = BytesLib.slice(input, 1, length);
    } else {
      // a list  over 55 bytes long
      uint llength = uint8(firstByte) - uint8(bytes1(hex"f7"));
      length = toUintX(BytesLib.slice(input, 1, llength), 0);
      innerRemainder = BytesLib.slice(input, llength + 1, length);
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
      innerRemainder = BytesLib.slice(innerRemainder, result.length, innerRemainder.length - result.length);
      decoded[index] = result.data;
      index++;
    }

    bytes[] memory decodedList = new bytes[](index);
    for(uint i = 0; i < index; i++ ){
        decodedList[i] = decoded[i];
    }

   return decodedList;


  }

  function decodeBytes(bytes memory input) internal pure returns (RLPItem memory item) {
    bytes1 firstByte = input[0];
    if (firstByte <= hex"7f") {
      return RLPItem(bytes(BytesLib.slice(input, 0,1)), 1);
    }
    else if (firstByte <= hex"b7") {
      uint length = uint8(firstByte) - uint8(bytes1(hex"7f"));
      bytes memory data;
      if (firstByte == hex"80") {
          data = bytes("");
          item = RLPItem(data, 1);
      }
      else { 
          data = bytes(BytesLib.slice(input, 1, length - 1));
          item = RLPItem(data, length);
      }
      require(length != 2 || data[0] > hex"80");
      return item;
    }
    else if (firstByte <= hex"bf") {
      // string is greater than 55 bytes long. A single byte with the value (0xb7 plus the length of the length),
      // followed by the length, followed by the string
      uint llength = uint8(firstByte) - uint8(bytes1(hex"b7"));
      require(input.length > llength);
      uint length = toUintX(BytesLib.slice(input, 1, llength), 0);
      require(length > 55);
      item = RLPItem(BytesLib.slice(input, llength + 1, length), length + 2);
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

  function toUintX(bytes memory _bytes, uint256 _start) internal pure returns (uint) {

      require(_bytes.length > 0 && _bytes.length <= 8);
      if(_bytes.length == 1) {
          return BytesLib.toUint8(_bytes, _start);
      } else if(_bytes.length == 2) {
          return BytesLib.toUint16(_bytes, _start);
      } else if(_bytes.length == 3) {
          return toUint24(_bytes, _start);
      } else if(_bytes.length == 4) {
          return BytesLib.toUint32(_bytes, _start);
      } else if(_bytes.length == 5) {
          return toUint40(_bytes, _start);
      } else if(_bytes.length == 6) {
          return toUint48(_bytes, _start);
      } else if(_bytes.length == 7) {
          return toUint56(_bytes, _start);
      } else if(_bytes.length == 8) {
          return BytesLib.toUint64(_bytes, _start);
      }

      return BytesLib.toUint64(_bytes, _start);
  }


  function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
    require(_bytes.length >= _start + 3, "toUint24_outOfBounds");
    uint16 tempUint;

    assembly {
        tempUint := mload(add(add(_bytes, 0x3), _start))
    }

    return tempUint;
  }

  function toUint40(bytes memory _bytes, uint256 _start) internal pure returns (uint40) {
    require(_bytes.length >= _start + 5, "toUint40_outOfBounds");
    uint16 tempUint;

    assembly {
        tempUint := mload(add(add(_bytes, 0x5), _start))
    }

    return tempUint;
  }

  function toUint48(bytes memory _bytes, uint256 _start) internal pure returns (uint48) {
    require(_bytes.length >= _start + 6, "toUint48_outOfBounds");
    uint16 tempUint;

    assembly {
        tempUint := mload(add(add(_bytes, 0x6), _start))
    }

    return tempUint;
  }

  function toUint56(bytes memory _bytes, uint256 _start) internal pure returns (uint56) {
    require(_bytes.length >= _start + 7, "toUint56_outOfBounds");
    uint16 tempUint;

    assembly {
        tempUint := mload(add(add(_bytes, 0x7), _start))
    }

    return tempUint;
  }


}
