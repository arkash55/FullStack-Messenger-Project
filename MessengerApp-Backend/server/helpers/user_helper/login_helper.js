const crypto = require('crypto-js');

const validate_password = (password, p_hash, p_salt) => {
    const salted_password = password.concat(p_salt);
    const hashed_pword = crypto.SHA256(salted_password).toString();
    if (hashed_pword !== p_hash) return false;
    return true
};




module.exports = {
    validate_password,
}