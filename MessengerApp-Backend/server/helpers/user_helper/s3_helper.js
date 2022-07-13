const fs = require('fs-extra');
const util = require('util');




const deleteImage = async (path) => {
    const unlinkFile = util.promisify(fs.unlink);
    await unlinkFile(path);
}




module.exports = {deleteImage}