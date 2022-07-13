const nodemailer = require('nodemailer');
const JWTController = require('./jwt_controller').JWTController;
const port = process.env.EMAIL_PORT || 587


class NodeMailerController {

    static transporter = nodemailer.createTransport({
        host: 'smtp.gmail.com',
        port: port,
        secure: false,
        auth: {
            user: process.env.EMAIL_SENDER,
            pass: process.env.EMAIL_PASSWORD
        }
    });

    //workflow
    //send url with new token as a query parameter. URL path should be /verify-email?token=kfemkfemkp
    //set up route
    //set up controller


    static verifyEmail = async (recipient_id,recipient_email) => {
        //const options = this.email_verification_options(recipient_id, recipient_email);
        const token = await JWTController.createEmailToken(recipient_id);
        const emailVerificationURL = `http://127.0.0.1:3000/user/verify-email?token=${token}`;
        const options =  {
            from: process.env.EMAIL_SENDER,
            to: recipient_email,
            subject: 'Verify your email address',
            text: 
            `Click the link to verify your email address ${emailVerificationURL}`
        };

        this.transporter.sendMail(options, (err, info) => {
            if (err) throw err;
            return true
        });
    };


}


module.exports = {NodeMailerController}
