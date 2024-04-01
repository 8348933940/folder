const crypto = require('crypto');
const password = 'rajdeep';
let symmetricKey = Buffer.from(password, 'utf-8');
if (symmetricKey.length < 32) {
    const padding = Buffer.alloc(32 - symmetricKey.length, 0);
    symmetricKey = Buffer.concat([symmetricKey, padding]);
} else if (symmetricKey.length > 32) {
    symmetricKey = symmetricKey.slice(0, 32);
}
const fixedIV = Buffer.from('1234567890123456', 'utf-8'); 
function encryptData(data, symmetricKey, iv) {
    const cipher = crypto.createCipheriv('aes-256-cbc', symmetricKey, iv);
    let encryptedData = cipher.update(data, 'utf-8', 'hex');
    encryptedData += cipher.final('hex');
    return { encryptedData, iv };
}
function decryptData(encryptedData, symmetricKey, iv) {
    const decipher = crypto.createDecipheriv('aes-256-cbc', symmetricKey, iv);
    let decryptedData = decipher.update(encryptedData, 'hex', 'utf-8');
    decryptedData += decipher.final('utf-8');
    return decryptedData;
}
console.log("Symmetric Key:", symmetricKey.toString('hex'));

const dataToEncrypt = 'Blockchain';
const { encryptedData, iv } = encryptData(dataToEncrypt, symmetricKey, fixedIV);
console.log('Encrypted data:', encryptedData);
console.log('IV:', iv.toString('hex'));

const decryptedData = decryptData(encryptedData, symmetricKey, iv);
console.log('Decrypted data:', decryptedData);