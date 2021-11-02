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

});
