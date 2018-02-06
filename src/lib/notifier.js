import dateFormat from 'dateformat';
import AWS from 'aws-sdk';

class Notifier {
    static notify(email, name, notifications) {
        const messages = notifications.map((notification) => {
            return `${dateFormat(notification.timestamp, "dddd, HH:MM")} \t ${notification.message}`
        }).join("\n");

        const notificationMessage = `Hi ${name}, your friends are active!\n\n${messages}\n`;

        const params = {
            Destination: {
                ToAddresses: [
                    email,
                ]
            },
            Message: {
                Body: {
                    Text: {
                        Charset: "UTF-8",
                        Data: notificationMessage
                    }
                },
                Subject: {
                    Charset: 'UTF-8',
                    Data: 'Komoot Notifications'
                }
            },
            Source: process.env.SENDER_EMAIL_ADDRESS,
        };

        AWS.config.update({region: process.env.AWS_DEFAULT_REGION});

        const sendPromise = new AWS.SES().sendEmail(params).promise();

        sendPromise.then(
            (data) => {
                console.log(`Email sent. ${data.MessageId}`);
            }).catch(
            (err) => {
                console.error(err, err.stack);
            });
    }
}

export default Notifier;