const RLPDecoder = artifacts.require("RLPDecoder");
const helper = artifacts.require("Helper");
const rlp = require("rlp");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RLPDecoder", function (/* accounts */) {

  let rlpDecoder;
  before(async () => {
    rlpDecoder = await helper.deployed();
  });


  it("first byte < 0x7f, return byte itself", async function () {
    const decoded = await rlpDecoder.decode('0x61');
    assert.equal(4, decoded[0].length)
    assert.equal(decoded[0], '0x61')
  });

  it("first byte < 0xb7, data is everything except first byte", async function () {
    const decoded = await rlpDecoder.decode('0x83646f67');
    assert.equal(8, decoded[0].length)
    assert.equal(decoded[0], '0x646f67')
  });


  it("first byte == 0x80, data is null", async function () {
    const decoded = await rlpDecoder.decode('0x80');
    assert.equal(decoded[0], '0x')
  });

  it('strings over 55 bytes long',async  function () {
    const testString =
      'This function takes in a data, convert it to buffer if not, and a length for recursion'
    const testBuffer = Buffer.from(testString)
    const encoded = rlp.encode(testBuffer)
    //console.log(testBuffer.toString('hex'));
    const encodedHex = "0x" + Buffer.from(new Uint8Array(encoded)).toString("hex")
    const decoded = await rlpDecoder.decode(encodedHex);
    assert.equal(Buffer.from(decoded[0].slice(2), 'hex').toString(), testString)
  })

  it('decode a list', async function () {
    const list = [
      '0x54686973',
      "0x546869732066756e6374696f6e2074616b657320696e206120646174612c20636f6e7665727420697420746f20627566666572206966206e6f742c20616e642061206c656e67746820666f7220726563757273696f6e",
      '0x07',
      '0x05',
      ,
    ]
    const encoded = rlp.encode(list)
    const encodedHex = "0x" + Buffer.from(new Uint8Array(encoded)).toString("hex")
    const decoded = await rlpDecoder.decode(encodedHex);
    assert.deepEqual(decoded, ['0x54686973',"0x546869732066756e6374696f6e2074616b657320696e206120646174612c20636f6e7665727420697420746f20627566666572206966206e6f742c20616e642061206c656e67746820666f7220726563757273696f6e", '0x07', '0x05','0x']);
  })

  it('decode a list with long string',async  function () {
    const list = [
      '0x54686973',
      "0x546869732066756e6374696f6e2074616b657320696e206120646174612c20636f6e7665727420697420746f20627566666572206966206e6f742c20616e642061206c656e67746820666f7220726563757273696f6e",
      '0x07',
      '0x05',
      ,
    ]
    const encoded = rlp.encode(list)
    const encodedHex = "0x" + Buffer.from(new Uint8Array(encoded)).toString("hex")
    const decoded = await rlpDecoder.decode(encodedHex);
    assert.deepEqual(decoded, ['0x54686973',"0x546869732066756e6374696f6e2074616b657320696e206120646174612c20636f6e7665727420697420746f20627566666572206966206e6f742c20616e642061206c656e67746820666f7220726563757273696f6e", '0x07', '0x05','0x']);

    const rlpencoded = rlp.decode(encoded)

  })

  it('decode a long list', async function () {
    const list = ['This', 'function', 'takes', 'in', 'a', 'data', 'convert', 'it', 'to', 'buffer', 'if', 'not', 'and', 'a', 'length', 'for', 'recursion', 'a1', 'a2', 'a3', 'ia4', 'a5', 'a6', 'a7', 'a8', 'ba9']

    const encoded = rlp.encode(list)
    const encodedHex = "0x" + Buffer.from(new Uint8Array(encoded)).toString("hex")
    const decoded = await rlpDecoder.decode(encodedHex);
    
    const decodedBuffer = rlp.decode(encoded)
    let rlpdecoded = []
    for (let i = 0; i < decodedBuffer.length; i++) {
      rlpdecoded[i] = "0x" + decodedBuffer[i].toString('hex');
    }

    assert.deepEqual(decoded, rlpdecoded)
  })

  it("decode a long list2", async function () {

    const string = '0xf90131a0b7030de7565b7531315fefd37f135a84fcfc82896e38bf7321d458d6846c4285a04c05e9cd442533a0fe8cfa6948540dc3e178f6add3fe1a4a253694d345b97198a0667e9f9a0e2a7ee536a4c9bd2013d06296430ae8181ea08c76c737debf379d63a01d1146f205eaeca9bf69943a5882e81de1ac7e7fceaf112af76bf29deb34bc47a022715dfc9109f2e78dbc177f48b3e181ad3044b936e3d50ddc958c42ff76a23fa00c32dd02fc4143baa82d42182151637ac256e6262036dc9c353c561b8b15b8d1a055c39110aff8d0a5469fd6a3dfa966dbbd0ae726c8ecab006a3093806c45e03ba0d6bdf0cc3e37ae46f2a295d18f35cd019bb4d189a1c18fb94ae38e70c6b8eae8a0cedb936c7df2fb8e6720770b3eab8ff0320182b0e2a28c517e38bcbdbc13178f8080808080808080';

    const encoded = Buffer.from(string.slice(2), 'hex');
    const decodedBuffer = rlp.decode(encoded)
    const decoded = await rlpDecoder.decode(string);
    let rlpdecoded = []
    for(let i = 0; i < decodedBuffer.length ;i++) {
      rlpdecoded[i] = "0x" + decodedBuffer[i].toString('hex');
    }
    assert.deepEqual(decoded, rlpdecoded)
  });


});
