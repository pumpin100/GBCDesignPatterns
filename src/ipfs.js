const ipfsApi = require('ipfs-api');
const ipfs = new ipfsApi('localhost', '3000', {protocol:'http'});
export default ipfs;
